#include <stack>

#include <gtest/gtest.h>

bool IsOpening(const char c) { return c == '{' or c == '[' or c == '('; }

char ClosingOf(const char c) {
  switch (c) {
  case '}':
    return '{';
  case ']':
    return '[';
  case ')':
    return '(';
  default:
    std::unreachable();
  }
  std::unreachable();
}

bool ValidParenthesis(const std::string &s) {
  std::stack<char> stack;

  auto i = s.cbegin();

  while (i < s.cend()) {
    if (IsOpening(*i)) {
      stack.push(*i++);
      continue;
    }

    char closing = ClosingOf(*i++);
    if (stack.empty() or stack.top() != closing)
      return false;
    stack.pop();
  }

  return stack.empty();
}

TEST(IsOpeningTest, RecognizesOnlyOpeningBrackets) {
  for (char c : {'(', '[', '{'})
    EXPECT_TRUE(IsOpening(c));
  for (char c : {')', ']', '}', 'a'})
    EXPECT_FALSE(IsOpening(c));
}

TEST(ValidParenthesisTest, AcceptsEachBracketType) {
  EXPECT_TRUE(ValidParenthesis("()"));
  EXPECT_TRUE(ValidParenthesis("[]"));
  EXPECT_TRUE(ValidParenthesis("{}"));
}

TEST(ValidParenthesisTest, AcceptsAdjacentAndNestedPairs) {
  EXPECT_TRUE(ValidParenthesis("()[]{}"));
  EXPECT_TRUE(ValidParenthesis("{[()]}"));
  EXPECT_TRUE(ValidParenthesis("{[()()]([])}{}[({})]"));
  EXPECT_TRUE(ValidParenthesis("(()[{}])({[]})"));
}

TEST(ValidParenthesisTest, AcceptsLongInputs) {
  const std::string deeply_nested =
      std::string(5000, '(') + std::string(5000, ')');
  EXPECT_TRUE(ValidParenthesis(deeply_nested));

  std::string adjacent;
  for (int i = 0; i < 5000; ++i)
    adjacent += "[]";
  EXPECT_TRUE(ValidParenthesis(adjacent));
}

TEST(ValidParenthesisTest, RejectsMismatchedAndIncorrectlyNestedPairs) {
  EXPECT_FALSE(ValidParenthesis("(]"));
  EXPECT_FALSE(ValidParenthesis("[(])"));
}

TEST(ValidParenthesisTest, RejectsUnmatchedBrackets) {
  EXPECT_FALSE(ValidParenthesis("("));
  EXPECT_FALSE(ValidParenthesis(")"));
  EXPECT_FALSE(ValidParenthesis("())"));
  EXPECT_FALSE(ValidParenthesis("(()"));
  EXPECT_FALSE(ValidParenthesis("{[()()]([])}{}[({})]]"));
  EXPECT_FALSE(ValidParenthesis("{[()()]([])}{}[({})]({"));
}

TEST(ValidParenthesisTest, RejectsDeepMismatchesAndCrossedNesting) {
  EXPECT_FALSE(ValidParenthesis("{[()()]([)]}{}"));
  EXPECT_FALSE(ValidParenthesis("{[({[()]})]}[({[}])]"));

  std::string deep =
      std::string(4999, '(') + "[" + ")" + std::string(4999, ')');
  EXPECT_FALSE(ValidParenthesis(deep));
}
