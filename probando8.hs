import Language.Aspell
import qualified Data.ByteString as DBS
import qualified Data.ByteString.Char8 as BC

import SpellingModule

main= do
	
	aux <- spellCheck ","
		
	if(aux)
		then
		putStrLn ("spellcheck pass")
	else
		putStrLn ("spellcheck not passed")



