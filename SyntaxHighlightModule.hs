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
			putStrLn("[highlightSyntax]texto parseado")

--
processResult::ParseResult HsModule->TextBuffer-> IO()
processResult (ParseOk modul) buffer = do
				putStrLn("[highlightSyntax] ParseOK")
				putStrLn(show modul)
				processModule modul buffer

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
process_hsdecl buffer (HsTypeSig loc hsName _ )=foldIO (process_fun_declaration buffer loc ) hsName
process_hsdecl _ _ =return ()

--procesa la declaración de tipos de la función(no es la función en sí con lo que devuelve)
process_fun_declaration:: TextBuffer->SrcLoc->HsName->IO()
process_fun_declaration buffer loc hsName=do
						tag<-blackItalic
						markElement buffer loc (extractHsName hsName) tag


--Procesa los datos de una función
process_hsMatch::TextBuffer->HsMatch->IO()
process_hsMatch buffer (HsMatch srcLoc hsName _ _ _)=do
						tag<-blackItalic
						markElement buffer srcLoc (extractHsName hsName) tag

--
extractHsName::HsName->String
extractHsName (HsIdent str)=str
extractHsName (HsSymbol str)=str

--se marca declaración de función en el buffer

markElement::TextBuffer->SrcLoc->String->TextTag->IO()
markElement buffer srcLoc name tag=do
				let line=(srcLine srcLoc)-1
				let column=srcColumn srcLoc
				start<-textBufferGetIterAtLine buffer line
				textIterForwardChars start (column -1)
				end<-textIterCopy start
				putStrLn ("Elemento: "++name++" linea:" ++(show line))


				tags <- textBufferGetTagTable buffer
						
				textTagTableAdd tags tag
				markElementRec buffer name start end "" tag



--estilo de letra color verde
greenTag::IO TextTag
greenTag=do
	aux<- textTagNew Nothing
	set aux [
      		textTagForegroundSet := True,
		textTagForeground := ("green" :: String) 
		]
	return aux

--estilo de letra color negro con cursiva
blackItalic::IO TextTag
blackItalic=do
			aux<- textTagNew Nothing
			set aux [
      				textTagStyle := StyleItalic,
      				textTagForegroundSet := True,
				textTagForeground := ("black" :: String) 
				]
			return aux

--recibe: el buffer, el nombre del elemento, iterador que apunta al comienzo del nombre del elemento en el buffer, iterador que apunta al final del nombre del elemento , cadena leida hasta el momento desde start en el buffer(cuando se llega a haber leido todo el nombre del elemento, se marca dicho nombre sobre el buffer).
markElementRec::TextBuffer->String->TextIter->TextIter->String->TextTag->IO()
markElementRec buffer name start end acum tag=do
						startOffset<-textIterGetOffset start
						endOffset<-textIterGetOffset end
						top<-textBufferGetEndIter buffer
						topOffset<-textIterGetOffset top
						putStrLn ("start"++(show startOffset)++" end"++(show endOffset)++".Limit:"++(show topOffset)) 
						if((compare name acum)== EQ)
							then do
								
								startOffset<-textIterGetOffset start
								endOffset<-textIterGetOffset end
								putStrLn ("start"++(show startOffset)++" end"++(show endOffset) ++" elemento: "++name) 
								
								textBufferApplyTag buffer tag start end
	
						else do
							--se obtiene el siguiente caracter
							textIterForwardChars end 1
							contents <- textBufferGetText buffer start end False	
							markElementRec buffer name start end contents tag
							
							
