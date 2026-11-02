/-
Hardening/Compat.lean — modern Lean comparator compatibility note

The original Lean 4.11 research repository carried inert stand-ins for
String.ofList and eagerReduce because they were missing from that toolchain
but requested by a newer comparator/exporter.

The current Mathlib fork uses a newer Lean toolchain providing these names
itself. Redeclaring them would conflict with kernel/builtin definitions.
The legacy shims are therefore intentionally absent in this migration.
No statement or proof in the trusted ConnectionLaplacian spine depends on
them, and this compatibility file is outside that spine.

Historical comparator transcripts, external dual-kernel replay, and
intentional negative controls remain independent of compilation here.
-/