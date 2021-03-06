:- initialization(main).

% Chessboard will be N*N size
% X, Y is the starting point of the knight
knight :-
    knight(8).
knight(N) :-
    knight(N, 0, 0).
knight(N, X, Y) :-
    knight(N, X, Y, _).
knight(N, X, Y, L) :-
	Max is N * N,
	length(L, Max),
	knight(N, 0, Max, X, Y, L),
	display(N, 0, L).
 
% knight(NbCol, Coup, Max, Lig, Col, L),
% NbCol : number of columns per line
% Coup  : number of the current move
% Max   : maximum number of moves
% Lig/ Col : current position of the knight
% L : the "chessboard"

% the game is over
knight(_, Max, Max, _, _, _) :- !.

knight(NbCol, N, MaxN, Lg, Cl, L) :-
	% Is the move legal
	Lg >= 0, Cl >= 0, Lg < NbCol, Cl < NbCol,

	Pos is Lg * NbCol + Cl,
	N1 is N+1,
	% is the place free
	nth0(Pos, L, N1),

	LgM1 is Lg - 1, LgM2 is Lg - 2, LgP1 is Lg + 1, LgP2 is Lg + 2,
	ClM1 is Cl - 1, ClM2 is Cl - 2, ClP1 is Cl + 1, ClP2 is Cl + 2,
	maplist(best_move(NbCol, L),
		[(LgP1, ClM2), (LgP2, ClM1), (LgP2, ClP1),(LgP1, ClP2),
		(LgM1, ClM2), (LgM2, ClM1), (LgM2, ClP1),(LgM1, ClP2)],
		R),
	sort(R, RS),
	pairs_values(RS, Moves),

	move(NbCol, N1, MaxN, Moves, L).

move(NbCol, N1, MaxN, [(Lg, Cl) | R], L) :-
	knight(NbCol, N1, MaxN, Lg, Cl, L);
	move(NbCol, N1, MaxN,  R, L).

%% An illegal move is scored 1000
best_move(NbCol, _L, (Lg, Cl), 1000-(Lg, Cl)) :-
	(   Lg < 0 ; Cl < 0; Lg >= NbCol; Cl >= NbCol), !.

best_move(NbCol, L, (Lg, Cl), 1000-(Lg, Cl)) :-
	Pos is Lg*NbCol+Cl,
	nth0(Pos, L, V),
	\+var(V), !.

%% a legal move is scored with the number of moves a knight can make
best_move(NbCol, L, (Lg, Cl), R-(Lg, Cl)) :-
	LgM1 is Lg - 1, LgM2 is Lg - 2, LgP1 is Lg + 1, LgP2 is Lg + 2,
	ClM1 is Cl - 1, ClM2 is Cl - 2, ClP1 is Cl + 1, ClP2 is Cl + 2,
	include(possible_move(NbCol, L),
		[(LgP1, ClM2), (LgP2, ClM1), (LgP2, ClP1),(LgP1, ClP2),
		(LgM1, ClM2), (LgM2, ClM1), (LgM2, ClP1),(LgM1, ClP2)],
		Res),
	length(Res, Len),
	(   Len = 0 -> R = 1000; R = Len).

% test if a place is enabled
possible_move(NbCol, L, (Lg, Cl)) :-
	% move must be legal
	Lg >= 0, Cl >= 0, Lg < NbCol, Cl < NbCol,
	Pos is Lg * NbCol + Cl,
	% place must be free
	nth0(Pos, L, V),
	var(V).


display(_, _, []).
display(N, N, L) :-
	nl,
	display(N, 0, L).

display(N, M, [H | T]) :-
	format(atom(Out), '~t~d~3|', H),
    write(Out),
	M1 is M + 1,
	display(N, M1, T).

main :- knight(8,2,4), nl, halt.

%%Helpers
include(Goal, List, Included) :-
    include_(List, Goal, Included).
include_([], _, []).
include_([X1|Xs1], P, Included) :-
    ( call(P, X1)
    ->  Included = [X1|Included1]
    ;   Included = Included1
    ),
    include_(Xs1, P, Included1).

pairs_values([], []).
    pairs_values([_-V|T0], [V|T]) :-
        pairs_values(T0, T).