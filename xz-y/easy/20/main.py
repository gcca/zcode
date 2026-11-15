import unittest


def is_opening(c: str) -> bool:
    return c in ("{", "[", "(")


def closing_of(c: str) -> str:
    if c == "}":
        return "{"
    if c == "]":
        return "["
    if c == ")":
        return "("
    raise ValueError("closing_of requires a closing bracket")


def valid_parenthesis(s: str) -> bool:
    stack = []
    for c in s:
        if is_opening(c):
            stack.append(c)
            continue

        closing = closing_of(c)
        if not stack or stack[-1] != closing:
            return False
        stack.pop()

    return not stack


class IsOpeningTest(unittest.TestCase):
    def test_recognizes_only_opening_brackets(self):
        for c in "([{":
            with self.subTest(c=c):
                self.assertTrue(is_opening(c))
        for c in ")]}a":
            with self.subTest(c=c):
                self.assertFalse(is_opening(c))


class ClosingOfTest(unittest.TestCase):
    def test_maps_closing_brackets_to_openings(self):
        for c, opening in [("}", "{"), ("]", "["), (")", "(")]:
            with self.subTest(c=c):
                self.assertEqual(closing_of(c), opening)

    def test_rejects_unsupported_characters(self):
        with self.assertRaises(ValueError):
            closing_of("a")


class ValidParenthesisTest(unittest.TestCase):
    def test_accepts_each_bracket_type(self):
        for s in ["()", "[]", "{}"]:
            with self.subTest(s=s):
                self.assertTrue(valid_parenthesis(s))

    def test_accepts_adjacent_and_nested_pairs(self):
        for s in ["()[]{}", "{[()]}", "{[()()]([])}{}[({})]", "(()[{}])({[]})"]:
            with self.subTest(s=s):
                self.assertTrue(valid_parenthesis(s))

    def test_accepts_empty_input(self):
        self.assertTrue(valid_parenthesis(""))

    def test_accepts_long_inputs(self):
        for name, s in [
            ("deep nesting", "(" * 5000 + ")" * 5000),
            ("adjacent pairs", "[]" * 5000),
        ]:
            with self.subTest(name=name):
                self.assertTrue(valid_parenthesis(s))

    def test_rejects_mismatched_and_incorrectly_nested_pairs(self):
        for s in ["(]", "[(])"]:
            with self.subTest(s=s):
                self.assertFalse(valid_parenthesis(s))

    def test_rejects_unmatched_brackets(self):
        for s in [
            "(", ")", "())", "(()",
            "{[()()]([])}{}[({})]]", "{[()()]([])}{}[({})]({",
        ]:
            with self.subTest(s=s):
                self.assertFalse(valid_parenthesis(s))

    def test_rejects_deep_mismatches_and_crossed_nesting(self):
        for name, s in [
            ("crossed inner pairs", "{[()()]([)]}{}"),
            ("mismatch after valid group", "{[({[()]})]}[({[}])]"),
            ("deep mismatch", "(" * 4999 + "[)" + ")" * 4999),
        ]:
            with self.subTest(name=name):
                self.assertFalse(valid_parenthesis(s))


if __name__ == "__main__":
    unittest.main(verbosity=2)
