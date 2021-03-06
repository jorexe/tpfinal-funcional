module SearchModule where
import Graphics.UI.Gtk
import qualified Control.Monad as CM
import qualified Data.Char as DC
--marca una determinada palabra con un determinado tag que se recibe. Se busca en todo el texto.No se hacen búsquedas paciales, es decir que no se marca un string que aparezca parcialmente dentro de otro palabra que haya en el texto.

--primer parametro es el buffer, el segunto el tag a emplear para marcar, el tercero es la palabra que se busca.
markWord::TextBuffer->TextTag->String->IO()
markWord buffer  tag name=do
				start<-textBufferGetStartIter buffer 
				end<-textIterCopy start
				tags <- textBufferGetTagTable buffer
				--textTagTableRemove tags tag
				textTagTableAdd tags tag
				markWordRec buffer name start end "" tag 0 False False


--TextBuffer, Character to search, Direction, CurrentPositionTextIter
searchChar :: TextBuffer -> Char -> Int -> TextIter -> IO (Maybe TextIter)
searchChar buffer c direction iter = do
										currentchar <- textIterGetChar iter
										if (compareMaybeChar currentchar c)
											then do
												return (Just iter)
										else do
											totalcount <- textBufferGetCharCount buffer
											offset <- textIterGetOffset iter
											if ((offset < totalcount) && (offset > 0))
												then do
													nextiter <- textBufferGetIterAtOffset buffer (offset+direction)
													searchChar buffer c direction nextiter
											else do
												return (Nothing)

flipParenthesis :: Char -> Char
flipParenthesis c | c == ')' = '(' | c == '(' = ')' | otherwise = ' '

--TextBuffer, Character to search, Direction, CurrentPositionTextIter
searchNextParenthesis :: TextBuffer -> Char -> Int -> TextIter -> Int -> IO (Maybe TextIter)
searchNextParenthesis buffer c direction iter flag= do
														--putStrLn("Getting flag "++show flag)
														currentchar <- textIterGetChar iter
														if ((compareMaybeChar currentchar c))
															then do
																if (flag == 0)
																	then do
																		return (Just iter)
																else do
																	totalcount <- textBufferGetCharCount buffer
																	offset <- textIterGetOffset iter
																	if ((offset < totalcount) && (offset > 0))
																		then do
																			nextiter <- textBufferGetIterAtOffset buffer (offset+direction)
																			searchNextParenthesis buffer c direction nextiter (flag-1)
																	else do
																		return (Nothing)
														else do
															if ((compareMaybeChar currentchar (flipParenthesis c)))
																then do
																	--putStrLn("Increasing flag")
																	totalcount <- textBufferGetCharCount buffer
																	offset <- textIterGetOffset iter
																	if ((offset < totalcount) && (offset > 0))
																		then do
																			nextiter <- textBufferGetIterAtOffset buffer (offset+direction)
																			searchNextParenthesis buffer c direction nextiter (flag+1)
																	else do
																		return (Nothing)
															else do
																putStr("")
																totalcount <- textBufferGetCharCount buffer
																offset <- textIterGetOffset iter
																if ((offset < totalcount) && (offset > 0))
																	then do
																		nextiter <- textBufferGetIterAtOffset buffer (offset+direction)
																		searchNextParenthesis buffer c direction nextiter flag
																else do
																	return (Nothing)

compareMaybeChar :: Maybe Char -> Char -> Bool
compareMaybeChar (Just c) ch = c == ch
compareMaybeChar _ _ = False

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
								CM.when ((endOffset == topOffset) || DC.isSpace nextChar' || (nextChar' == '.') || (nextChar' == ':')|| (nextChar' == ';')|| (nextChar' == ',')|| (nextChar' == '-')|| (nextChar' == ']')|| (nextChar' == '='))	(textBufferApplyTag buffer tag start end)
								
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
										let inOtherWord=not (DC.isSpace currentChar || (currentChar == '.') || (currentChar == ':')|| (currentChar == ';')|| (currentChar == ',') || (currentChar == '=') || (currentChar == '>')|| (currentChar == '[')|| (currentChar == '('))
										markWordRec buffer name start end "" tag 0 inOtherWord stopOnNewLine
								
								else do
								--se obtiene el siguiente caracter
									contents <- textBufferGetText buffer start end False	
									markWordRec buffer name start end contents tag (nameOffset +1) inOtherWord stopOnNewLine
							
	---

