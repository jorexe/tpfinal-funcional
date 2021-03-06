--ver Syntax.hs para ver la sintaxis del parseo que usa la libreria

module SyntaxHighlightModule where
import Graphics.UI.Gtk
import Control.Monad.IO.Class
import Language.Haskell.Parser
import Language.Haskell.Syntax
import TagsModule
import SearchModule
import SyntaxUtilsModule
import qualified Control.Monad as CM
import FoldingModule

reservedWords=["case", "class", "data", "deriving", "do","else", "if", "import", "in", "infix", "infixl", "infixr","instance", "let", "of", "module", "newtype", "then", "type", "where"]
--
highlightSyntaxMain:: ActionClass self =>(self,TextView,Table) -> IO (ConnectId self)	
highlightSyntaxMain (a,textview,table) = onActionActivate a $ do
							highlightSyntax textview table
							putStrLn("[highlightSyntaxMain] done")							
--
--hbox es la caja horizontal en la que se encuentra la tabla
highlightSyntax:: TextView->Table ->IO()
highlightSyntax txtview table =do
			txtBuffer <- textViewGetBuffer txtview
			start <- textBufferGetStartIter txtBuffer
			
			end <- textBufferGetEndIter txtBuffer
			
			contents <- textBufferGetText txtBuffer start end False
			--se remueven marcas previas
			textBufferRemoveAllTags txtBuffer start end			
			
			
			
			--parseo y marcado de sintaxis. También se agregan los botones para colapsar el código.
			let parseResult=Language.Haskell.Parser.parseModule contents
			processResult parseResult txtBuffer table 
			
					
			
			putStrLn("[highlightSyntax]texto parseado")
			
		
--			
markReservedWords:: TextBuffer->IO ()
markReservedWords txtBuffer =do
			tag<-brownTag
			foldIO (markWord txtBuffer  tag ) reservedWords
		 	putStrLn("[markedReservedWords] palabras clave marcadas")
--

--se procesa el resultado del parseo que se obtiene del parser de sintaxis de Haskell.
processResult::ParseResult HsModule->TextBuffer->Table-> IO()
processResult (ParseOk modul) buffer table = do
				putStrLn("[highlightSyntax] ParseOK")

				--se marcan palabras clave de la sintaxis de Haskell.
				markReservedWords buffer	
				--putStrLn(show modul)
				
				--se marca la sintaxis segun lo parseado				
				processModule modul buffer
				--se agregan los botones para colapsar el código
				processFolding modul buffer table 
				--se marcan comentarios
				markComments buffer
processResult (ParseFailed _ _) _ _  =do
					putStrLn("[highlightSyntax] ParseFailed (not valid Haskell syntax)")
					return ()
--
processModule::HsModule->TextBuffer->IO()
processModule (HsModule loc mod _ _ hsdeclList) buffer=foldIO (process_hsdecl buffer) hsdeclList

--

--
process_hsdecl::TextBuffer-> HsDecl->IO()
process_hsdecl buffer (HsFunBind hsMatchList)=foldIO (process_hsMatch buffer)  hsMatchList
process_hsdecl buffer (HsTypeSig loc hsName hsQualType)= do 
		foldIO (process_fun_declaration buffer loc ) hsName
		process_hsQualType buffer hsQualType loc
process_hsdecl buffer (HsDataDecl loc _ hsName _ hsDataDecl _ )	=do
							
							btag<-brownTag
							markElement buffer loc "data"  btag 
							gtag<-greenTag
							markElement buffer loc (extractHsName hsName)  gtag
							foldIO (process_hsConDecl buffer ) hsDataDecl
 
process_hsdecl buffer (HsPatBind loc hspat _ _ )=processHsPat buffer loc hspat		
process_hsdecl _ _ =return ()

--
process_hsQualType::TextBuffer->HsQualType->SrcLoc->IO()
process_hsQualType buffer (HsQualType _ hs_type) srcLoc=process_hsType buffer hs_type srcLoc

--
process_hsType::TextBuffer->HsType->SrcLoc->IO()
process_hsType buffer (HsTyFun hstype1 hstype2) srcLoc = do
					process_hsType buffer hstype1 srcLoc
					process_hsType buffer hstype2 srcLoc
process_hsType buffer (HsTyCon hsQName) srcLoc =do
						tag <-greenTag
						process_hsQName buffer hsQName srcLoc tag
process_hsType buffer (HsTyApp hstype1 hstype2)  srcLoc= do
						process_hsType buffer hstype1 srcLoc
						process_hsType buffer hstype2 srcLoc
process_hsType buffer _  _= return ()
--
process_hsQName:: TextBuffer->HsQName->SrcLoc->TextTag->IO()
process_hsQName buffer (UnQual hsName) loc tag= do
					markElement buffer loc (extractHsName hsName) tag
process_hsQName _ _ _ _ =return ()

--procesa la declaración de tipos de la función(no es la función en sí con lo que devuelve)
process_fun_declaration:: TextBuffer->SrcLoc->HsName->IO()
process_fun_declaration buffer loc hsName=do
						tag<-blackItalic
						markElement buffer loc (extractHsName hsName) tag


