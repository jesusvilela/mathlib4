#!/usr/bin/env python3
"""Exact independent small-graph oracle for signed-Laplacian semantics.

Checks *all* 761 absent/positive/negative edge assignments on 0..4
labeled vertices. No Lean imports or floating-point tolerances.
These are mathematical reference tests, NOT a Lean kernel replay.
"""

from fractions import Fraction
from itertools import product


def edges(n):
    return [(u, v) for u in range(n) for v in range(u + 1, n)]


def research_matrix(n, signing):
    """Research definition: +1 off-diagonal for wraps, -1 for positive edges."""
    mat = [[0] * n for _ in range(n)]
    for (u, v), sigma in signing.items():
        if not sigma:
            continue
        mat[u][u] += 1
        mat[v][v] += 1
        mat[u][v] = -sigma
        mat[v][u] = -sigma
    return mat


def library_matrix(n, signing):
    """Separately construct D-A with signed adjacency coefficients."""
    adj = [[0] * n for _ in range(n)]
    deg = [0] * n
    for (u, v), sigma in signing.items():
        if not sigma:
            continue
        adj[u][v] = adj[v][u] = sigma
        deg[u] += 1
        deg[v] += 1
    return [[(deg[u] if u == v else 0) - adj[u][v]
             for v in range(n)] for u in range(n)]


def rank_exact(mat):
    n = len(mat)
    a = [[Fraction(x) for x in row] for row in mat]
    rank = 0
    for col in range(n):
        pivot = next((r for r in range(rank, n) if a[r][col]), None)
        if pivot is None:
            continue
        a[rank], a[pivot] = a[pivot], a[rank]
        divisor = a[rank][col]
        a[rank] = [x / divisor for x in a[rank]]
        for row in range(n):
            if row != rank and a[row][col]:
                factor = a[row][col]
                a[row] = [a[row][k] - factor * a[rank][k] for k in range(n)]
        rank += 1
    return rank


def det_exact(mat):
    a = [[Fraction(x) for x in row] for row in mat]
    n = len(a)
    result = Fraction(1)
    for col in range(n):
        pivot = next((r for r in range(col, n) if a[r][col]), None)
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            result = -result
        divisor = a[col][col]
        result *= divisor
        for row in range(col + 1, n):
            factor = a[row][col] / divisor
            for j in range(col + 1, n):
                a[row][j] -= factor * a[col][j]
            a[row][col] = 0
    return result


def balanced_components(n, signing):
    """Independent parity BFS: positive edges preserve, negative reverse."""
    adj = [[] for _ in range(n)]
    for (u, v), sigma in signing.items():
        if sigma:
            adj[u].append((v, sigma))
            adj[v].append((u, sigma))
    coloring = [0] * n
    count = 0
    for origin in range(n):
        if coloring[origin]:
            continue
        coloring[origin] = 1
        stack = [origin]
        balanced = True
        while stack:
            u = stack.pop()
            for v, sigma in adj[u]:
                desired = sigma * coloring[u]
                if not coloring[v]:
                    coloring[v] = desired
                    stack.append(v)
                elif coloring[v] != desired:
                    balanced = False
        count += int(balanced)
    return count


def energy_matrix(mat, x):
    return sum(x[u] * mat[u][v] * x[v]
               for u in range(len(mat)) for v in range(len(mat)))


def energy_edges(signing, x):
    return sum((x[u] - sigma * x[v]) ** 2
               for (u, v), sigma in signing.items() if sigma)


def check_graph(n, signing):
    a = research_matrix(n, signing)
    b = library_matrix(n, signing)
    assert a == b, (n, signing, 'matrix identity', a, b)
    assert all(a[u][v] == a[v][u] for u in range(n) for v in range(n))
    balanced = balanced_components(n, signing)
    assert n - rank_exact(a) == balanced, (n, signing, 'kernel/balance')
    for x in product((-1, 0, 1), repeat=n):
        e = energy_edges(signing, x)
        assert energy_matrix(a, x) == e >= 0, (n, signing, x, 'energy/PSD')
        assert (e == 0) == all(x[u] == sigma * x[v]
                              for (u, v), sigma in signing.items() if sigma), (
                                  n, signing, x, 'parallel section')
    for switches in product((-1, 1), repeat=n):
        switched = {(u, v): sigma * switches[u] * switches[v] if sigma else 0
                    for (u, v), sigma in signing.items()}
        transformed = research_matrix(n, switched)
        assert all(transformed[u][v] == switches[u] * a[u][v] * switches[v]
                   for u in range(n) for v in range(n)), (n, signing, 'gauge')
        assert balanced_components(n, switched) == balanced, (n, signing, 'gauge parity')
    if n:
        shifted = {tuple(sorted(((u + 1) % n, (v + 1) % n))): sigma
                   for (u, v), sigma in signing.items()}
        transformed = research_matrix(n, shifted)
        assert all(transformed[(u + 1) % n][(v + 1) % n] == a[u][v]
                   for u in range(n) for v in range(n)), (n, signing, 'vertex relabel')


def check_triangle_spectra():
    for vals, spectrum in [((1, 1, 1), (0, 3, 3)),
                           ((-1, 1, 1), (1, 1, 4))]:
        mat = research_matrix(3, dict(zip(edges(3), vals)))
        for lam in (-2, -1, 0, 1, 2, 3, 4, 5):
            actual = det_exact([[(lam if u == v else 0) - mat[u][v]
                                 for v in range(3)] for u in range(3)])
            expected = 1
            for root in spectrum:
                expected *= lam - root
            assert actual == expected, (vals, lam, actual, expected)


def main():
    num = 0
    for n in range(5):
        es = edges(n)
        for values in product((0, 1, -1), repeat=len(es)):
            check_graph(n, dict(zip(es, values)))
            num += 1
    assert num == 761, num
    check_triangle_spectra()
    print('PASS 761 complete ternary graphs (0..4 vertices): exact matrix, '
          'rational kernel/balance, edge energy/PSD, gauge, relabeling, '
          'parallel-section tests and two analytic triangle spectra')
    print('SCOPE: independent finite-graph reference, not a Lean theorem replay')


if __name__ == '__main__':
    main()
