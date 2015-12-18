module SpellingModule where

import Graphics.UI.Gtk
import Control.Monad.IO.Class
import Language.Aspell
import qualified Data.ByteString as DBS
import qualified Data.ByteString.Char8 as BC
import qualified Data.Char as DC
bytestringLang = BC.pack "es"
--
markSpelling:: TextView->IO()
markSpelling txtview=do
			txtBuffer <- textViewGetBuffer txtview
			start <- textBufferGetStartIter txtBuffer
			
			end <- textBufferGetEndIter txtBuffer
			contents <- textBufferGetText txtBuffer start end False	
			tags <- textBufferGetTagTable txtBuffer
			kindaRedItalic <- textTagNew Nothing
			set kindaRedItalic [
      					textTagStyle := StyleItalic,
      					textTagForegroundSet := True,
					textTagForeground := ("red" :: String) 
					]
			textTagTableAdd tags kindaRedItalic
			end' <- textIterCopy start
			markSpellingRec contents start end' "" txtBuffer kindaRedItalic
--

markSpellingRec:: [Char] -> TextIter ->TextIter ->String ->TextBuffer->TextTag->IO()
markSpellingRec [] start end acum txtbuffer tag=return ()
markSpellingRec (x:xs) start end acum txtbuffer tag=do
					startOffset'<-textIterGetOffset start
					endOffset'<-textIterGetOffset end
					putStrLn ("start"++(show startOffset')++" end"++(show endOffset') )					
					if (DC.isSpace x)
						then
							do
							spellPass<-spellCheck acum
							if (not spellPass)
							--hay error de ortografia
								then do
									textIterBackwardChars end 1
									auxStart <-textIterCopy end
									startOffset<-textIterGetOffset start
									endOffset<-textIterGetOffset end
									putStrLn ("start"++(show startOffset)++" end"++(show endOffset) ++" error ortografico: "++acum)
									--se marca el error
									textBufferApplyTag txtbuffer tag start end
									textIterForwardChars end 2
									
									markSpellingRec xs (auxStart) (end) "" txtbuffer tag
								
								else do
									textIterForwardChars end 1
									auxStart <-textIterCopy end
									markSpellingRec xs auxStart end "" txtbuffer tag
						else do
							textIterForwardChars end 1
							markSpellingRec xs start end (acum ++ [x]) txtbuffer tag
							


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
