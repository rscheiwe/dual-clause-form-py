% Prolog sketch of the dual clause form program, for side-by-side
% comparison with the Python package. Covers neg, and, or, and imp.
% See Fitting's book for the complete original.

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
