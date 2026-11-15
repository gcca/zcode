:- use_module(library(plunit)).

remove_element([], _, [], 0).

remove_element([X|Xs], Y, Rs, K) :-
    X==Y,
    remove_element(Xs, Y, Rs, K).

remove_element([X|Xs], Y, [X|Rs], K) :-
    X=\=Y,
    remove_element(Xs, Y, Rs, L),
    K is L+1.

:- begin_tests(remove_element).

test(empty_input, all(Result-Count==[[]-0])) :-
    remove_element([], 2, Result, Count).

test(singleton_removed, all(Result-Count==[[]-0])) :-
    remove_element([2], 2, Result, Count).

test(singleton_retained, all(Result-Count==[[1]-1])) :-
    remove_element([1], 2, Result, Count).

test(all_removed, all(Result-Count==[[]-0])) :-
    remove_element([2, 2, 2, 2], 2, Result, Count).

test(none_removed, all(Result-Count==[[1, 3, 4]-3])) :-
    remove_element([1, 3, 4], 2, Result, Count).

test(leading_matches, all(Result-Count==[[1, 3]-2])) :-
    remove_element([2, 2, 1, 3], 2, Result, Count).

test(middle_matches, all(Result-Count==[[1, 3]-2])) :-
    remove_element([1, 2, 2, 3], 2, Result, Count).

test(trailing_matches, all(Result-Count==[[1, 3]-2])) :-
    remove_element([1, 3, 2, 2], 2, Result, Count).

test(alternating_matches, all(Result-Count==[[1, 3, 4]-3])) :-
    remove_element([2, 1, 2, 3, 2, 4, 2], 2, Result, Count).

test(retained_duplicates, all(Result-Count==[[1, 1, 3, 3]-4])) :-
    remove_element([1, 2, 1, 3, 2, 3], 2, Result, Count).

test(official_example_1, all(Result-Count==[[2, 2]-2])) :-
    remove_element([3, 2, 2, 3], 3, Result, Count).

test(official_example_2, all(Result-Count==[[0, 1, 3, 0, 4]-5])) :-
    remove_element([0, 1, 2, 2, 3, 0, 4, 2], 2, Result, Count).

test(remove_zero, all(Result-Count==[[50, 50]-2])) :-
    remove_element([0, 50, 0, 50, 0], 0, Result, Count).

test(remove_fifty, all(Result-Count==[[0, 0, 0]-3])) :-
    remove_element([0, 50, 0, 50, 0], 50, Result, Count).

test(maximum_removal_value, all(Result-Count==[[0, 50, 0]-3])) :-
    remove_element([0, 50, 0], 100, Result, Count).

test(maximum_length_all_removed, all(Result-Count==[[]-0])) :-
    length(Input, 100),
    maplist(=(7), Input),
    remove_element(Input, 7, Result, Count).

test(maximum_length_all_retained, [setup((length(Input, 100), maplist(=(7), Input))), all(Result-Count==[Input-100])]) :-
    remove_element(Input, 2, Result, Count).

:- end_tests(remove_element).
