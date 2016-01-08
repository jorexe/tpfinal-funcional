module SearchModule where
import Graphics.UI.Gtk
import qualified Control.Monad as CM
import qualified Data.Char as DC
--marca una determinada palabra con un determinado tag que se recibe. Se busca en todo el texto.No se hacen búsquedas paciales, es decir que no se marca un string que aparezca parcialmente dentro de otro palabra que haya en el texto.

markWord::TextBuffer->TextTag->String->IO()
markWord buffer  tag name=do
				start<-textBufferGetStartIter buffer 
				
				end<-textIterCopy start

				tags <- textBufferGetTagTable buffer
				textTagTableAdd tags tag
				markWordRec buffer name start end "" tag 0 False False





--recibe: el buffer, el nombre del elemento, iterador que apunta al comienzo del nombre del elemento en el buffer, iterador que apunta al final del nombre del elemento , cadena leida hasta el momento desde start en el buffer(cuando se llega leer todo el nombre del elemento, se marca dicho nombre sobre el buffer),la etiqueta, indice actual sobre el nombre del elemento, un booleano que indica si se esta iterando sobre una palabra distintinta de la que se busca, y por último un booleano que indica si se debe parar de buscar la palabra frente a un fin de linea.
markWordRec::TextBuffer->String->TextIter->TextIter->String->TextTag->Int->Bool->Bool->IO()
markWordRec buffer name start end acum tag nameOffset inOtherWord stopOnNewLine=do
						startOffset<-textIterGetOffset start
						endOffset<-textIterGetOffset end
						--posición limite
						top<-textBufferGetEndIter buffer
						topOffset<-textIterGetOffset top
						putStrLn ("Word:"++name++" start"++(show startOffset)++" end"++(show endOffset)++".Limit:"++(show topOffset) ++" nameOffset"++(show nameOffset)++" acum: "++acum ++" inOtherWord: "++(show inOtherWord))
 
						if( (not inOtherWord) && (compare name acum)== EQ)
							then do
								
								startOffset<-textIterGetOffset start
								endOffset<-textIterGetOffset end
								putStrLn ("start"++(show startOffset)++" end"++(show endOffset) ++" elemento tageado: "++name) 						
								--se evitan ocurrencias parciales al marcar
								nextIter<-textIterCopy end
								textIterForwardChars nextIter 1
								currentString<-textBufferGetText  buffer end nextIter False								
								let nextChar'=currentString !! 0
								CM.when ((endOffset == topOffset) || DC.isSpace nextChar' || (nextChar' == '.') || (nextChar' == ':')|| (nextChar' == ';')|| (nextChar' == ','))	(textBufferApplyTag buffer tag start end)
								
								--se busca siguiente ocurrencias si no se encuentra en el final del buffer
								if (endOffset < topOffset)
									then do
										textIterForwardChars end 1
										start<-textIterCopy end
										markWordRec buffer name start end "" tag 0 False stopOnNewLine
								else
									return ()
														
						else do
							--posición caracter actual			
							current<-textIterCopy end
							
							textIterForwardChars end 1
							currentString<-textBufferGetText buffer current end False	
							let currentChar=currentString !! 0
							--caso en el cual se encuentre en el último elemento del buffer
							if (endOffset == topOffset || ( (compare currentChar '\n')==EQ && stopOnNewLine) )
								then return ()
							else do
								
								
								--el elemento buscado no esta en esta posición, se busca mas adelante
								if( (length name)<= nameOffset ||not( (compare currentString [(name !! nameOffset)])==EQ))
									then do
										start<-textIterCopy end
										let inOtherWord=not (DC.isSpace currentChar || (currentChar == '.') || (currentChar == ':')|| (currentChar == ';')|| (currentChar == ','))
										markWordRec buffer name start end "" tag 0 inOtherWord stopOnNewLine
								
								else do
								--se obtiene el siguiente caracter
									contents <- textBufferGetText buffer start end False	
									markWordRec buffer name start end contents tag (nameOffset +1) inOtherWord stopOnNewLine
							
	---

