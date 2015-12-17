import Language.Aspell
import qualified Data.ByteString as DBS
import qualified Data.ByteString.Char8 as BC


bytestringLang = BC.pack "es"
bytestringWords =BC.pack "hola"

main= do
	aux <- spellCheckerWithDictionary bytestringLang
	--el corrector ortografico queda en aux
	let checker=unpack' aux 
	if(check checker bytestringWords)
		then
		putStrLn ("spellcheck pass")
	else
		putStrLn ("spellcheck not passed")


unpack'::Either BC.ByteString SpellChecker ->SpellChecker
unpack' (Right checker)=checker
unpack' (Left a)=error "Invalid value"
