# dual-clause-form-py

Python implementation of Fitting's Dual Clause Form (DNF) algorithm, from his Prolog program in _First-Order Logic and Automated Theorem Proving_.

## About

The Dual Clause Form Algorithm converts a propositional formula into an equivalent disjunction of conjunctions of literals (disjunctive normal form). Fitting presents it using uniform notation: α (conjunctive) formulas are expanded within a conjunction, and β (disjunctive) formulas split a conjunction in two. He implements it in Prolog with three predicates: `singlestep` (one rule application), `expand` (apply steps until none remain), and `dualclauseform` (the driver).

This repository is an independent reimplementation of that algorithm in Python, written from scratch rather than as a line-by-line port of the Prolog code.

## The algorithm

### Uniform notation

Fitting classifies every non-literal formula as conjunctive ($\alpha$) or disjunctive ($\beta$), each with two components. The core cases:

| $\alpha$          | $\alpha_1$ | $\alpha_2$ |
| ----------------- | ---------- | ---------- |
| $X \land Y$       | $X$        | $Y$        |
| $\lnot(X \lor Y)$ | $\lnot X$  | $\lnot Y$  |
| $\lnot(X \to Y)$  | $X$        | $\lnot Y$  |

| $\beta$            | $\beta_1$ | $\beta_2$ |
| ------------------ | --------- | --------- |
| $X \lor Y$         | $X$       | $Y$       |
| $\lnot(X \land Y)$ | $\lnot X$ | $\lnot Y$ |
| $X \to Y$          | $\lnot X$ | $Y$       |

Fitting's full table also covers $\leftarrow$, $\uparrow$, $\downarrow$, $\not\to$ and $\not\leftarrow$.

### Rules

Write $\langle \ldots \rangle$ for a generalized conjunction and $[\ldots]$ for a generalized disjunction. Start with $[\langle X \rangle]$ and, while some dual clause contains a non-literal, apply one of:

```math
\frac{\langle \ldots, \lnot\lnot Z, \ldots \rangle}{\langle \ldots, Z, \ldots \rangle}
\qquad
\frac{\langle \ldots, \alpha, \ldots \rangle}{\langle \ldots, \alpha_1, \alpha_2, \ldots \rangle}
\qquad
\frac{\langle \ldots, \beta, \ldots \rangle}{\langle \ldots, \beta_1, \ldots \rangle,\ \langle \ldots, \beta_2, \ldots \rangle}
```

An $\alpha$-step stays within one dual clause; a $\beta$-step splits a dual clause in two. (Fitting also rewrites $\lnot\top$ to $\bot$ and $\lnot\bot$ to $\top$.)

### Correctness

A Boolean valuation $v$ maps formulas to truth values and satisfies

```math
\begin{aligned}
v(\lnot X) = t &\iff v(X) = f \\
v(\alpha) = t &\iff v(\alpha_1) = t \text{ and } v(\alpha_2) = t \\
v(\beta) = t &\iff v(\beta_1) = t \text{ or } v(\beta_2) = t
\end{aligned}
```

Every rule application preserves truth under every Boolean valuation, and the algorithm always terminates. So for the final dual clause form $D$ of $X$:

```math
v(X) = v(D) \quad \text{for every Boolean valuation } v.
```

The tests in this repository check this by brute force over all assignments to the atoms of $X$.

### Example

```math
(p \lor q) \land \lnot r
\;\leadsto\; [\langle p \lor q,\ \lnot r \rangle]
\;\leadsto\; [\langle p, \lnot r \rangle,\ \langle q, \lnot r \rangle]
\;=\; (p \land \lnot r) \lor (q \land \lnot r)
```

## Prolog reference sketch

A compact Prolog sketch of the algorithm, covering `neg`, `and`, `or` and `imp`. It is written for illustration in the style of Fitting's program; see the book for his complete original.

```prolog
:- op(140, fy, neg).
:- op(160, xfy, [and, or, imp]).

% Uniform notation
conjunctive(_ and _).
conjunctive(neg(_ or _)).
conjunctive(neg(_ imp _)).

disjunctive(_ or _).
disjunctive(neg(_ and _)).
disjunctive(_ imp _).

components(X and Y,      X,     Y).
components(neg(X or Y),  neg X, neg Y).
components(neg(X imp Y), X,     neg Y).
components(X or Y,       X,     Y).
components(neg(X and Y), neg X, neg Y).
components(X imp Y,      neg X, Y).

% remove(Item, List, ListWithoutItem)
remove(_, [], []).
remove(X, [X|T], R)     :- remove(X, T, R).
remove(X, [H|T], [H|R]) :- X \== H, remove(X, T, R).

% One rule application (one edge of the graph)
singlestep([Con|Rest], [[X|Tmp]|Rest]) :-
    member(neg neg X, Con), remove(neg neg X, Con, Tmp).
singlestep([Con|Rest], [[A1, A2|Tmp]|Rest]) :-
    member(A, Con), conjunctive(A),
    components(A, A1, A2), remove(A, Con, Tmp).
singlestep([Con|Rest], [[B1|Tmp], [B2|Tmp]|Rest]) :-
    member(B, Con), disjunctive(B),
    components(B, B1, B2), remove(B, Con, Tmp).
singlestep([Con|Rest], [Con|NewRest]) :-
    singlestep(Rest, NewRest).

% Follow edges until none remain (a maximal path)
expand(Dis, Newdis) :- singlestep(Dis, Temp), expand(Temp, Newdis).
expand(Dis, Dis).

% Driver
dualclauseform(X, Y) :- expand([[X]], Y).
```

```prolog
?- dualclauseform((p or q) and neg r, V).
V = [[p, neg r], [q, neg r]].
```

## Status

Work in progress.

## Citation

Melvin Fitting, _First-Order Logic and Automated Theorem Proving_, 2nd ed., Graduate Texts in Computer Science, Springer, New York, 1996.

```bibtex
@book{fitting1996,
  author    = {Fitting, Melvin},
  title     = {First-Order Logic and Automated Theorem Proving},
  edition   = {2},
  series    = {Graduate Texts in Computer Science},
  publisher = {Springer},
  address   = {New York},
  year      = {1996}
}
```
