module ClipboardModule where

import Graphics.UI.Gtk
import Graphics.UI.Gtk.General.Clipboard
import Control.Monad.IO.Class
import System.IO

copyFromClipboard:: ActionClass self => (self,TextView) -> IO (ConnectId self)
copyFromClipboard (a, txtview) = onActionActivate a $
		do	putStrLn ("Copy to clipboard")
			--clipboard <-clipboardGet selectionClipboard
			
pasteFromClipboard:: ActionClass self => (self,TextView) -> IO (ConnectId self)
pasteFromClipboard (a, txtview) = onActionActivate a $
		do	putStrLn ("Paste from clipboard")
			clipboard <-clipboardGet selectionClipboard
			clipboardRequestText clipboard (pasteCallback txtview)


pasteCallback:: TextView -> Maybe String -> IO ()
pasteCallback txtView (Just str)=
			do	putStrLn (str)
				txtBuffer <- textViewGetBuffer txtView
   				textBufferInsertAtCursor txtBuffer str
pasteCallback txtView Nothing = 
			do return()
