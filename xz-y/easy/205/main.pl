:- use_module(library(plunit)).

shape([], [], _).

shape([X|Xs], [Y|Ys], S) :-
    ( memberchk(X-Yp, S)
    -> Y = Yp, Ss = S
    ; Ss = [X-Y|S] ),
    shape(Xs, Ys, Ss).

isomorphic(X, Y) :-
    string_chars(X, Xs), string_chars(Y, Ys),
    shape(Xs, A, []), shape(Ys, B, []),
    A =@= B.

:- begin_tests(isomorphic).

test(egg_add) :-
    isomorphic("egg", "add").

test(foo_bar, fail) :-
    isomorphic("foo", "bar").

test(paper_title) :-
    isomorphic("paper", "title").

test(badc_baba, fail) :-
    isomorphic("badc", "baba").

test(empty_strings) :-
    isomorphic("", "").

test(single_char) :-
    isomorphic("a", "b").

test(identical) :-
    isomorphic("abc", "abc").

test(many_to_one, fail) :-
    isomorphic("ab", "aa").

test(one_to_many, fail) :-
    isomorphic("aa", "ab").

test(different_lengths, fail) :-
    isomorphic("ab", "abc").

test(digits_and_symbols) :-
    isomorphic("13!1", "42?4").

:- end_tests(isomorphic).
