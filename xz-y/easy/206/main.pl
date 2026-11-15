:- use_module(library(plunit)).

reverse([], []).

reverse([L|Ls], Rs) :-
    reverse(Ls, Ss),
    append(Ss, [L], Rs).

:- begin_tests(reverse).

test(official_example_1, all(Result==[[5, 4, 3, 2, 1]])) :-
    reverse([1, 2, 3, 4, 5], Result).

test(official_example_2, all(Result==[[2, 1]])) :-
    reverse([1, 2], Result).

test(official_example_3, all(Result==[[]])) :-
    reverse([], Result).

test(single_node, all(Result==[[7]])) :-
    reverse([7], Result).

test(duplicate_values, all(Result==[[3, 2, 2, 1]])) :-
    reverse([1, 2, 2, 3], Result).

test(all_equal, all(Result==[[4, 4, 4]])) :-
    reverse([4, 4, 4], Result).

test(palindrome, all(Result==[[1, 2, 3, 2, 1]])) :-
    reverse([1, 2, 3, 2, 1], Result).

test(negative_values, all(Result==[[-1, 0, -3]])) :-
    reverse([-3, 0, -1], Result).

test(boundary_values, all(Result==[[5000, 0, -5000]])) :-
    reverse([-5000, 0, 5000], Result).

test(involution, all(Result==[[1, 2, 3, 4, 5]])) :-
    reverse([1, 2, 3, 4, 5], Reversed),
    reverse(Reversed, Result).

test(maximum_length,
     [ setup(( numlist(1, 5000, Input),
               findall(X, (between(1, 5000, I), X is 5001-I), Expected) )),
       all(Result==[Expected])
     ]) :-
    reverse(Input, Result).

:- end_tests(reverse).
