import Language.Aspell

main= do
	checker <- unpack (spellCheckerWithDictionary "es")
	putStrLn (check checker "asdf")


unpack::Either ByteString SpellChecker-> SpellChecker
unpack (Right checker)=checker
unpack (Left str)=error "invalid language"

