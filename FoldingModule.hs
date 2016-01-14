--modulo que realiza la función de colapsado de código de función.
module FoldingModule where
import SyntaxUtilsModule
import Graphics.UI.Gtk
import Language.Haskell.Syntax
import TagsModule

					--boton , linea en la que se encuentra
data ButtonProperty=ButtonProperty ToggleButton Int 

--función principal en la funcionalidad de colapsar código.
processFolding::HsModule->TextBuffer->Table->HBox  -> IO ()
processFolding (HsModule _  _ _ _ hsDecl) buffer table hbox=	processHsDecl buffer hsDecl table hbox
--
processHsDecl:: TextBuffer -> [ HsDecl ]->Table ->HBox ->IO ()
processHsDecl buffer ((HsFunBind hsMatch):xs) table hbox=do
						putStrLn "[FoldingModule, processHsDecl] hsFunBind"
						processHsMatch xs hsMatch buffer table hbox
						processHsDecl buffer xs table hbox
processHsDecl buffer (x:xs) table hbox =processHsDecl buffer xs table hbox
processHsDecl _   _ _  _= do
			putStrLn  "[FoldingModule, processHsDecl] others: "
			return()
--

--primera lista contiene las siguientes declaraciones de Haskell.
--segunda lista tiene como primer elemento a la declaración de la actual función. Los siguientes elementos son las siguientes funciones.
processHsMatch :: [HsDecl] -> [HsMatch] -> TextBuffer->Table->HBox->IO [ButtonProperty]
processHsMatch xs (y:ys) buffer table hbox= do
					start<-getNameEndIter y buffer --iterador al comienzo del código a ocultar
					--lineBelow el numero linea que la cual se oculta codigo
					(end,nextLine)<- if (null ys)
						then 
							getStartIter xs buffer --comienzo siguiente declaración
						else 
							getNameStartIter ys buffer --comienzo de la siguiente función
					tags <- textBufferGetTagTable buffer
					tag<-invisibleTag	
					textTagTableAdd tags tag
					--					
					startOffset<-textIterGetOffset start
					endOffset<-textIterGetOffset end
					putStrLn ("[FoldingModule, processHsMatch] registering tag. Start:" ++ (show startOffset) ++ " end: " ++ (show endOffset))
					--					
					--textBufferApplyTag buffer tag start end
					--se crea el boton para colapsar el código de dicha función
					let currentLine=getRow y	
					let row=getRow y				
					button<-createButton start end tag buffer
					tableAttachDefaults table button 0 1 (row-1) row
					
					nextButtonProperties<-processHsMatch xs ys buffer table hbox --llamada recursiva. En la variable quedan los siguientes botones
					
					
					onToggled button (buttonSwitch button buffer tag start end nextButtonProperties table (currentLine - nextLine ))			
					
					putStrLn ("[FoldingModule, processHsMatch].CurrentLine: " ++ (show currentLine )++ "line nextLine: " ++ (show nextLine))
					
					
					--tableAttach table button 0 1 (row-1) row [Shrink] [Shrink] 0 0
					
					return ((ButtonProperty button row):nextButtonProperties)

processHsMatch _ _ _  _ _=return []
--

getRow::HsMatch-> Int
getRow (HsMatch srcLoc _ _ _ _)= srcLine srcLoc



--Retorna el iterador que apunta al comienzo del nombre de la definición de función
getNameStartIter::[HsMatch]->TextBuffer->IO (TextIter,Int)
getNameStartIter ((HsMatch srcLoc _ _ _ _):ys) buffer=getIterForSrcLoc srcLoc buffer
							



--

getStartIter::[HsDecl]->TextBuffer->IO (TextIter,Int)
getStartIter [] buffer=do
			iter<- textBufferGetEndIter buffer
			return (iter,0)
getStartIter (x:xs) buffer =getStartIterHsDecl x buffer


