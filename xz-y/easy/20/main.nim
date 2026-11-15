import std/[unittest, strutils]

proc isOpening(c: char): bool = c in {'{', '[', '('}
proc closingOf(c: char): char =
  case c
  of '}': '{'
  of ']': '['
  of ')': '('
  else: raise newException(ValueError, "closingOf requires a closing bracket")

proc validParenthesis(s: string): bool =
  var stack: seq[char] = @[]
  for c in s:
    if isOpening(c):
      stack.add(c)
      continue
    let closing = closingOf(c)
    if stack.len == 0 or stack[^1] != closing:
      return false
    discard stack.pop()
  stack.len == 0

suite "Valid Parentheses":
  test "opening detection":
    for c in "([{": check isOpening(c)
    for c in ")]}a": check not isOpening(c)
  test "closing mappings":
    check closingOf('}') == '{'
    check closingOf(']') == '['
    check closingOf(')') == '('
  test "valid inputs":
    for s in ["()", "[]", "{}", "()[]{}", "{[()]}", "{[()()]([])}{}[({})]",
        "(()[{}])({[]})", ""]:
      checkpoint s
      check validParenthesis(s)
  test "invalid inputs":
    for s in ["(]", "[(])", "(", ")", "())", "(()", "{[()()]([])}{}[({})]]",
        "{[()()]([])}{}[({})]({", "{[()()]([)]}{}", "{[({[()]})]}[({[}])]"]:
      checkpoint s
      check not validParenthesis(s)
  test "long inputs":
    check validParenthesis("(".repeat(5000) & ")".repeat(5000))
    check validParenthesis("[]".repeat(5000))
    check not validParenthesis("(".repeat(4999) & "[)" & ")".repeat(4999))
