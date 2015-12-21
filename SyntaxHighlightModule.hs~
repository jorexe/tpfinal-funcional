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
process_hsdecl buffer (HsTypeSig loc hsName hsQualType)= do 
		foldIO (process_fun_declaration buffer loc ) hsName
		process_hsQualType buffer hsQualType loc						
process_hsdecl _ _ =return ()

--
process_hsQualType::TextBuffer->HsQualType->SrcLoc->IO()
process_hsQualType buffer (HsQualType _ hs_type) srcLoc=process_hsType buffer hs_type srcLoc

--
process_hsType::TextBuffer->HsType->SrcLoc->IO()
process_hsType buffer (HsTyFun hstype1 hstype2) srcLoc = do
					process_hsType buffer hstype1 srcLoc
					process_hsType buffer hstype2 srcLoc
process_hsType buffer (HsTyCon hsQName) srcLoc = process_hsQName buffer hsQName srcLoc
process_hsType buffer _  _= return ()
--
process_hsQName:: TextBuffer->HsQName->SrcLoc->IO()
process_hsQName buffer (UnQual hsName) loc= do
					tag<-greenTag
					markElement buffer loc (extractHsName hsName) tag
process_hsQName _ _ _ =return ()

--procesa la declaración de tipos de la función(no es la función en sí con lo que devuelve)
process_fun_declaration:: TextBuffer->SrcLoc->HsName->IO()
process_fun_declaration buffer loc hsName=do
						tag<-blackItalic
						markElement buffer loc (extractHsName hsName) tag


--Procesa los datos de una función
process_hsMatch::TextBuffer->HsMatch->IO()
process_hsMatch buffer (HsMatch srcLoc hsName hsPat _ _)=do
						tag<-blackItalic
						markElement buffer srcLoc (extractHsName hsName) tag
						foldIO (processHsPat buffer) hsPat

--
processHsPat::TextBuffer->HsPat->IO()
processHsPat buffer (HsPParen hsPat)=processHsPat hsPat
processHsPat buffer (HsPApp hsQName hsPat)=do
					process_hsQName buffer hsQName
					foldIO (processHsPat buffer) hsPat
	

--
extractHsName::HsName->String
extractHsName (HsIdent str)=str
extractHsName (HsSymbol str)=str

--se marca declaración de función en el buffer

markElement::TextBuffer->SrcLoc->String->TextTag->IO()
markElement buffer srcLoc name tag=do
				let line=(srcLine srcLoc)-1
				let column=(srcColumn srcLoc)
				start<-textBufferGetIterAtLine buffer line
				textIterForwardChars start (column -1)
				end<-textIterCopy start
				putStrLn ("Elemento: "++name++" linea:" ++(show (line+1))++"columna:"++(show (column +1)))


				tags <- textBufferGetTagTable buffer
						
				textTagTableAdd tags tag
				markElementRec buffer name start end "" tag 0



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
markElementRec::TextBuffer->String->TextIter->TextIter->String->TextTag->Int->IO()
markElementRec buffer name start end acum tag nameOffset=do
						startOffset<-textIterGetOffset start
						endOffset<-textIterGetOffset end
						top<-textBufferGetEndIter buffer
						topOffset<-textIterGetOffset top
						putStrLn ("Name:"++name++" start"++(show startOffset)++" end"++(show endOffset)++".Limit:"++(show topOffset) ++" nameOffset"++(show nameOffset)++" acum: "++acum) 
						if((compare name acum)== EQ)
							then do
								
								startOffset<-textIterGetOffset start
								endOffset<-textIterGetOffset end
								putStrLn ("start"++(show startOffset)++" end"++(show endOffset) ++" elemento tageado: "++name) 
								
								textBufferApplyTag buffer tag start end
								
								--se busca siguiente ocurrencias
								textIterForwardChars end 1
								start<-textIterCopy end
								markElementRec buffer name start end "" tag 0
	
						else do
							--posición caracter actual			
							end'<-textIterCopy end
							
							textIterForwardChars end 1

							currentChar<-textBufferGetText buffer end' end False	
							--se corta si se llega al final de linea
							if( (compare currentChar "\n")==EQ)
								then return ()
							else  do
								--el elemento buscado no esta en esta posición, se busca mas adelante
								if( not( (compare currentChar [(name !! nameOffset)])==EQ))
									then do
								start<-textIterCopy end
								markElementRec buffer name start end "" tag 0
								
								else    do
									--se obtiene el siguiente caracter
									contents <- textBufferGetText buffer start end False	
									markElementRec buffer name start end contents tag (nameOffset +1)
							
							