--Procesa los datos de una función
process_hsMatch::TextBuffer->HsMatch->IO()
process_hsMatch buffer (HsMatch srcLoc hsName hsPat hsRhs _) =do
						tag<-blackItalic
						markElement buffer srcLoc (extractHsName hsName) tag
						foldIO (processHsPat buffer srcLoc) hsPat
						process_hsRhs buffer hsRhs srcLoc

--
processHsPat::TextBuffer->SrcLoc->HsPat->IO()
processHsPat buffer location (HsPParen hsPat) =processHsPat buffer location hsPat 
processHsPat buffer  location (HsPApp hsQName hsPat)=do
					tag<-greenTag
					process_hsQName buffer hsQName location tag
					foldIO (processHsPat buffer location) hsPat

processHsPat _ _ _=return ()	
--

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
				--markElementRec buffer name start end "" tag 0
				markWordRec buffer name start end "" tag 0 False True




--recibe: el buffer, el nombre del elemento, iterador que apunta al comienzo del nombre del elemento en el buffer, iterador que apunta al final del nombre del elemento , cadena leida hasta el momento desde start en el buffer(cuando se llega a haber leido todo el nombre del elemento, se marca dicho nombre sobre el buffer), indice actual sobre el nombre del elemento, un booleano que indica si se esta iterando sobre una palabra distintinta de la que se busca.
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
								putStrLn ("start"++(show startOffset)++" end"++(show endOffset) ++" tagged element: "++name) 
								
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
							
---


process_hsConDecl::TextBuffer->HsConDecl->IO()
process_hsConDecl buffer  (HsConDecl loc hsName hsBangType)=do
							tag<-greenTag
							markElement buffer loc (extractHsName hsName)  tag
							foldIO (process_hsBangType buffer loc ) hsBangType

process_hsConDecl buffer _ =return ()

--

process_hsBangType::TextBuffer->SrcLoc->HsBangType->IO()
process_hsBangType buffer location (HsUnBangedTy hsType)=process_hsType buffer hsType location
process_hsBangType _ _ _=return ()




markComments::TextBuffer->IO()
markComments buffer=do
			putStrLn("[markComments] start")
			start <- textBufferGetStartIter buffer
			
			end <-textIterCopy  start
			btag<- blueTag
			tags <- textBufferGetTagTable buffer
			
			--borrarTag<-invisibleTag	
			--textTagTableAdd tags borrarTag
			--markCommentsRec buffer start end "" borrarTag
			
		
			textTagTableAdd tags btag
			markCommentsRec buffer start end "" btag
			
			putStrLn("[markComments] end")
markCommentsRec::TextBuffer->TextIter->TextIter->String->TextTag->IO()
markCommentsRec buffer start end acum tag=do
				
				startOffset<-textIterGetOffset start
				endOffset<-textIterGetOffset end
				top<-textBufferGetEndIter buffer
				topOffset<-textIterGetOffset top
				putStrLn ("[markCommentRec] start"++(show startOffset)++" end"++(show endOffset)++".Limit:"++(show topOffset) ++" acum: "++acum) 
				--se controlan los límites
				if (endOffset == topOffset)  
					then return () --fuera de limite
				else	do
					end'<-textIterCopy end
					textIterForwardChars end 1
					currentChar<-textBufferGetText buffer end' end False
				
					case currentChar of
						"\n" ->do
							CM.when ((compare "--" acum)==EQ) (do 
												textBufferApplyTag buffer tag start end
												putStrLn ("[markCommentRec] comentario marcado") )
							start<-textIterCopy end				  	
							markCommentsRec buffer start end "" tag
						"-" -> markCommentsRec buffer start end (acum++ currentChar) tag
						_ -> if((compare "--" acum)==EQ) --dentro de un comentario
								then markCommentsRec buffer start end acum tag
							else do
								start<-textIterCopy end
								markCommentsRec buffer start end "" tag

					
					


---se resaltan nombres de funciones cuando se las aplica
process_hsRhs::TextBuffer->HsRhs->SrcLoc->IO()
process_hsRhs buffer (HsUnGuardedRhs hsExp) srcLoc=process_hs_exp buffer srcLoc hsExp False
process_hsRhs _ _ _ = return ()

--el booleano se emplea para detectar si es el nombre de la función que se esta aplicando
process_hs_exp::TextBuffer-> SrcLoc->HsExp->Bool->IO()
process_hs_exp buffer loc (HsApp hsexp1 hsexp2) bool=do
						process_hs_exp buffer loc hsexp1 True
						process_hs_exp buffer loc hsexp2 False

process_hs_exp buffer loc (HsVar hsQname) bool=do
						if bool
							then do
							tag<-blackItalic
							process_hsQName buffer hsQname loc tag
						else
							return ()
process_hs_exp buffer loc (HsParen hsExp) bool =process_hs_exp buffer loc hsExp True
process_hs_exp _ _ _ _ =return ()




