:- use_module(library(plunit)).

max_non_adjacent_sum_recursive([], 0).

max_non_adjacent_sum_recursive([X], Sum) :-
    Sum is max(0, X).

max_non_adjacent_sum_recursive([X, Y|Rest], Sum) :-
    max_non_adjacent_sum_recursive([Y|Rest], Skip),
    max_non_adjacent_sum_recursive(Rest, TailSum),
    Sum is max(Skip, X + TailSum).

max_non_adjacent_sum(Values, Sum) :-
    max_non_adjacent_sum(Values, 0, 0, Sum).

max_non_adjacent_sum([], _, OneBack, OneBack).

max_non_adjacent_sum([X|Rest], TwoBack, OneBack, Sum) :-
    Current is max(OneBack, TwoBack + X),
    max_non_adjacent_sum(Rest, OneBack, Current, Sum).

:- begin_tests(seq0).

example([1, 3, -2, 5, -7, 10], 18).
example([], 0).
example([7], 7).
example([-9, -3, -7], 0).
example([4, 5, 4], 8).

test(recursive, [forall(example(Values, Expected)), all(Result == [Expected])]) :-
    max_non_adjacent_sum_recursive(Values, Result).

test(tail_recursive, [forall(example(Values, Expected)), all(Result == [Expected])]) :-
    max_non_adjacent_sum(Values, Result).

test(maximum_length_and_value, all(Result == [500_000_000_000_000])) :-
    length(Values, 1_000_000),
    maplist(=(1_000_000_000), Values),
    max_non_adjacent_sum(Values, Result).

:- end_tests(seq0).
