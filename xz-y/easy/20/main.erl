-module(main).
-export([is_opening/1, closing_of/1, valid_parenthesis/1]).
-include_lib("eunit/include/eunit.hrl").

-spec is_opening(char()) -> boolean().
is_opening(C) ->
    C =:= ${ orelse C =:= $[ orelse C =:= $(.

-spec closing_of(char()) -> char().
closing_of($}) -> ${;
closing_of($]) -> $[;
closing_of($)) -> $(;
closing_of(_) -> erlang:error(badarg).

-spec valid_parenthesis(string()) -> boolean().
valid_parenthesis(S) -> scan(S, []).

scan([], Stack) -> Stack =:= [];
scan([C | Rest], Stack) ->
    case is_opening(C) of
        true -> scan(Rest, [C | Stack]);
        false ->
            Closing = closing_of(C),
            case Stack of
                [Closing | Tail] -> scan(Rest, Tail);
                _ -> false
            end
    end.

helpers_test_() ->
    [{"opening " ++ [C], ?_assert(is_opening(C))} || C <- "([{"] ++
    [{"not opening " ++ [C], ?_assertNot(is_opening(C))} || C <- ")]}a"] ++
    [{"closing " ++ [C], ?_assertEqual(Opening, closing_of(C))} ||
        {C, Opening} <- [{$}, ${}, {$], $[}, {$), $(}]].

valid_inputs_test_() ->
    [{"valid " ++ S, ?_assert(valid_parenthesis(S))} || S <- [
        "()",
        "[]",
        "{}",
        "()[]{}",
        "{[()]}",
        "{[()()]([])}{}[({})]",
        "(()[{}])({[]})",
        ""
    ]].

invalid_inputs_test_() ->
    [{"invalid " ++ S, ?_assertNot(valid_parenthesis(S))} || S <- [
        "(]",
        "[(])",
        "(",
        ")",
        "())",
        "(()",
        "{[()()]([])}{}[({})]]",
        "{[()()]([])}{}[({})]({",
        "{[()()]([)]}{}",
        "{[({[()]})]}[({[}])]"
    ]].

long_inputs_test_() ->
    [
        {"deep nesting", ?_assert(valid_parenthesis(
            lists:duplicate(5000, $() ++ lists:duplicate(5000, $))))},
        {"long adjacent pairs", ?_assert(valid_parenthesis(
            lists:flatten(lists:duplicate(5000, "[]"))))},
        {"deep mismatch", ?_assertNot(valid_parenthesis(
            lists:duplicate(4999, $() ++ "[)" ++ lists:duplicate(4999, $))))}
    ].
