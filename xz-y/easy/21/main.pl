:- use_module(library(plunit)).

merge_sorted_lists([], L2, L2).

merge_sorted_lists(L1, [], L1).

merge_sorted_lists([X|Xs], [Y|Ys], [X|Rs]) :-
    X=<Y,
    merge_sorted_lists(Xs, [Y|Ys], Rs).

merge_sorted_lists([X|Xs], [Y|Ys], [Y|Rs]) :-
    X>Y,
    merge_sorted_lists([X|Xs], Ys, Rs).

:- begin_tests(merge_sorted_lists).

test(both_inputs_empty, true(Result==[])) :-
    merge_sorted_lists([], [], Result).

test(first_input_empty, true(Result==[1, 2, 3])) :-
    merge_sorted_lists([], [1, 2, 3], Result).

test(second_input_empty, true(Result==[1, 2, 3])) :-
    merge_sorted_lists([1, 2, 3], [], Result).

test(single_elements_ascending, true(Result==[1, 2])) :-
    merge_sorted_lists([1], [2], Result).

test(single_elements_descending, true(Result==[1, 2])) :-
    merge_sorted_lists([2], [1], Result).

test(equal_single_elements, true(Result==[1, 1])) :-
    merge_sorted_lists([1], [1], Result).

test(interleaved_values, true(Result==[1, 2, 3, 4, 5, 6])) :-
    merge_sorted_lists([1, 3, 5], [2, 4, 6], Result).

test(disjoint_ranges_first_input_smaller, true(Result==[1, 2, 3, 4, 5, 6])) :-
    merge_sorted_lists([1, 2, 3], [4, 5, 6], Result).

test(disjoint_ranges_second_input_smaller, true(Result==[1, 2, 3, 4, 5, 6])) :-
    merge_sorted_lists([4, 5, 6], [1, 2, 3], Result).

test(remaining_values_from_first_input, true(Result==[1, 2, 3, 4, 5, 7, 9])) :-
    merge_sorted_lists([1, 3, 5, 7, 9], [2, 4], Result).

test(remaining_values_from_second_input, true(Result==[1, 2, 3, 4, 5, 7, 9])) :-
    merge_sorted_lists([2, 4], [1, 3, 5, 7, 9], Result).

test(duplicates_within_and_across_inputs, true(Result==[1, 1, 1, 2, 2, 2, 4, 4])) :-
    merge_sorted_lists([1, 1, 2, 4], [1, 2, 2, 4], Result).

test(negative_values_and_zero, true(Result==[-5, -4, -2, -1, 0, 0, 3])) :-
    merge_sorted_lists([-5, -1, 0], [-4, -2, 0, 3], Result).

:- end_tests(merge_sorted_lists).
