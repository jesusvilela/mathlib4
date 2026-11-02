#!/usr/bin/env bash
# Modern-toolchain probe for the explicitly positive historical hardening artifacts.
# Each module is compiled separately: convention monolith/shards have overlapping names.
# Comparator challenges containing intentional 'sorry' are deliberately excluded.
set -euo pipefail

mkdir -p .lake/build/lib/lean/Hardening
failed=0
modules=(
  Compat
  Solution
  CycleSolution
  BatteryPrelude
  ConventionAnchor
  BatteryA
  BatteryB
  BatteryC
  BatteryD
  ConventionBattery
)
for name in "${modules[@]}"; do
  echo "::group::Hardening.$name (positive port probe)"
  if lake env lean -o ".lake/build/lib/lean/Hardening/$name.olean" "Hardening/$name.lean"; then
    echo "PASS: Hardening.$name"
  else
    echo "::error title=Hardening compilation failure::Hardening.$name"
    failed=1
  fi
  echo "::endgroup::"
done
if (( failed )); then
  echo "::error title=Hardening port incomplete::One or more positive artifacts require modern-toolchain repairs"
  exit 1
fi
echo "PASS: all selected historical positive hardening artifacts compile"
