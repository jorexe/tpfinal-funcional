import Graphics.UI.Gtk
import Control.Monad.IO.Class

module FileModule where

import Graphics.UI.Gtk
import Control.Monad.IO.Class
--definicion de funciones

--recibe el string del nombre del archivo y el textview.
--No reterna nada. Inserta el texto del archivo en el buffer del textview.

openFile:: FilePath -> TextViewClass -> IO ()
openFile fileName txtView=do
			handle <- openFile fileName ReadMode
  			contents <- hGetContents handle
			txtBuffer <- textViewGetBuffer txtview
   			textBufferSetText txtBuffer "pepe"
		  	putStr contents
			hClose handle
			return ()
