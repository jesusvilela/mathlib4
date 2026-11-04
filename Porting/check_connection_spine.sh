#!/usr/bin/env bash
# Probe all migrated modules via Lake, letting Lake construct imported Mathlib
# .oleans. A bare `lake env lean` cannot build missing import dependencies.
# Preserve strict failure semantics and the dependency-aware result table.
set -euo pipefail

mkdir -p .lake/build/lib/lean/ConnectionLaplacian
python3 Porting/audit_trust.py --root .

modules=(
  Basic
  KernelDimension
  CycleSpectrum
  L5_Cover
  L6_Cohomology
  L8_Recognition
  L9_Bounds
  L10_CoverCharpoly
  L11_Trees
  L12_WalkH1
  L13_PSD
  L14_CycleEw
  L15_BridgeMonotone
  L16_SpectrumUnion
  L17_TracesAndLipschitz
  CycleMultiset
  CycleGraphTransfer
)
# Only direct imports; indirect dependencies propagate through the result table.
declare -A deps=(
  [Basic]=""
  [KernelDimension]="Basic"
  [CycleSpectrum]="Basic KernelDimension"
  [L5_Cover]="KernelDimension"
  [L6_Cohomology]="KernelDimension L5_Cover"
  [L8_Recognition]="L5_Cover L6_Cohomology"
  [L9_Bounds]="L8_Recognition"
  [L10_CoverCharpoly]="L5_Cover"
  [L11_Trees]="L8_Recognition"
  [L12_WalkH1]="L6_Cohomology"
  [L13_PSD]="KernelDimension"
  [L14_CycleEw]="L12_WalkH1"
  [L15_BridgeMonotone]="L12_WalkH1"
  [L16_SpectrumUnion]="L10_CoverCharpoly KernelDimension"
  [L17_TracesAndLipschitz]="L16_SpectrumUnion L9_Bounds L13_PSD"
  [CycleMultiset]="CycleSpectrum L10_CoverCharpoly"
  [CycleGraphTransfer]="CycleMultiset L16_SpectrumUnion"
)
declare -A outcome=()
failed=()
skipped=()

for name in "${modules[@]}"; do
  blocked=()
  for dep in ${deps[$name]}; do
    if [[ "${outcome[$dep]:-MISSING}" != PASS ]]; then
      blocked+=("$dep")
    fi
  done
  if (( ${#blocked[@]} )); then
    outcome[$name]=SKIP
    skipped+=("$name")
    echo "::notice title=Skipped $name::Unverified imports: ${blocked[*]}"
    continue
  fi
  echo "::group::Compile ConnectionLaplacian.$name"
  if lake build "ConnectionLaplacian.${name}"; then
    outcome[$name]=PASS
    echo "PASS: ConnectionLaplacian.$name"
  else
    outcome[$name]=FAIL
    failed+=("$name")
    echo "::error title=Compilation failure::$name"
  fi
  echo "::endgroup::"
done

printf 'Module result summary:\n'
for name in "${modules[@]}"; do
  printf '  %s: %s\n' "$name" "${outcome[$name]}"
done
if (( ${#failed[@]} || ${#skipped[@]} )); then
  echo "::error title=Proof spine incomplete::Failed: ${failed[*]}; dependency-skipped: ${skipped[*]}"
  exit 1
fi

lake build ConnectionLaplacian
# All printed axioms are checked against a complete source-derived allowlist.
lake env lean ConnectionLaplacian/AxiomAudit.lean | tee /tmp/connection-laplacian-axiom-audit.log
python3 Porting/audit_trust.py --root . --axiom-output /tmp/connection-laplacian-axiom-audit.log
echo "PASS: all 19 theorem-spine source files compiled and audited."
