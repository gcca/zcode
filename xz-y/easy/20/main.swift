import XCTest

func isOpening(_ c: UInt8) -> Bool {
    c == UInt8(ascii: "{") || c == UInt8(ascii: "[") || c == UInt8(ascii: "(")
}

func closingOf(_ c: UInt8) -> UInt8 {
    switch c {
    case UInt8(ascii: "}"): return UInt8(ascii: "{")
    case UInt8(ascii: "]"): return UInt8(ascii: "[")
    case UInt8(ascii: ")"): return UInt8(ascii: "(")
    default: preconditionFailure("closingOf requires a closing bracket")
    }
}

func validParenthesis(_ s: String) -> Bool {
    var stack: [UInt8] = []

    for c in s.utf8 {
        if isOpening(c) {
            stack.append(c)
            continue
        }

        let closing = closingOf(c)
        guard stack.last == closing else { return false }
        stack.removeLast()
    }

    return stack.isEmpty
}

final class ValidParenthesisTests: XCTestCase {
    func testIsOpeningRecognizesOnlyOpeningBrackets() {
        for c in "([{".utf8 {
            XCTAssertTrue(isOpening(c))
        }
        for c in ")]}a".utf8 {
            XCTAssertFalse(isOpening(c))
        }
    }

    func testClosingOfMapsClosingBracketsToTheirOpenings() {
        for (closing, opening) in zip("}])".utf8, "{[(".utf8) {
            XCTAssertEqual(closingOf(closing), opening)
        }
    }

    func testAcceptsEachBracketType() {
        for s in ["()", "[]", "{}"] {
            XCTAssertTrue(validParenthesis(s), s)
        }
    }

    func testAcceptsAdjacentAndNestedPairsAndEmptyInput() {
        for s in ["()[]{}", "{[()]}", "{[()()]([])}{}[({})]", "(()[{}])({[]})", ""] {
            XCTAssertTrue(validParenthesis(s), s)
        }
    }

    func testAcceptsLongInputs() {
        let deep = String(repeating: "(", count: 5000) + String(repeating: ")", count: 5000)
        XCTAssertTrue(validParenthesis(deep))
        XCTAssertTrue(validParenthesis(String(repeating: "[]", count: 5000)))
    }

    func testRejectsMismatchedAndIncorrectlyNestedPairs() {
        for s in ["(]", "[(])"] {
            XCTAssertFalse(validParenthesis(s), s)
        }
    }

    func testRejectsUnmatchedBrackets() {
        for s in ["(", ")", "())", "(()", "{[()()]([])}{}[({})]]", "{[()()]([])}{}[({})]({"] {
            XCTAssertFalse(validParenthesis(s), s)
        }
    }

    func testRejectsDeepMismatchesAndCrossedNesting() {
        for s in ["{[()()]([)]}{}", "{[({[()]})]}[({[}])]"] {
            XCTAssertFalse(validParenthesis(s), s)
        }
        let deep = String(repeating: "(", count: 4999) + "[)" + String(repeating: ")", count: 4999)
        XCTAssertFalse(validParenthesis(deep))
    }
}

let suite = ValidParenthesisTests.defaultTestSuite
suite.run()
let result = suite.testRun!
exit(result.executionCount > 0 && result.hasSucceeded ? 0 : 1)
