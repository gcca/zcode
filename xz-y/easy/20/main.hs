import Test.Hspec

isOpening :: Char -> Bool
isOpening c = c `elem` "{[("

closingOf :: Char -> Char
closingOf '}' = '{'
closingOf ']' = '['
closingOf ')' = '('
closingOf _ = error "closingOf requires a closing bracket"

validParenthesis :: String -> Bool
validParenthesis = scan []
  where
    scan stack [] = null stack
    scan stack (c:rest)
      | isOpening c = scan (c:stack) rest
      | otherwise = case stack of
          opening:tailStack | opening == closingOf c -> scan tailStack rest
          _ -> False

main :: IO ()
main = hspec $ do
  describe "helpers" $ do
    it "detects openings" $ do
      map isOpening "([{" `shouldBe` [True, True, True]
      map isOpening ")]}a" `shouldBe` [False, False, False, False]
    it "maps closings" $ map closingOf "}])" `shouldBe` "{[("
  describe "valid inputs" $
    mapM_ (\s -> it (show s) $ validParenthesis s `shouldBe` True)
      ["()", "[]", "{}", "()[]{}", "{[()]}", "{[()()]([])}{}[({})]", "(()[{}])({[]})", ""]
  describe "invalid inputs" $
    mapM_ (\s -> it (show s) $ validParenthesis s `shouldBe` False)
      ["(]", "[(])", "(", ")", "())", "(()", "{[()()]([])}{}[({})]]", "{[()()]([])}{}[({})]({", "{[()()]([)]}{}", "{[({[()]})]}[({[}])]"]
  describe "long inputs" $ do
    it "accepts deep nesting" $
      validParenthesis (replicate 5000 '(' ++ replicate 5000 ')') `shouldBe` True
    it "accepts adjacent pairs" $
      validParenthesis (concat (replicate 5000 "[]")) `shouldBe` True
    it "rejects a deep mismatch" $
      validParenthesis (replicate 4999 '(' ++ "[)" ++ replicate 4999 ')') `shouldBe` False
