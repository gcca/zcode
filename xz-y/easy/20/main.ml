let is_opening c = c = '{' || c = '[' || c = '('

let closing_of = function
  | '}' -> '{'
  | ']' -> '['
  | ')' -> '('
  | _ -> invalid_arg "closing_of requires a closing bracket"

let valid_parenthesis s =
  let stack = Stack.create () in
  let length = String.length s in
  let rec scan i =
    if i = length then Stack.is_empty stack
    else
      let c = s.[i] in
      if is_opening c then (
        Stack.push c stack;
        scan (i + 1))
      else
        let closing = closing_of c in
        if Stack.is_empty stack || Stack.top stack <> closing then false
        else (
          ignore (Stack.pop stack);
          scan (i + 1))
  in
  scan 0

let opening_tests =
  List.map
    (fun (c, expected) ->
      Alcotest.test_case (Printf.sprintf "%C" c) `Quick (fun () ->
          Alcotest.(check bool) "is_opening" expected (is_opening c)))
    [
      ('(', true);
      ('[', true);
      ('{', true);
      (')', false);
      (']', false);
      ('}', false);
      ('a', false);
    ]

let closing_tests =
  List.map
    (fun (c, expected) ->
      Alcotest.test_case (Printf.sprintf "%C" c) `Quick (fun () ->
          Alcotest.(check char) "closing_of" expected (closing_of c)))
    [ ('}', '{'); (']', '['); (')', '(') ]

let parenthesis_tests =
  List.map
    (fun (name, input, expected) ->
      Alcotest.test_case name `Quick (fun () ->
          Alcotest.(check bool) name expected (valid_parenthesis input)))
    [
      ("round pair", "()", true);
      ("square pair", "[]", true);
      ("curly pair", "{}", true);
      ("adjacent pairs", "()[]{}", true);
      ("nested pairs", "{[()]}", true);
      ("mixed groups", "{[()()]([])}{}[({})]", true);
      ("adjacent nested groups", "(()[{}])({[]})", true);
      ("deep nesting", String.make 5000 '(' ^ String.make 5000 ')', true);
      ( "long adjacent pairs",
        String.init 10000 (fun i -> if i mod 2 = 0 then '[' else ']'),
        true );
      ("mismatched pair", "(]", false);
      ("crossed pairs", "[(])", false);
      ("unmatched opening", "(", false);
      ("unmatched closing", ")", false);
      ("extra closing", "())", false);
      ("extra opening", "(()", false);
      ("extra closing after groups", "{[()()]([])}{}[({})]]", false);
      ("extra openings after groups", "{[()()]([])}{}[({})]({", false);
      ("crossed inner pairs", "{[()()]([)]}{}", false);
      ("mismatch after valid group", "{[({[()]})]}[({[}])]", false);
      ( "deep mismatch",
        String.make 4999 '(' ^ "[)" ^ String.make 4999 ')',
        false );
      ("empty input", "", true);
    ]

let () =
  Alcotest.run ~verbose:true ~log_dir:".cache/alcotest/20" "Valid Parentheses"
    [
      ("is_opening", opening_tests);
      ("closing_of", closing_tests);
      ("valid_parenthesis", parenthesis_tests);
    ]
