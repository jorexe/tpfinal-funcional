module ClipboardModule where

import Graphics.UI.Gtk
import Control.Monad.IO.Class
import System.IO

copyFromClipboard:: ActionClass self => (self,TextView) -> IO (ConnectId self)
copyFromClipboard (a, txtview) = onActionActivate a $
		do	putStrLn ("Copy to clipboard")

pasteFromClipboard:: ActionClass self => (self,TextView) -> IO (ConnectId self)
pasteFromClipboard (a, txtview) = onActionActivate a $
		do	putStrLn ("Paste from clipboard")