--
getStartIterHsDecl::HsDecl->TextBuffer->IO (TextIter,Int)
getStartIterHsDecl (HsTypeDecl srcLoc _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsDataDecl srcLoc _ _ _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsInfixDecl srcLoc _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsNewTypeDecl srcLoc _ _ _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsClassDecl srcLoc _ _ _ _  ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsInstDecl srcLoc _ _ _ _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsDefaultDecl srcLoc _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsTypeSig srcLoc _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsFunBind hsMatch ) buffer=getNameStartIter hsMatch buffer
getStartIterHsDecl (HsPatBind srcLoc _ _ _  ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsForeignImport srcLoc _  _ _ _ _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsForeignExport srcLoc _ _ _ _ ) buffer=getIterForSrcLoc srcLoc buffer


--
getNameEndIter::HsMatch->TextBuffer->IO TextIter
getNameEndIter (HsMatch srcLoc hsName _ _ _) buffer =do
							let name=extractHsName hsName
							getIter srcLoc buffer name
--
getIterForSrcLoc::SrcLoc->TextBuffer->IO (TextIter,Int)
getIterForSrcLoc srcLoc buffer=do
				let line=(srcLine srcLoc)-1
				let column=(srcColumn srcLoc)
				iter<-textBufferGetIterAtLine buffer line
				textIterForwardChars iter (column -1 )
				return (iter,line)
--
getIter::SrcLoc->TextBuffer->String->IO TextIter
getIter srcLoc buffer name=do
				let length'=length name
				(iter,l) <- getIterForSrcLoc srcLoc buffer
				textIterForwardChars iter length'
				return iter


--función que permite obtener la cantidad de líneas que se muestran
getTextViewRows::TextView->IO Int
getTextViewRows textView=do
				txtBuffer <- textViewGetBuffer textView
				textBufferGetLineCount txtBuffer
--

--
createButton::TextIter->TextIter->TextTag->TextBuffer-> IO ToggleButton
createButton start end tag buffer=do
			button<-toggleButtonNewWithLabel "[-]"
			--onClicked button (buttonSwitch button buffer tag start end)
			--onToggled button (buttonSwitch button buffer tag start end)			
			return button
--

--nextButtonsProperties contiene las propiedades de los siguientes botones, no la del actual.
-- lines contiene la cantidad de lineas que hay que desplazar el boton de abajo cuando se oculta el código
buttonSwitch :: ToggleButton->TextBuffer->TextTag->TextIter->TextIter->[ButtonProperty] ->Table -> Int-> IO ()
buttonSwitch button buffer tag start end nextButtonsProperty table lines= do
					  active<-toggleButtonGetActive button
					  if ( active)
						then	do
							putStrLn ("Se oculta codigo. Lineas ocultadas:" ++ (show lines))
							textBufferApplyTag buffer tag start end
							--updateButtons nextButtonsProperty table lines
							--set table [tableChildTopAttach button :=0,
							--	   tableChildBottomAttach button := 1]
							updateButtons button table lines
					  else do
						putStrLn "Se vuelve a mostrar codigo"
						textBufferRemoveTag buffer tag start end
					 	updateButtons button table (-lines)
					  return ()

-- 
updateButtons::ToggleButton->Table->Int->IO()
updateButtons button table lines=do
							putStrLn "[updateButtons]"
							buttons<-containerGetChildren table
							updateButton table lines button False (reverse buttons)
--

--el valor booleano indica si los botones son los siguientes al boton presionado
updateButton::Table->Int->ToggleButton->Bool->[Widget]->IO()
updateButton table lines callingButton True  (x:xs)= do
						let button=castToToggleButton x
						currentTopAttach<-get table (tableChildTopAttach button)
						currentBottomAttach<- get table (tableChildBottomAttach button)					
						
						let topAttach=currentTopAttach + lines
						let bottomAttach=currentBottomAttach +lines
						putStrLn ("[updateButton] lines: " ++ (show lines)++" currentTopAttach:"++ (show currentTopAttach) ++ " currentBottomAttach: " ++ (show currentBottomAttach) ++ "top attach: " ++ (show topAttach) ++ " bottomAttach: " ++ (show bottomAttach))	
						set table	[tableChildTopAttach button :=topAttach,
								tableChildBottomAttach button := bottomAttach
							 	]
						updateButton table lines callingButton True  xs
updateButton table lines callingButton False  (x:xs)= do
							let currentButton=castToToggleButton x
							updateButton table lines callingButton (currentButton==callingButton)  xs
						  	
updateButton table lines callingButton _  _= return ()


