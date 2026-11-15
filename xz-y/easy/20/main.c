#include <setjmp.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include <cmocka.h>

bool IsOpening(const char c) { return c == '{' || c == '[' || c == '('; }

char ClosingOf(const char c) {
  switch (c) {
  case '}':
    return '{';
  case ']':
    return '[';
  case ')':
    return '(';
  default:
    abort();
  }
}

bool ValidParenthesis(const char *s) {
  const size_t length = strlen(s);
  if (length == 0)
    return true;

  char *stack = malloc(length);
  if (stack == nullptr)
    abort();
  size_t size = 0;
  bool valid = true;

  for (const char *i = s; *i != '\0'; ++i) {
    if (IsOpening(*i)) {
      stack[size++] = *i;
      continue;
    }

    const char closing = ClosingOf(*i);
    if (size == 0 || stack[size - 1] != closing) {
      valid = false;
      break;
    }
    --size;
  }

  const bool result = valid && size == 0;
  free(stack);
  return result;
}

static void RecognizesOnlyOpeningBrackets(void **state) {
  (void)state;
  for (const char *c = "([{"; *c; ++c)
    assert_true(IsOpening(*c));
  for (const char *c = ")]}a"; *c; ++c)
    assert_false(IsOpening(*c));
}

static void MapsClosingBracketsToOpenings(void **state) {
  (void)state;
  assert_int_equal(ClosingOf('}'), '{');
  assert_int_equal(ClosingOf(']'), '[');
  assert_int_equal(ClosingOf(')'), '(');
}

static void AcceptsEachBracketType(void **state) {
  (void)state;
  assert_true(ValidParenthesis("()"));
  assert_true(ValidParenthesis("[]"));
  assert_true(ValidParenthesis("{}"));
}

static void AcceptsAdjacentAndNestedPairsAndEmptyInput(void **state) {
  (void)state;
  assert_true(ValidParenthesis("()[]{}"));
  assert_true(ValidParenthesis("{[()]}"));
  assert_true(ValidParenthesis("{[()()]([])}{}[({})]"));
  assert_true(ValidParenthesis("(()[{}])({[]})"));
  assert_true(ValidParenthesis(""));
}

static void AcceptsLongInputs(void **state) {
  (void)state;
  char deep[10001];
  memset(deep, '(', 5000);
  memset(deep + 5000, ')', 5000);
  deep[10000] = '\0';
  assert_true(ValidParenthesis(deep));

  char adjacent[10001];
  for (size_t i = 0; i < 10000; i += 2) {
    adjacent[i] = '[';
    adjacent[i + 1] = ']';
  }
  adjacent[10000] = '\0';
  assert_true(ValidParenthesis(adjacent));
}

static void RejectsMismatchedAndIncorrectlyNestedPairs(void **state) {
  (void)state;
  assert_false(ValidParenthesis("(]"));
  assert_false(ValidParenthesis("[(])"));
}

static void RejectsUnmatchedBrackets(void **state) {
  (void)state;
  assert_false(ValidParenthesis("("));
  assert_false(ValidParenthesis(")"));
  assert_false(ValidParenthesis("())"));
  assert_false(ValidParenthesis("(()"));
  assert_false(ValidParenthesis("{[()()]([])}{}[({})]]"));
  assert_false(ValidParenthesis("{[()()]([])}{}[({})]({"));
}

static void RejectsDeepMismatchesAndCrossedNesting(void **state) {
  (void)state;
  assert_false(ValidParenthesis("{[()()]([)]}{}"));
  assert_false(ValidParenthesis("{[({[()]})]}[({[}])]"));

  char deep[10001];
  memset(deep, '(', 4999);
  deep[4999] = '[';
  memset(deep + 5000, ')', 5000);
  deep[10000] = '\0';
  assert_false(ValidParenthesis(deep));
}

int main(void) {
  const struct CMUnitTest tests[] = {
      cmocka_unit_test(RecognizesOnlyOpeningBrackets),
      cmocka_unit_test(MapsClosingBracketsToOpenings),
      cmocka_unit_test(AcceptsEachBracketType),
      cmocka_unit_test(AcceptsAdjacentAndNestedPairsAndEmptyInput),
      cmocka_unit_test(AcceptsLongInputs),
      cmocka_unit_test(RejectsMismatchedAndIncorrectlyNestedPairs),
      cmocka_unit_test(RejectsUnmatchedBrackets),
      cmocka_unit_test(RejectsDeepMismatchesAndCrossedNesting),
  };
  return cmocka_run_group_tests(tests, nullptr, nullptr);
}
