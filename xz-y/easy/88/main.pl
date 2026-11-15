:- use_module(library(plunit)).

merge_sorted_array(_, 0, Y, _, Y).

merge_sorted_array(Xs, M, [], 0, Rs) :-
    M>0,
    length(Rs, M),
    append(Rs, _, Xs).

merge_sorted_array([X|Xs], M, [Y|Ys], N, [X|Rs]) :-
    M>0,
    N>0,
    X=<Y,
    O is M-1,
    merge_sorted_array(Xs, O, [Y|Ys], N, Rs).

merge_sorted_array([X|Xs], M, [Y|Ys], N, [Y|Rs]) :-
    M>0,
    N>0,
    X>Y,
    P is N-1,
    merge_sorted_array([X|Xs], M, Ys, P, Rs).

:- begin_tests(merge_sorted_array).

test(official_example_1, all(Result==[[1, 2, 2, 3, 5, 6]])) :-
    merge_sorted_array([1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3, Result).

test(official_example_2, all(Result==[[1]])) :-
    merge_sorted_array([1], 1, [], 0, Result).

test(official_example_3, all(Result==[[1]])) :-
    merge_sorted_array([0], 0, [1], 1, Result).

test(first_input_empty_negative_value, all(Result==[[-1]])) :-
    merge_sorted_array([0], 0, [-1], 1, Result).

test(first_input_empty_multiple_values, all(Result==[[-2, 0, 3]])) :-
    merge_sorted_array([0, 0, 0], 0, [-2, 0, 3], 3, Result).

test(second_input_empty_multiple_values, all(Result==[[-2, 0, 3]])) :-
    merge_sorted_array([-2, 0, 3], 3, [], 0, Result).

test(second_input_exhausted_first, all(Result==[[1, 2]])) :-
    merge_sorted_array([2, 0], 1, [1], 1, Result).

test(first_input_exhausted_first, all(Result==[[1, 2]])) :-
    merge_sorted_array([1, 0], 1, [2], 1, Result).

test(interleaved_values, all(Result==[[1, 2, 3, 4, 5, 6]])) :-
    merge_sorted_array([1, 3, 5, 0, 0, 0], 3, [2, 4, 6], 3, Result).

test(second_input_precedes_first, all(Result==[[1, 2, 3, 4, 5, 6]])) :-
    merge_sorted_array([4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3, Result).

test(all_equal, all(Result==[[2, 2, 2, 2]])) :-
    merge_sorted_array([2, 2, 0, 0], 2, [2, 2], 2, Result).

test(valid_zeros_and_placeholders, all(Result==[[-1, 0, 0, 0, 2]])) :-
    merge_sorted_array([-1, 0, 0, 0, 0], 3, [0, 2], 2, Result).

test(all_zeros, all(Result==[[0, 0, 0]])) :-
    merge_sorted_array([0, 0, 0], 1, [0, 0], 2, Result).

test(negative_values, all(Result==[[-5, -4, -3, -2, -1]])) :-
    merge_sorted_array([-5, -2, 0, 0, 0], 2, [-4, -3, -1], 3, Result).

test(boundary_values, all(Result==[[-1000000000, -1000000000, 1000000000, 1000000000]])) :-
    merge_sorted_array([-1000000000, 1000000000, 0, 0],
                       2,
                       [-1000000000, 1000000000],
                       2,
                       Result).

test(maximum_combined_length, [setup(numlist(1, 200, Expected)), all(Result==[Expected])]) :-
    numlist(1, 100, First),
    numlist(101, 200, Second),
    length(Padding, 100),
    maplist(=(0), Padding),
    append(First, Padding, Input),
    merge_sorted_array(Input, 100, Second, 100, Result).

:- end_tests(merge_sorted_array).
