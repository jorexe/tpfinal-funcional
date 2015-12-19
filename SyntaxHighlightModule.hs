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
processResult (ParseOk module) = do
				putStrLn("ParseOK")
				putStrLn(show a)
				processModule module
processResult (ParseFailed a b) = putStrLn("Parse failed")

--
processModule::HsModule->IO()
processModule HsModule loc mod _ _ hsdeclList=foldIO process_hsdecl hsdecList

--
foldIO:: (a->IO()) -> [a] -> IO()
foldIO fun []=return ()
foldIO fun (x:xs)=do
			fun x
			foldIO fun xs
--
process_hsdecl:: HsDecl->IO()
process_hsdecl (HsFunBind hsMatchList)=foldIO process_hsMatch  hsMatchList
process_hsdecl _ =return ()

--Procesa los datos de una función
process_hsMatch::HsMatch->IO()
process_hsMatch (HsMatch 
