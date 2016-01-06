module SearchModule where
import Graphics.UI.Gtk
--marca una determinada palabra con un determinado tag que se recibe. Se busca en todo el texto.

markWord::TextBuffer->String->TextTag->IO()
markWord buffer name tag=do
				start<-textBufferGetStartIter buffer 
				
				end<-textIterCopy start

				tags <- textBufferGetTagTable buffer
				textTagTableAdd tags tag
				markWordRec buffer name start end "" tag 0





--recibe: el buffer, el nombre del elemento, iterador que apunta al comienzo del nombre del elemento en el buffer, iterador que apunta al final del nombre del elemento , cadena leida hasta el momento desde start en el buffer(cuando se llega a haber leido todo el nombre del elemento, se marca dicho nombre sobre el buffer).
markWordRec::TextBuffer->String->TextIter->TextIter->String->TextTag->Int->IO()
markWordRec buffer name start end acum tag nameOffset=do
						startOffset<-textIterGetOffset start
						endOffset<-textIterGetOffset end
						top<-textBufferGetEndIter buffer
						topOffset<-textIterGetOffset top
						putStrLn ("Word:"++name++" start"++(show startOffset)++" end"++(show endOffset)++".Limit:"++(show topOffset) ++" nameOffset"++(show nameOffset)++" acum: "++acum) 
						if((compare name acum)== EQ)
							then do
								
								startOffset<-textIterGetOffset start
								endOffset<-textIterGetOffset end
								putStrLn ("start"++(show startOffset)++" end"++(show endOffset) ++" elemento tageado: "++name) 
								
								textBufferApplyTag buffer tag start end
								
								--se busca siguiente ocurrencias
								textIterForwardChars end 1
								start<-textIterCopy end
								markWordRec buffer name start end "" tag 0
	
						else do
							--posición caracter actual			
							end'<-textIterCopy end
							
							textIterForwardChars end 1

							currentChar<-textBufferGetText buffer end' end False	
							
							
							--el elemento buscado no esta en esta posición, se busca mas adelante
							if( not( (compare currentChar [(name !! nameOffset)])==EQ))
								then do
									start<-textIterCopy end
									markWordRec buffer name start end "" tag 0
								
							else do
							--se obtiene el siguiente caracter
								contents <- textBufferGetText buffer start end False	
								markWordRec buffer name start end contents tag (nameOffset +1)
							
---

