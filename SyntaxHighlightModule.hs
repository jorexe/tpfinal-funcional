--ver Syntax.hs para ver la sintaxis del parseo que usa la libreria

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
			processResult parseResult txtBuffer
			putStrLn("texto parseado")

--
processResult::ParseResult HsModule->TextBuffer-> IO()
processResult (ParseOk modul) buffer = do
				putStrLn("ParseOK")
				putStrLn(show modul)
				--processModule modul buffer
processResult (ParseFailed a b) buffer= putStrLn("Parse failed")

--
processModule::HsModule->TextBuffer->IO()
processModule (HsModule loc mod _ _ hsdeclList) buffer=foldIO (process_hsdecl buffer) hsdeclList

--
foldIO:: (a->IO()) -> [a] -> IO()
foldIO fun []=return ()
foldIO fun (x:xs)=do
			fun x
			foldIO fun xs
--
process_hsdecl::TextBuffer-> HsDecl->IO()
process_hsdecl buffer (HsFunBind hsMatchList)=foldIO (process_hsMatch buffer)  hsMatchList
process_hsdecl _ _ =return ()

--Procesa los datos de una función
process_hsMatch::TextBuffer->HsMatch->IO()
process_hsMatch buffer (HsMatch srcLoc hsName _ _ _)=do
						putStrLn ("función: "++ (extractHsName hsName))
						markFunction buffer srcLoc (extractHsName hsName)

--
extractHsName::HsName->String
extractHsName (HsIdent str)=str
extractHsName (HsSymbol str)=str

--se marca declaración de función en el buffer

markFunction::TextBuffer->SrcLoc->String->IO()
markFunction buffer srcLoc name=do
				let line=srcLine srcLoc
				let column=srcColumn srcLoc
				start<-textBufferGetIterAtLine buffer line
				textIterForwardChars start (column -1)
				end<-textIterCopy start
				markFunctionRec buffer name start end ""


--recibe: el buffer, el nombre de la función, iterador que apunta al comienzo del nombre de la funcion en el buffer, iterador que apunta al final del nombre de la función, cadena leida hasta el momento desde start en el buffer(cuando se llega a haber leido todo el nombre de la funcion, se marca dicho nombre sobre el buffer).
markFunctionRec::TextBuffer->String->TextIter->TextIter->String->IO()
markFunctionRec buffer name start end acum=	if(name==acum)
							then do
								tags <- textBufferGetTagTable buffer
								blackItalic <- textTagNew Nothing
								blackItalic <- textTagNew Nothing
								set blackItalic [
      									textTagStyle := StyleItalic,
      									textTagForegroundSet := True,
									textTagForeground := ("black" :: String) 
										]
								textTagTableAdd tags blackItalic
						else do
							--se obtiene el siguiente caracter
							textIterForwardChars end 1
							contents <- textBufferGetText buffer start end False	
							markFunctionRec buffer name start end contents
							
							
