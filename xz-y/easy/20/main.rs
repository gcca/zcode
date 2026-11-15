fn is_opening(c: u8) -> bool {
    c == b'{' || c == b'[' || c == b'('
}

fn closing_of(c: u8) -> u8 {
    match c {
        b'}' => b'{',
        b']' => b'[',
        b')' => b'(',
        _ => unreachable!(),
    }
}

fn valid_parenthesis(s: &str) -> bool {
    let mut stack = Vec::new();

    for c in s.bytes() {
        if is_opening(c) {
            stack.push(c);
            continue;
        }

        let closing = closing_of(c);
        if stack.last() != Some(&closing) {
            return false;
        }
        stack.pop();
    }

    stack.is_empty()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn is_opening_recognizes_only_opening_brackets() {
        for c in [b'(', b'[', b'{'] {
            assert!(is_opening(c));
        }
        for c in [b')', b']', b'}', b'a'] {
            assert!(!is_opening(c));
        }
    }

    #[test]
    fn accepts_each_bracket_type() {
        assert!(valid_parenthesis("()"));
        assert!(valid_parenthesis("[]"));
        assert!(valid_parenthesis("{}"));
    }

    #[test]
    fn accepts_adjacent_and_nested_pairs() {
        assert!(valid_parenthesis("()[]{}"));
        assert!(valid_parenthesis("{[()]}"));
        assert!(valid_parenthesis("{[()()]([])}{}[({})]"));
        assert!(valid_parenthesis("(()[{}])({[]})"));
    }

    #[test]
    fn accepts_long_inputs() {
        let deeply_nested = "(".repeat(5000) + &")".repeat(5000);
        assert!(valid_parenthesis(&deeply_nested));

        let adjacent = "[]".repeat(5000);
        assert!(valid_parenthesis(&adjacent));
    }

    #[test]
    fn rejects_mismatched_and_incorrectly_nested_pairs() {
        assert!(!valid_parenthesis("(]"));
        assert!(!valid_parenthesis("[(])"));
    }

    #[test]
    fn rejects_unmatched_brackets() {
        assert!(!valid_parenthesis("("));
        assert!(!valid_parenthesis(")"));
        assert!(!valid_parenthesis("())"));
        assert!(!valid_parenthesis("(()"));
        assert!(!valid_parenthesis("{[()()]([])}{}[({})]]"));
        assert!(!valid_parenthesis("{[()()]([])}{}[({})]({"));
    }

    #[test]
    fn rejects_deep_mismatches_and_crossed_nesting() {
        assert!(!valid_parenthesis("{[()()]([)]}{}"));
        assert!(!valid_parenthesis("{[({[()]})]}[({[}])]"));

        let deep = "(".repeat(4999) + "[" + ")" + &")".repeat(4999);
        assert!(!valid_parenthesis(&deep));
    }
}
