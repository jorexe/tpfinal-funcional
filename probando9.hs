import Language.Aspell
import Graphics.UI.Gtk
import Control.Monad.IO.Class
import Language.Aspell
import qualified Language.Aspell.Options as LAO
import qualified Data.ByteString as DBS
import qualified Data.ByteString.Char8 as BC
import qualified Data.Char as DC
bytestringLang = BC.pack "es"


main= do
	--aux <- spellCheckerWithDictionary bytestringLang
	aux <-spellCheckerWithOptions [(LAO.Dictionary bytestringLang),LAO.Encoding LAO.Latin1]
	let string="dia"
	let checker = unpack' aux
	--en la siguiente linea tiene que estar el error	
	let bytestringInput =BC.pack string
	--se termina llamando al corrector ortografico	
	let bytestring2=DBS.pack [100,237,97]
	putStrLn(show bytestring2)
	let correct = check checker bytestring2
		
	if(correct)
		then
		putStrLn ("spellcheck pass")
	else
		putStrLn ("spellcheck not passed")


	suggestions<-suggest checker bytestringInput
	putStrLn ("sugerencias" ++ show suggestions)
	
unpack'::Either BC.ByteString SpellChecker ->SpellChecker
unpack' (Right checker)=checker
unpack' (Left a)=error "Invalid value"



