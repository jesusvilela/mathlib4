#!/usr/bin/env bash
# Modern-toolchain probe for the explicitly positive historical hardening artifacts.
# Each module is compiled separately: convention monolith/shards have overlapping names.
# Comparator challenges containing intentional 'sorry' are deliberately excluded.
# Stop at the first failing positive module so an upstream API break does not
# generate hundreds of cascading errors across the same 74 replicated fixtures.
set -euo pipefail

mkdir -p .lake/build/lib/lean/Hardening
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
    echo "::endgroup::"
    echo "::error title=Hardening port incomplete::Stopped at first failing positive artifact; downstream fixtures remain unverified"
    exit 1
  fi
  echo "::endgroup::"
done
echo "PASS: all selected historical positive hardening artifacts compile"
