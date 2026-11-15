:- use_module(library(plunit)).

is_opening('(').

is_opening('[').

is_opening('{').

closing_of('}', '{').

closing_of(']', '[').

closing_of(')', '(').

valid_parenthesis(String) :-
    string_chars(String, Chars),
    scan(Chars, []).

scan([], []).

scan([C|Rest], Stack) :-
    (   is_opening(C)
    ->  scan(Rest, [C|Stack])
    ;   closing_of(C, Opening),
        Stack=[Opening|Tail],
        scan(Rest, Tail)
    ).

:- begin_tests(parentheses).

test(openings) :-
    forall(member(C, ['(', '[', '{']), is_opening(C)).

test(not_openings) :-
    forall(member(C, [')', ']', '}', a]), \+is_opening(C)).

test(closings) :-
    closing_of('}', '{'),
    closing_of(']', '['),
    closing_of(')', '(').

test(valid_0) :-
    valid_parenthesis("()").

test(valid_1) :-
    valid_parenthesis("[]").

test(valid_2) :-
    valid_parenthesis("{}").

test(valid_3) :-
    valid_parenthesis("()[]{}").

test(valid_4) :-
    valid_parenthesis("{[()]}").

test(valid_5) :-
    valid_parenthesis("{[()()]([])}{}[({})]").

test(valid_6) :-
    valid_parenthesis("(()[{}])({[]})").

test(valid_7) :-
    valid_parenthesis("").

test(invalid_0, [fail]) :-
    valid_parenthesis("(]").

test(invalid_1, [fail]) :-
    valid_parenthesis("[(])").

test(invalid_2, [fail]) :-
    valid_parenthesis("(").

test(invalid_3, [fail]) :-
    valid_parenthesis(")").

test(invalid_4, [fail]) :-
    valid_parenthesis("())").

test(invalid_5, [fail]) :-
    valid_parenthesis("(()").

test(invalid_6, [fail]) :-
    valid_parenthesis("{[()()]([])}{}[({})]]").

test(invalid_7, [fail]) :-
    valid_parenthesis("{[()()]([])}{}[({})]({").

test(invalid_8, [fail]) :-
    valid_parenthesis("{[()()]([)]}{}").

test(invalid_9, [fail]) :-
    valid_parenthesis("{[({[()]})]}[({[}])]").

test(deep_nesting) :-
    length(Open, 5000),
    maplist(=('('), Open),
    length(Close, 5000),
    maplist(=(')'), Close),
    append(Open, Close, Chars),
    string_chars(S, Chars),
    valid_parenthesis(S).

test(adjacent_pairs) :-
    length(Pairs, 5000),
    maplist(=(['[', ']']), Pairs),
    append(Pairs, Chars),
    string_chars(S, Chars),
    valid_parenthesis(S).

test(deep_mismatch, [fail]) :-
    length(Open, 4999),
    maplist(=('('), Open),
    length(Close, 5000),
    maplist(=(')'), Close),
    append([Open, ['['], Close], Chars),
    string_chars(S, Chars),
    valid_parenthesis(S).

:- end_tests(parentheses).
