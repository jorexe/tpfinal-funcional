module FileModule where

import Graphics.UI.Gtk
import Control.Monad.IO.Class
import System.IO
import SyntaxHighlightModule
--definicion de funciones

--recibe el string del nombre del archivo y el textview.
--No reterna nada. Inserta el texto del archivo en el buffer del textview.
readFileIntoTextView:: FilePath -> TextView->Table -> IO ()
readFileIntoTextView fileName txtView table=
		do	putStrLn ("Opening file: " ++ fileName)
			handle <- openFile fileName ReadMode
  			contents <- hGetContents handle
			txtBuffer <- textViewGetBuffer txtView
   			textBufferSetText txtBuffer contents
		  	putStr contents
			hClose handle
			highlightSyntax txtView	table
			return ()

--recibe el string del nombre del archivo y el textview.
--No reterna nada. Inserta el texto del buffer del textview al archivo.
writeFileFromTextView:: FilePath -> TextView -> IO ()
writeFileFromTextView fileName txtView=
		do	putStrLn ("Saving file: " ++ fileName)
			
  			txtBuffer <- textViewGetBuffer txtView
			start <- textBufferGetStartIter txtBuffer
			end <- textBufferGetEndIter txtBuffer
			contents <- textBufferGetText txtBuffer start end False		
			writeFile fileName contents
			return ()


--función que se emplea para la opción de "nuevo archivo".
--newFile:: ActionClass self =>(self,TextView) -> IO (ConnectId self)
createNewFile:: ActionClass self =>(self,TextView) -> IO (ConnectId self)
createNewFile (a,txtView) =onActionActivate a $
		do	putStrLn ("New file")
			txtBuffer <- textViewGetBuffer txtView
			start <- textBufferGetStartIter txtBuffer
			end <- textBufferGetEndIter txtBuffer
			textBufferDelete txtBuffer start end
			
