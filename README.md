# dual-clause-form-py

Python implementation of Fitting's Dual Clause Form (DNF) algorithm, from his Prolog program in *First-Order Logic and Automated Theorem Proving*.

## About

The Dual Clause Form Algorithm converts a propositional formula into an equivalent disjunction of conjunctions of literals (disjunctive normal form). Fitting presents it using uniform notation: α (conjunctive) formulas are expanded within a conjunction, and β (disjunctive) formulas split a conjunction in two. He implements it in Prolog with three predicates: `singlestep` (one rule application), `expand` (apply steps until none remain), and `dualclauseform` (the driver).

This repository is an independent reimplementation of that algorithm in Python, written from scratch rather than as a line-by-line port of the Prolog code.

## Status

Work in progress.

## Citation

Melvin Fitting, *First-Order Logic and Automated Theorem Proving*, 2nd ed., Graduate Texts in Computer Science, Springer, New York, 1996.

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