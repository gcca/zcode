:- use_module(library(plunit)).

ddup_sorted([], [], 0).

ddup_sorted([X], [X], 1).

ddup_sorted([X1, X2|Xs], [X1|Rs], C) :-
    X1=\=X2,
    ddup_sorted([X2|Xs], Rs, D),
    C is D+1.

ddup_sorted([X1, X2|Xs], Rs, C) :-
    X1==X2,
    ddup_sorted([X2|Xs], Rs, C).

:- begin_tests(ddup_sorted).

test(empty_input, all(Result-Count==[[]-0])) :-
    ddup_sorted([], Result, Count).

test(singleton, all(Result-Count==[[0]-1])) :-
    ddup_sorted([0], Result, Count).

test(two_distinct_elements, all(Result-Count==[[1, 2]-2])) :-
    ddup_sorted([1, 2], Result, Count).

test(two_equal_elements, all(Result-Count==[[1]-1])) :-
    ddup_sorted([1, 1], Result, Count).

test(all_distinct, all(Result-Count==[[-2, 0, 3, 5]-4])) :-
    ddup_sorted([-2, 0, 3, 5], Result, Count).

test(all_equal, all(Result-Count==[[4]-1])) :-
    ddup_sorted([4, 4, 4, 4], Result, Count).

test(leading_duplicates, all(Result-Count==[[1, 2, 3]-3])) :-
    ddup_sorted([1, 1, 1, 2, 3], Result, Count).

test(middle_duplicates, all(Result-Count==[[1, 2, 3]-3])) :-
    ddup_sorted([1, 2, 2, 3], Result, Count).

test(trailing_duplicates, all(Result-Count==[[1, 2, 3]-3])) :-
    ddup_sorted([1, 2, 3, 3], Result, Count).

test(official_example_1, all(Result-Count==[[1, 2]-2])) :-
    ddup_sorted([1, 1, 2], Result, Count).

test(official_example_2, all(Result-Count==[[0, 1, 2, 3, 4]-5])) :-
    ddup_sorted([0, 0, 1, 1, 1, 2, 2, 3, 3, 4], Result, Count).

test(negative_values, all(Result-Count==[[-2, 3, 5]-3])) :-
    ddup_sorted([-2, -2, 3, 3, 5], Result, Count).

test(boundary_values, all(Result-Count==[[-100, 0, 100]-3])) :-
    ddup_sorted([-100, -100, 0, 100, 100], Result, Count).

test(maximum_length, all(Result-Count==[[7]-1])) :-
    length(Input, 30000),
    maplist(=(7), Input),
    ddup_sorted(Input, Result, Count).

:- end_tests(ddup_sorted).
