module SyntaxHighlightModule where
import Graphics.UI.Gtk
import Control.Monad.IO.Class
import Language.Haskell.Parser
import Language.Haskell.Syntax
--
highlightSyntax:: TextView->IO()
highlightSyntax txtview=do
			txtBuffer <- textViewGetBuffer txtview
			start <- textBufferGetStartIter txtBuffer
			
			end <- textBufferGetEndIter txtBuffer
			
			contents <- textBufferGetText txtBuffer start end False
			
			let parseResult=Language.Haskell.Parser.parseModule contents
			processResult parseResult
			putStrLn("texto parseado")
--
processResult::ParseResult HsModule-> IO()
processResult (ParseOk a) = do
				putStrLn("ParseOK")
				putStrLn(show a)
processResult (ParseFailed a b) = putStrLn("Parse failed")
