(defun is-opening (c)
  (or (char= c #\{) (char= c #\[) (char= c #\()))

(defun closing-of (c)
  (case c
    (#\} #\{)
    (#\] #\[)
    (#\) #\()
    (otherwise (error "closing-of requires a closing bracket: ~S" c))))

(defun valid-parenthesis (s)
  (let ((stack nil))
    (loop for c across s do
      (if (is-opening c)
          (push c stack)
          (let ((closing (closing-of c)))
            (unless (eql (car stack) closing)
              (return-from valid-parenthesis nil))
            (pop stack))))
    (null stack)))

(defvar *test-count* 0)
(defvar *assertion-count* 0)

(defun check (condition description)
  (incf *assertion-count*)
  (unless condition
    (error "Assertion failed: ~A" description)))

(defmacro test-group (name &body body)
  `(progn
     ,@body
     (incf *test-count*)
     (format t "PASS ~A~%" ,name)))

(defun run-tests ()
  (let ((*test-count* 0)
        (*assertion-count* 0))
    (test-group "is-opening recognizes only opening brackets"
      (loop for c across "([{"
            do (check (is-opening c) (format nil "opening ~S" c)))
      (loop for c across ")]}a"
            do (check (not (is-opening c)) (format nil "non-opening ~S" c))))

    (test-group "closing-of maps closing brackets to their openings"
      (loop for closing across "}])"
            for opening across "{[("
            do (check (eql (closing-of closing) opening)
                      (format nil "mapping ~S to ~S" closing opening))))

    (test-group "closing-of rejects unsupported characters"
      (dolist (c '(#\( #\[ #\{ #\a #\Space))
        (check (handler-case (progn (closing-of c) nil)
                 (error () t))
               (format nil "invalid closing ~S" c))))

    (test-group "accepts each bracket type"
      (dolist (s '("()" "[]" "{}"))
        (check (valid-parenthesis s) s)))

    (test-group "accepts adjacent and nested pairs and empty input"
      (dolist (s '("()[]{}" "{[()]}" "{[()()]([])}{}[({})]" "(()[{}])({[]})" ""))
        (check (valid-parenthesis s) s)))

    (test-group "accepts long inputs"
      (check (valid-parenthesis
              (concatenate 'string
                           (make-string 5000 :initial-element #\()
                           (make-string 5000 :initial-element #\))))
             "5000 nested pairs")
      (check (valid-parenthesis
              (with-output-to-string (out)
                (dotimes (i 5000) (write-string "[]" out))))
             "5000 adjacent pairs"))

    (test-group "rejects mismatched and incorrectly nested pairs"
      (dolist (s '("(]" "[(])"))
        (check (not (valid-parenthesis s)) s)))

    (test-group "rejects unmatched brackets"
      (dolist (s '("(" ")" "())" "(()" "{[()()]([])}{}[({})]]" "{[()()]([])}{}[({})]({"))
        (check (not (valid-parenthesis s)) s)))

    (test-group "rejects deep mismatches and crossed nesting"
      (dolist (s '("{[()()]([)]}{}" "{[({[()]})]}[({[}])]"))
        (check (not (valid-parenthesis s)) s))
      (check (not (valid-parenthesis
                   (concatenate 'string
                                (make-string 4999 :initial-element #\()
                                "[)"
                                (make-string 4999 :initial-element #\)))))
             "mismatch at depth 5000"))

    (format t "~%~D tests, ~D assertions, 0 failures~%"
            *test-count* *assertion-count*)))

(run-tests)
