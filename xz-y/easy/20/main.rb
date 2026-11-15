require 'minitest/autorun'

def is_opening(c)
  c == '{' || c == '[' || c == '('
end

def closing_of(c)
  case c
  when '}' then '{'
  when ']' then '['
  when ')' then '('
  else raise ArgumentError, 'closing_of requires a closing bracket'
  end
end

def valid_parenthesis(s)
  stack = []

  s.each_char do |c|
    if is_opening(c)
      stack.push(c)
      next
    end

    closing = closing_of(c)
    return false if stack.last != closing

    stack.pop
  end

  stack.empty?
end

class ValidParenthesisTest < Minitest::Test
  def test_is_opening_recognizes_only_opening_brackets
    '([{'.each_char { |c| assert is_opening(c), c }
    ')]}a'.each_char { |c| refute is_opening(c), c }
  end

  def test_closing_of_maps_closing_brackets_to_their_openings
    { '}' => '{', ']' => '[', ')' => '(' }.each do |closing, opening|
      assert_equal opening, closing_of(closing)
    end
  end

  def test_closing_of_rejects_unsupported_characters
    ['(', '[', '{', 'a', ''].each do |c|
      assert_raises(ArgumentError) { closing_of(c) }
    end
  end

  def test_accepts_each_bracket_type
    ['()', '[]', '{}'].each { |s| assert valid_parenthesis(s), s }
  end

  def test_accepts_adjacent_and_nested_pairs_and_empty_input
    ['()[]{}', '{[()]}', '{[()()]([])}{}[({})]', '(()[{}])({[]})', ''].each do |s|
      assert valid_parenthesis(s), s
    end
  end

  def test_accepts_long_inputs
    assert valid_parenthesis('(' * 5000 + ')' * 5000)
    assert valid_parenthesis('[]' * 5000)
  end

  def test_rejects_mismatched_and_incorrectly_nested_pairs
    ['(]', '[(])'].each { |s| refute valid_parenthesis(s), s }
  end

  def test_rejects_unmatched_brackets
    ['(', ')', '())', '(()', '{[()()]([])}{}[({})]]', '{[()()]([])}{}[({})]({'].each do |s|
      refute valid_parenthesis(s), s
    end
  end

  def test_rejects_deep_mismatches_and_crossed_nesting
    ['{[()()]([)]}{}', '{[({[()]})]}[({[}])]'].each do |s|
      refute valid_parenthesis(s), s
    end
    refute valid_parenthesis('(' * 4999 + '[)' + ')' * 4999)
  end
end
