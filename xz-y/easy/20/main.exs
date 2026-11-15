defmodule Parentheses do
  def is_opening(c), do: c in [?{, ?[, ?(]
  def closing_of(?}), do: ?{
  def closing_of(?]), do: ?[
  def closing_of(?)), do: ?(
  def closing_of(_), do: raise(ArgumentError, "closing_of requires a closing bracket")

  def valid_parenthesis(s), do: scan(s, [])
  defp scan(<<>>, stack), do: stack == []

  defp scan(<<c, rest::binary>>, stack) do
    if is_opening(c) do
      scan(rest, [c | stack])
    else
      closing = closing_of(c)

      case stack do
        [^closing | tail] -> scan(rest, tail)
        _ -> false
      end
    end
  end
end

ExUnit.start(trace: true)

defmodule ParenthesesTest do
  use ExUnit.Case
  alias Parentheses, as: P

  test "opening detection" do
    for c <- ~c"([{", do: assert(P.is_opening(c))
    for c <- ~c")]}a", do: refute(P.is_opening(c))
  end

  test "closing mappings" do
    assert P.closing_of(?}) == ?{
    assert P.closing_of(?]) == ?[
    assert P.closing_of(?)) == ?(
  end

  test "valid inputs" do
    for s <- ["()", "[]", "{}", "()[]{}", "{[()]}", "{[()()]([])}{}[({})]", "(()[{}])({[]})", ""],
        do: assert(P.valid_parenthesis(s), s)
  end

  test "invalid inputs" do
    for s <- [
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
        ],
        do: refute(P.valid_parenthesis(s), s)
  end

  test "long inputs" do
    assert P.valid_parenthesis(String.duplicate("(", 5000) <> String.duplicate(")", 5000))
    assert P.valid_parenthesis(String.duplicate("[]", 5000))
    refute P.valid_parenthesis(String.duplicate("(", 4999) <> "[)" <> String.duplicate(")", 4999))
  end
end
