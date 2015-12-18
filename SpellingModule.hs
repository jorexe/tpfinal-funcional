module SpellingModule where

import Language.Aspell
import qualified Data.ByteString as DBS
import qualified Data.ByteString.Char8 as BC

bytestringLang = BC.pack "es"
--
markSpelling:: TextView->IO()
markSpelling txtview=do
			txtBuffer <- textViewGetBuffer txtView
			start <- textBufferGetStartIter txtBuffer
			end <- textBufferGetEndIter txtBuffer
			contents <- textBufferGetText txtBuffer start end False	
			markSpellingRec contents start end "" txtBuffer
--

markSpellingRec:: [Char] -> TextIter ->TextIter ->String ->TextBuffer->IO()
markSpellingRec [] start end acum txtbuffer=return IO()
markSpellingRec (x:xs) start end acum txtbuffer= if (isSpace x)
						then
							if not(speelCheck acum)
							--hay error de ortografia
								then do
									textIterBackwardChars end 1
									textBufferApplyTag txtbuffer kindaRedItalic start end
									textIterForwardChars end 2
									auxStart <-textIterCopy end
									markSpellingRec xs (auxStart) (end) "" txtbuffer
								
								else do
									textIterForwardChars end 1
									auxStart <-textIterCopy end
									markSpellingRec xs auxStart end "" txtbuffer
						else do
							textIterForwardChars end 1
							markSpellingRec xs start end (acum ++ x) txtbuffer
							


--
spellCheck::String ->IO Bool
spellCheck string=do
			aux <- spellCheckerWithDictionary bytestringLang
			let 	checker = unpack' aux
			let 	bytestringWords =BC.pack string	
			return (check checker bytestringWords)


unpack'::Either BC.ByteString SpellChecker ->SpellChecker
unpack' (Right checker)=checker
unpack' (Left a)=error "Invalid value"
