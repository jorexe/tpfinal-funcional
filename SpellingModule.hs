module SpellingModule where

import Language.Aspell
import qualified Data.ByteString as DBS
import qualified Data.ByteString.Char8 as BC

bytestringLang = BC.pack "es"

spellCheck::String ->IO Bool
spellCheck string=do
			aux <- spellCheckerWithDictionary bytestringLang
			let 	checker=unpack' aux
			bytestringWords =BC.pack string	
		return (check checker bytestringWords)


unpack'::Either BC.ByteString SpellChecker ->SpellChecker
unpack' (Right checker)=checker
unpack' (Left a)=error "Invalid value"
