; Valid Parentheses: each rule advances one scan or produces a result.
(deftemplate scan
  (slot text (type STRING))
  (slot position (type INTEGER) (default 1))
  (slot depth (type INTEGER) (default 0)))

; Separate stack facts avoid copying a growing multifield on every push.
(deftemplate stack-entry
  (slot depth (type INTEGER))
  (slot bracket (type STRING)))

(deftemplate scan-result
  (slot valid (allowed-symbols TRUE FALSE)))

(deffunction is-opening (?c)
  (return (or (eq ?c "(") (eq ?c "[") (eq ?c "{"))))

(deffunction closing-of (?c)
  (switch ?c
    (case "}" then (return "{"))
    (case "]" then (return "["))
    (case ")" then (return "("))
    (default
      (printout stderr "closing-of requires a closing bracket" crlf)
      (exit 1))))

(defrule push-opening
  ?state <- (scan (text ?s) (position ?i) (depth ?depth))
  (test (<= ?i (str-length ?s)))
  (test (is-opening (sub-string ?i ?i ?s)))
  =>
  (assert (stack-entry (depth (+ ?depth 1)) (bracket (sub-string ?i ?i ?s))))
  (modify ?state (position (+ ?i 1)) (depth (+ ?depth 1))))

(defrule pop-matching-closing
  ?state <- (scan (text ?s) (position ?i) (depth ?depth))
  (test (<= ?i (str-length ?s)))
  (test (not (is-opening (sub-string ?i ?i ?s))))
  ?top <- (stack-entry (depth ?depth) (bracket ?opening))
  (test (eq ?opening (closing-of (sub-string ?i ?i ?s))))
  =>
  (retract ?top)
  (modify ?state (position (+ ?i 1)) (depth (- ?depth 1))))

(defrule reject-mismatched-closing
  ?state <- (scan (text ?s) (position ?i) (depth ?depth))
  (test (<= ?i (str-length ?s)))
  (test (not (is-opening (sub-string ?i ?i ?s))))
  (stack-entry (depth ?depth) (bracket ?opening))
  (test (neq ?opening (closing-of (sub-string ?i ?i ?s))))
  =>
  (retract ?state)
  (assert (scan-result (valid FALSE))))

(defrule reject-unmatched-closing
  ?state <- (scan (text ?s) (position ?i) (depth 0))
  (test (<= ?i (str-length ?s)))
  (test (not (is-opening (sub-string ?i ?i ?s))))
  =>
  (retract ?state)
  (assert (scan-result (valid FALSE))))

(defrule accept-completed-scan
  ?state <- (scan (text ?s) (position ?i) (depth 0))
  (test (> ?i (str-length ?s)))
  =>
  (retract ?state)
  (assert (scan-result (valid TRUE))))

(defrule reject-unmatched-openings
  ?state <- (scan (text ?s) (position ?i) (depth ?depth&:(> ?depth 0)))
  (test (> ?i (str-length ?s)))
  =>
  (retract ?state)
  (assert (scan-result (valid FALSE))))

; Called from the batch command level, outside rule execution.
(deffunction valid-parenthesis (?s)
  (do-for-all-facts ((?f scan)) TRUE (retract ?f))
  (do-for-all-facts ((?f stack-entry)) TRUE (retract ?f))
  (do-for-all-facts ((?f scan-result)) TRUE (retract ?f))
  (assert (scan (text ?s)))
  (run)
  (bind ?results (find-all-facts ((?r scan-result)) TRUE))
  (if (neq (length$ ?results) 1) then
    (printout stderr "Scan did not produce exactly one result" crlf)
    (exit 1))
  (return (fact-slot-value (nth$ 1 ?results) valid)))

(defglobal ?*tests* = 0 ?*failures* = 0)

(deffunction expect (?name ?expected ?actual)
  (bind ?*tests* (+ ?*tests* 1))
  (if (eq ?actual ?expected) then
    (printout t "PASS: " ?name crlf)
   else
    (bind ?*failures* (+ ?*failures* 1))
    (printout t "FAIL: " ?name " expected " ?expected " got " ?actual crlf)))

(deffunction repeat-text (?text ?count)
  (bind ?result "")
  (loop-for-count (?i 1 ?count)
    (bind ?result (str-cat ?result ?text)))
  (return ?result))

(deffunction run-tests ()
  (progn$ (?c (create$ "(" "[" "{"))
    (expect (str-cat "opening " ?c) TRUE (is-opening ?c)))
  (progn$ (?c (create$ ")" "]" "}" "a"))
    (expect (str-cat "not opening " ?c) FALSE (is-opening ?c)))
  (expect "closing curly" "{" (closing-of "}"))
  (expect "closing square" "[" (closing-of "]"))
  (expect "closing round" "(" (closing-of ")"))
  (expect "valid 0" TRUE (valid-parenthesis "()"))
  (expect "valid 1" TRUE (valid-parenthesis "[]"))
  (expect "valid 2" TRUE (valid-parenthesis "{}"))
  (expect "valid 3" TRUE (valid-parenthesis "()[]{}"))
  (expect "valid 4" TRUE (valid-parenthesis "{[()]}"))
  (expect "valid 5" TRUE (valid-parenthesis "{[()()]([])}{}[({})]"))
  (expect "valid 6" TRUE (valid-parenthesis "(()[{}])({[]})"))
  (expect "valid 7" TRUE (valid-parenthesis ""))
  (expect "invalid 0" FALSE (valid-parenthesis "(]"))
  (expect "invalid 1" FALSE (valid-parenthesis "[(])"))
  (expect "invalid 2" FALSE (valid-parenthesis "("))
  (expect "invalid 3" FALSE (valid-parenthesis ")"))
  (expect "invalid 4" FALSE (valid-parenthesis "())"))
  (expect "invalid 5" FALSE (valid-parenthesis "(()"))
  (expect "invalid 6" FALSE (valid-parenthesis "{[()()]([])}{}[({})]]"))
  (expect "invalid 7" FALSE (valid-parenthesis "{[()()]([])}{}[({})]({"))
  (expect "invalid 8" FALSE (valid-parenthesis "{[()()]([)]}{}"))
  (expect "invalid 9" FALSE (valid-parenthesis "{[({[()]})]}[({[}])]"))
  (expect "deep nesting" TRUE
    (valid-parenthesis (str-cat (repeat-text "(" 5000) (repeat-text ")" 5000))))
  (expect "long adjacent pairs" TRUE
    (valid-parenthesis (repeat-text "[]" 5000)))
  (expect "deep mismatch" FALSE
    (valid-parenthesis (str-cat (repeat-text "(" 4999) "[)" (repeat-text ")" 4999))))
  (expect "state reset after mismatch" TRUE (valid-parenthesis "[]"))
  (printout t ?*tests* " tests, " ?*failures* " failures" crlf)
  (exit (if (= ?*failures* 0) then 0 else 1)))

(reset)
(run-tests)
