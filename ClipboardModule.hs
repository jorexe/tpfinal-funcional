module ClipboardModule(copyFromClipboard,pasteFromClipboard)  where

import Graphics.UI.Gtk
import Graphics.UI.Gtk.General.Clipboard
import Control.Monad.IO.Class
import System.IO


-- se lee del clipboard de seleccion, luego se graba en el clipboard general
--"selectionPrimary" es el clipboard de selección de texto de la ventana de edición de texto.
copyFromClipboard:: ActionClass self => (self,TextView) -> IO (ConnectId self)
copyFromClipboard (a, txtview) = onActionActivate a $
		do	putStrLn ("Copy to clipboard")
			readClipboard <-clipboardGet selectionPrimary
			writeClipboard <-clipboardGet selectionClipboard
			clipboardRequestText readClipboard (copyCallBack writeClipboard)

--"selectionClipboard" es el clipboard general del sistema operativo

pasteFromClipboard:: ActionClass self => (self,TextView) -> IO (ConnectId self)
pasteFromClipboard (a, txtview) = onActionActivate a $
		do	putStrLn ("Paste from clipboard")
			clipboard <-clipboardGet selectionClipboard
			clipboardRequestText clipboard (pasteCallback txtview)
--
pasteCallback:: TextView -> Maybe String -> IO ()
pasteCallback txtView (Just str)=
			do	putStrLn (str)
				txtBuffer <- textViewGetBuffer txtView
   				textBufferInsertAtCursor txtBuffer str
pasteCallback txtView Nothing = 
			do return()


--
copyCallBack::Clipboard -> Maybe String -> IO ()
copyCallBack writeClipboard (Just str)=
			do 	clipboardSetText writeClipboard str
copyCallBack writeClipboard Nothing=
				do return()
