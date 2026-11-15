const { test } = require('node:test');
const assert = require('node:assert/strict');

function isOpening(c) { return c === '{' || c === '[' || c === '('; }
function closingOf(c) {
  switch (c) {
    case '}': return '{';
    case ']': return '[';
    case ')': return '(';
    default: throw new Error('closingOf requires a closing bracket');
  }
}
function validParenthesis(s) {
  const stack = [];
  for (const c of s) {
    if (isOpening(c)) { stack.push(c); continue; }
    const closing = closingOf(c);
    if (stack.length === 0 || stack[stack.length - 1] !== closing) return false;
    stack.pop();
  }
  return stack.length === 0;
}

test('opening detection', () => {
  for (const c of '([{') assert.equal(isOpening(c), true);
  for (const c of ')]}a') assert.equal(isOpening(c), false);
});
test('closing mappings', () => {
  assert.equal(closingOf('}'), '{');
  assert.equal(closingOf(']'), '[');
  assert.equal(closingOf(')'), '(');
});
test("valid ()", () => assert.equal(validParenthesis("()"), true));
test("valid []", () => assert.equal(validParenthesis("[]"), true));
test("valid {}", () => assert.equal(validParenthesis("{}"), true));
test("valid ()[]{}", () => assert.equal(validParenthesis("()[]{}"), true));
test("valid {[()]}", () => assert.equal(validParenthesis("{[()]}"), true));
test("valid {[()()]([])}{}[({})]", () => assert.equal(validParenthesis("{[()()]([])}{}[({})]"), true));
test("valid (()[{}])({[]})", () => assert.equal(validParenthesis("(()[{}])({[]})"), true));
test("valid ", () => assert.equal(validParenthesis(""), true));
test("invalid (]", () => assert.equal(validParenthesis("(]"), false));
test("invalid [(])", () => assert.equal(validParenthesis("[(])"), false));
test("invalid (", () => assert.equal(validParenthesis("("), false));
test("invalid )", () => assert.equal(validParenthesis(")"), false));
test("invalid ())", () => assert.equal(validParenthesis("())"), false));
test("invalid (()", () => assert.equal(validParenthesis("(()"), false));
test("invalid {[()()]([])}{}[({})]]", () => assert.equal(validParenthesis("{[()()]([])}{}[({})]]"), false));
test("invalid {[()()]([])}{}[({})]({", () => assert.equal(validParenthesis("{[()()]([])}{}[({})]({"), false));
test("invalid {[()()]([)]}{}", () => assert.equal(validParenthesis("{[()()]([)]}{}"), false));
test("invalid {[({[()]})]}[({[}])]", () => assert.equal(validParenthesis("{[({[()]})]}[({[}])]"), false));
test('long inputs', () => {
  assert.equal(validParenthesis('('.repeat(5000) + ')'.repeat(5000)), true);
  assert.equal(validParenthesis('[]'.repeat(5000)), true);
  assert.equal(validParenthesis('('.repeat(4999) + '[)' + ')'.repeat(4999)), false);
});
