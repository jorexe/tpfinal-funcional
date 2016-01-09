--modulo que realiza la función de colapsado de código de función.
module FoldingModule where
import SyntaxUtilsModule

processHsDecl:: TextBuffer->[HsDecl]-> IO()
processHsDecl buffer ((HsFunBind hsMatch):xs)=processHsMatch xs hsMatch
processHsDecl _  _= return()

--primera lista contiene las siguientes declaraciones de Haskell.
--segunda lista tiene como primer elemento a la declaración de la actual función. Los siguientes elementos son las siguientes funciones.
processHsMatch :: [HsDecl] -> [HsMatch] -> TextBuffer->IO()
processHsMatch xs (y:ys) buffer= do
					let start=getNameEndIter y buffer
					let end= if (null ys)
							then
							getStartIter xs buffer
						else
							getNameStartIter ys buffer --comienzo de la siguiente función
					tags <- textBufferGetTagTable buffer
					tag<-invisibleTag	
					textTagTableAdd tags tag
					textBufferApplyTag buffer tag start end
					processHsMatch xs ys buffer
processHsMatch [] [] _=return ()
--


--Retorna el iterador que apunta al comienzo del nombre de la definición de función
getNameStartIter::[HsMatch]->TextBuffer->TextIter
getNameStartIter ((HsMatch srcLoc _ _ _ _):ys) buffer=iter
				where iter<-getIterForSrcLoc srcLoc



--

getStartIter::[HsDecl]->TextBuffer->TextIter
getStartIter [] buffer=iter
			where iter<-textBufferGetEndIter buffer
getStartIter (x:xs) _ =iter 
			where iter<-getStartIterHsDecl x


--
getStartIterHsDecl::HsDecl->TextBuffer->IO TextIter
getStartIterHsDecl (HsTypeDecl srcLoc _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsDataDecl srcLoc _ _ _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsInfixDecl srcLoc _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsNewTypeDecl srcLoc _ _ _ _ _) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsClassDecl srcLoc _ _ _ _  ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsInstDecl srcLoc _ _ _ _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsDefaultDecl srcLoc _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsTypeSign srcLoc _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsFunBind srcLoc _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsPathBind srcLoc _ _ _  ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsForeignImport srcLoc _ _ _ _ _ _ ) buffer=getIterForSrcLoc srcLoc buffer
getStartIterHsDecl (HsForeignExport srcLoc _ _ _ _ ) buffer=getIterForSrcLoc srcLoc buffer


--
getNameEndIter::HsMatch->TextBuffer->TextIter
getNameEndIter (HsMatch srcLoc hsName _ _ _) buffer =iter
						where iter<-getIter srcLoc buffer name
						      name=extractHsName hsName
--
getIterForSrcLoc::SrcLoc->TextBuffer->IO TextIter
getIterForSrcLoc srcLoc buffer=do
				let line=(srcLine srcLoc)-1
				let column=(srcColumn srcLoc)
				iter<-textBufferGetIterAtLine buffer line
				textIterForwardChars iter (column -1 )
				return iter

getIter::SrcLoc->TextBuffer-String->IO TextIter
getIter srcLoc buffer name=do
				let length=length name
				iter<-getIterForSrcLoc srcLoc buffer
				textIterForwardChars iter length
				return iter
