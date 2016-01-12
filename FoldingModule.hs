--modulo que realiza la función de colapsado de código de función.
module FoldingModule where
import SyntaxUtilsModule
import Graphics.UI.Gtk
import Language.Haskell.Syntax
import TagsModule
--función principal en la funcionalidad de colapsar código.
processFolding::HsModule->TextBuffer->Table  -> IO ()
processFolding (HsModule _  _ _ _ hsDecl) buffer table=	processHsDecl buffer hsDecl table
--
processHsDecl:: TextBuffer -> [ HsDecl ]->Table -> IO ()
processHsDecl buffer ((HsFunBind hsMatch):xs) table=do
						putStrLn "[FoldingModule, processHsDecl] hsFunBind"
						processHsMatch xs hsMatch buffer table
						processHsDecl buffer xs table
processHsDecl buffer (x:xs) table =processHsDecl buffer xs table
processHsDecl _   _ _ = do
			putStrLn  "[FoldingModule, processHsDecl] others: "
			return()
--

--primera lista contiene las siguientes declaraciones de Haskell.
--segunda lista tiene como primer elemento a la declaración de la actual función. Los siguientes elementos son las siguientes funciones.
processHsMatch :: [HsDecl] -> [HsMatch] -> TextBuffer->Table->IO()
processHsMatch xs (y:ys) buffer table= do
					start<-getNameEndIter y buffer
					end<- if (null ys)
						then 
							getStartIter xs buffer
						else 
							getNameStartIter ys buffer --comienzo de la siguiente función
					tags <- textBufferGetTagTable buffer
					tag<-invisibleTag	
					textTagTableAdd tags tag
					--					
					startOffset<-textIterGetOffset start
					endOffset<-textIterGetOffset end
					putStrLn ("[FoldingModule, processHsMatch] applying tag. Start:" ++ (show startOffset) ++ " end: " ++ (show endOffset))
					--					
					--textBufferApplyTag buffer tag start end
					--se crea el boton para colapsar el código de dicha función
					button<-createButton start end tag buffer
					let row=getRow y
					tableAttachDefaults table button 0 1 (row-1) row
					--tableAttach table button 0 1 (row-1) row [Shrink] [Shrink] 0 0
					
					processHsMatch xs ys buffer table

processHsMatch _ _ _  _=return ()
--

getRow::HsMatch-> Int
getRow (HsMatch srcLoc _ _ _ _)= srcLine srcLoc



--Retorna el iterador que apunta al comienzo del nombre de la definición de función
getNameStartIter::[HsMatch]->TextBuffer->IO TextIter
getNameStartIter ((HsMatch srcLoc _ _ _ _):ys) buffer=getIterForSrcLoc srcLoc buffer



--

getStartIter::[HsDecl]->TextBuffer->IO TextIter
getStartIter [] buffer=textBufferGetEndIter buffer
getStartIter (x:xs) buffer =getStartIterHsDecl x buffer


--
getStartIterHsDecl::HsDecl->TextBuffer->IO TextIter
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
getIterForSrcLoc::SrcLoc->TextBuffer->IO TextIter
getIterForSrcLoc srcLoc buffer=do
				let line=(srcLine srcLoc)-1
				let column=(srcColumn srcLoc)
				iter<-textBufferGetIterAtLine buffer line
				textIterForwardChars iter (column -1 )
				return iter
--
getIter::SrcLoc->TextBuffer->String->IO TextIter
getIter srcLoc buffer name=do
				let length'=length name
				iter <- getIterForSrcLoc srcLoc buffer
				textIterForwardChars iter length'
				return iter


--función que permite obtener la cantidad de líneas que se muestran
getTextViewRows::TextView->IO Int
getTextViewRows textView=do
				txtBuffer <- textViewGetBuffer textView
				textBufferGetLineCount txtBuffer
--

--
createButton::TextIter->TextIter->TextTag->TextBuffer-> IO Button
createButton start end tag buffer=do
			button<-buttonNewWithLabel "-"
			--onClicked button (buttonSwitch button buffer tag start end)
			onButtonActivate button (buttonSwitch button buffer tag start end)			
			return button
--
buttonSwitch :: Button->TextBuffer->TextTag->TextIter->TextIter -> IO ()
buttonSwitch b buffer tag start end = do
  txt <- buttonGetLabel b
  let newtxt = case txt of
                 "less" ->  "more"
                 "more"  -> "less"
  --case txt of
  --               "+" -> textBufferRemoveTag buffer tag start end
  --               "-"  -> textBufferApplyTag buffer tag start end
  buttonSetLabel b newtxt

