#!/usr/bin/env bash
# Compile and cache each migrated theorem module in dependency order.
# Deliberately fail on the first unresolved compiler/proof error.
set -euo pipefail
mkdir -p .lake/build/lib/lean/ConnectionLaplacian
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
for name in "${modules[@]}"; do
  echo "::group::Compile ConnectionLaplacian.${name}"
  lake env lean -o ".lake/build/lib/lean/ConnectionLaplacian/${name}.olean" "ConnectionLaplacian/${name}.lean"
  echo "::endgroup::"
done
lake env lean -o .lake/build/lib/lean/ConnectionLaplacian.olean ConnectionLaplacian.lean
# Source trust boundary; no sorry, admit, native_decide or project-local axioms.
python3 Porting/audit_trust.py --root .
# Each requested declaration must appear, with only standard transitive axioms.
lake env lean ConnectionLaplacian/AxiomAudit.lean | tee /tmp/connection-laplacian-axiom-audit.log
python3 Porting/audit_trust.py --root . --axiom-output /tmp/connection-laplacian-axiom-audit.log
echo "PASS: all 19 theorem-spine source files compiled; review axioms separately."
