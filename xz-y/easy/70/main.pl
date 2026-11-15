:- use_module(library(plunit)).

:- (table ways/2).

ways(1, 1).

ways(2, 2).

ways(K, W) :-
    K>2,
    L is K-1,
    M is K-2,
    ways(L, X),
    ways(M, Y),
    W is X+Y.

:- begin_tests(ways).

test(one_step, all(Result==[1])) :-
    ways(1, Result).

test(official_example_1, all(Result==[2])) :-
    ways(2, Result).

test(official_example_2, all(Result==[3])) :-
    ways(3, Result).

test(four_steps, all(Result==[5])) :-
    ways(4, Result).

test(five_steps, all(Result==[8])) :-
    ways(5, Result).

test(ten_steps, all(Result==[89])) :-
    ways(10, Result).

test(maximum_steps, all(Result==[1836311903])) :-
    ways(45, Result).

:- end_tests(ways).
