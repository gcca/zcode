package main

import (
	"regexp"
	"strings"
	"testing"
)

func IsOpening(c byte) bool {
	return c == '{' || c == '[' || c == '('
}

func main() {
	testing.Main(regexp.MatchString, []testing.InternalTest{
		{Name: "TestIsOpening", F: TestIsOpening},
		{Name: "TestClosingOf", F: TestClosingOf},
		{Name: "TestValidParenthesis", F: TestValidParenthesis},
	}, nil, nil)
}

func ClosingOf(c byte) byte {
	switch c {
	case '}':
		return '{'
	case ']':
		return '['
	case ')':
		return '('
	default:
		panic("ClosingOf requires a closing bracket")
	}
}

func ValidParenthesis(s string) bool {
	var stack []byte

	for i := 0; i < len(s); i++ {
		c := s[i]
		if IsOpening(c) {
			stack = append(stack, c)
			continue
		}

		closing := ClosingOf(c)
		if len(stack) == 0 || stack[len(stack)-1] != closing {
			return false
		}
		stack = stack[:len(stack)-1]
	}

	return len(stack) == 0
}

func TestIsOpening(t *testing.T) {
	for _, tc := range []struct {
		input byte
		want  bool
	}{
		{'(', true}, {'[', true}, {'{', true},
		{')', false}, {']', false}, {'}', false}, {'a', false},
	} {
		t.Run(string(tc.input), func(t *testing.T) {
			if got := IsOpening(tc.input); got != tc.want {
				t.Errorf("IsOpening(%q) = %t; want %t", tc.input, got, tc.want)
			}
		})
	}
}

func TestClosingOf(t *testing.T) {
	for _, tc := range []struct {
		input byte
		want  byte
	}{
		{'}', '{'}, {']', '['}, {')', '('},
	} {
		t.Run(string(tc.input), func(t *testing.T) {
			if got := ClosingOf(tc.input); got != tc.want {
				t.Errorf("ClosingOf(%q) = %q; want %q", tc.input, got, tc.want)
			}
		})
	}
}

func TestValidParenthesis(t *testing.T) {
	for _, tc := range []struct {
		name  string
		input string
		want  bool
	}{
		{"round pair", "()", true},
		{"square pair", "[]", true},
		{"curly pair", "{}", true},
		{"adjacent pairs", "()[]{}", true},
		{"nested pairs", "{[()]}", true},
		{"mixed groups", "{[()()]([])}{}[({})]", true},
		{"adjacent nested groups", "(()[{}])({[]})", true},
		{"deep nesting", strings.Repeat("(", 5000) + strings.Repeat(")", 5000), true},
		{"long adjacent pairs", strings.Repeat("[]", 5000), true},
		{"mismatched pair", "(]", false},
		{"crossed pairs", "[(])", false},
		{"unmatched opening", "(", false},
		{"unmatched closing", ")", false},
		{"extra closing", "())", false},
		{"extra opening", "(()", false},
		{"extra closing after groups", "{[()()]([])}{}[({})]]", false},
		{"extra openings after groups", "{[()()]([])}{}[({})]({", false},
		{"crossed inner pairs", "{[()()]([)]}{}", false},
		{"mismatch after valid group", "{[({[()]})]}[({[}])]", false},
		{"deep mismatch", strings.Repeat("(", 4999) + "[)" + strings.Repeat(")", 4999), false},
		{"empty input", "", true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if got := ValidParenthesis(tc.input); got != tc.want {
				t.Errorf("ValidParenthesis(%q) = %t; want %t", tc.input, got, tc.want)
			}
		})
	}
}
