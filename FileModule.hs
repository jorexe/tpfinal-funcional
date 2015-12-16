module FileModule where

import Graphics.UI.Gtk
import Control.Monad.IO.Class
import System.IO
--definicion de funciones

--recibe el string del nombre del archivo y el textview.
--No reterna nada. Inserta el texto del archivo en el buffer del textview.
readFileIntoTextView:: FilePath -> TextView -> IO ()
readFileIntoTextView fileName txtView=
		do	putStrLn ("Opening file: " ++ fileName)
			handle <- openFile fileName ReadMode
  			contents <- hGetContents handle
			txtBuffer <- textViewGetBuffer txtView
   			textBufferSetText txtBuffer contents
		  	putStr contents
			hClose handle
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
