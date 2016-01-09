module SyntaxUtilsModule where
--
extractHsName::HsName->String
extractHsName (HsIdent str)=str
extractHsName (HsSymbol str)=str

--
foldIO:: (a->IO()) -> [a] -> IO()
foldIO fun []=return ()
foldIO fun (x:xs)=do
			fun x
			foldIO fun xs
