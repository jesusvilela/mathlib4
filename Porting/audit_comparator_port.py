#!/usr/bin/env python3
"""Static, source-pinned comparator audit. NOT comparator or kernel replay.

Keep the old challenge, solution, config, and negative-control bytes
immutable during the Lean/Mathlib port. A green result means provenance,
coverage, configuration, and intentional tampering are intact -- nothing
about execution by leanprover/comparator, nanoda, or a sandbox.
"""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "Porting/comparator_source_hashes.json"
ALLOWED = {"propext", "Quot.sound", "Classical.choice"}
GENERAL = [
    "cover_charpoly_eq_scalar_times_mobius",
    "isBalanced_iff_closedWalk_wrap_even",
    "signedLaplacianMobius_posSemidef",
    "numBalancedComponents_monotone_remove_nonwrap_nonbridge",
    "mobius_charpoly_roots_eq_union",
    "frobenius_laplacian_decomposes",
    "trace_mul_scalar_signed_eq",
]
CYCLE = [
    "periodic_charpoly",
    "antiperiodic_charpoly",
    "periodic_multiset",
    "antiperiodic_multiset",
    "mobius_graph_multiset",
]
THEOREM = re.compile(r"(?m)^\s*theorem\s+([^\s(:]+)")


def guard(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit("comparator static audit FAILED: " + message)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def config(name: str) -> dict:
    path = "Hardening/" + name
    cfg = json.loads(read(path))
    guard(isinstance(cfg, dict), path + ": expected JSON object")
    guard(
        set(cfg) in (
            {"challenge_module", "solution_module", "theorem_names", "permitted_axioms"},
            {"challenge_module", "solution_module", "theorem_names", "permitted_axioms", "enable_nanoda"},
        ),
        path + ": unexpected configuration keys",
    )
    guard(set(cfg["permitted_axioms"]) == ALLOWED, path + ": axiom allowlist drift")
    guard(len(cfg["permitted_axioms"]) == 3, path + ": duplicate allowed axiom")
    return cfg


def names(path: str, prefix: str) -> list[str]:
    return [prefix + x for x in THEOREM.findall(read(path))]


def check_config(cfg: dict, challenge: str, solution: str, targets: list[str], name: str) -> None:
    guard(cfg["challenge_module"] == challenge, name + ": challenge module drift")
    guard(cfg["solution_module"] == solution, name + ": solution module drift")
    guard(cfg["theorem_names"] == targets, name + ": theorem coverage/order drift")


def source_provenance() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    guard(
        manifest["source_repository"] == "jesusvilela/connection_laplacian_lean"
        and manifest["source_commit"] == "0b4ad40a7dd26d924bd44096eaa5291c3882a67b",
        "pinned source identity drift",
    )
    files = manifest["git_blob_sha1"]
    guard(len(files) == 17, "expected 8 Lean files, 8 comparator configs, 1 cycle guard")
    for path, expected in files.items():
        payload = (ROOT / path).read_bytes()
        git_hash = hashlib.sha1(
            b"blob " + str(len(payload)).encode("ascii") + b"\0" + payload
        ).hexdigest()
        guard(git_hash == expected, path + ": pinned source bytes changed")
    print("PASS: 17 Git blob identities preserved from pinned research source")


def check_transcriptions() -> None:
    cases = [
        ("Hardening/Challenge.lean", "Hardening/Solution.lean", GENERAL, "Hardening."),
        ("Hardening/CycleChallenge.lean", "Hardening/CycleSolution.lean", CYCLE, "Hardening.Cycle."),
    ]
    for challenge, solution, expected, prefix in cases:
        target = [prefix + x for x in expected]
        guard(names(challenge, prefix) == target, challenge + ": challenge theorem drift")
        guard(names(solution, prefix) == target, solution + ": solution theorem drift")
        guarded = re.findall(r"(?m)^\s*sorry\s*$", read(challenge))
        guard(len(guarded) == len(target), challenge + ": expected one untrusted hole per theorem")
        guard(not re.search(r"(?m)^\s*(?:sorry|axiom)\b", read(solution)),
              solution + ": solution must not add sorry or axioms")

    guard(
        names("Hardening/Negative/BadChallenge.lean", "Hardening.")
        == ["Hardening." + x for x in GENERAL],
        "general mismatched challenge theorem list drift",
    )
    guard(
        names("Hardening/Negative/BadSolution.lean", "Hardening.")
        == ["Hardening." + x for x in GENERAL],
        "general axiom-smuggling solution theorem list drift",
    )
    for path in ("Hardening/CycleNegative/BadChallenge.lean",
                 "Hardening/CycleNegative/BadSolution.lean"):
        guard(names(path, "Hardening.Cycle.") ==
              ["Hardening.Cycle.antiperiodic_multiset"],
              path + ": one-target cycle negative control drift")

    guard("3 * (G.scalarLaplacian * G.signedLaplacianMobius).trace"
          in read("Hardening/Negative/BadChallenge.lean"),
          "tampered general-graph trace coefficient removed")
    guard("axiom smuggled_roots_union" in read("Hardening/Negative/BadSolution.lean"),
          "general-graph illicit axiom removed")
    guard("2 * j.val * Real.pi / n"
          in read("Hardening/CycleNegative/BadChallenge.lean"),
          "cycle eigenphase perturbation removed")
    guard("axiom smuggled_cycle_multiset" in
          read("Hardening/CycleNegative/BadSolution.lean"),
          "cycle illicit axiom removed")

    production = [ROOT / "ConnectionLaplacian.lean"]
    production += list((ROOT / "ConnectionLaplacian").rglob("*.lean"))
    for path in production:
        guard(not re.search(r"(?m)^\s*import\s+Hardening(?:\.|\s|$)",
                            path.read_text(encoding="utf-8")),
              str(path) + ": untrusted comparator module imported by production")
    print("PASS: 7 general and 5 cycle statements; four tampered controls isolated")


def check_configs() -> None:
    general = ["Hardening." + x for x in GENERAL]
    cycle = ["Hardening.Cycle." + x for x in CYCLE]

    gp = config("config.json")
    gn = config("config-nanoda.json")
    check_config(gp, "Hardening.Challenge", "Hardening.Solution", general, "general positive")
    guard("enable_nanoda" not in gp, "general positive must be plain")
    guard(gn.get("enable_nanoda") is True, "general dual-kernel flag missing")
    guard({k: v for k, v in gn.items() if k != "enable_nanoda"} == gp,
          "general dual-kernel config differs from positive")
    check_config(config("config-negative1-tampered-challenge.json"),
                 "Hardening.Negative.BadChallenge", "Hardening.Solution",
                 general, "general tampered challenge")
    check_config(config("config-negative2-smuggled-axiom.json"),
                 "Hardening.Challenge", "Hardening.Negative.BadSolution",
                 general, "general axiom-smuggling control")

    cp = config("config-cycle.json")
    cn = config("config-cycle-nanoda.json")
    check_config(cp, "Hardening.CycleChallenge", "Hardening.CycleSolution",
                 cycle, "cycle positive")
    guard("enable_nanoda" not in cp, "cycle positive must be plain")
    guard(cn.get("enable_nanoda") is True, "cycle dual-kernel flag missing")
    guard({k: v for k, v in cn.items() if k != "enable_nanoda"} == cp,
          "cycle dual-kernel config differs from positive")
    one = ["Hardening.Cycle.antiperiodic_multiset"]
    check_config(config("config-cycle-negative-phase.json"),
                 "Hardening.CycleNegative.BadChallenge", "Hardening.CycleSolution",
                 one, "cycle perturbed eigenphase")
    check_config(config("config-cycle-negative-axiom.json"),
                 "Hardening.CycleChallenge", "Hardening.CycleNegative.BadSolution",
                 one, "cycle illicit axiom")

    print("PASS: eight configs, two positive suites, two dual-kernel flags, four controls")


def main() -> None:
    source_provenance()
    check_transcriptions()
    check_configs()
    print("STATIC CHECK ONLY. No comparator, independent kernel, or negative rejection replay.")


if __name__ == "__main__":
    main()
