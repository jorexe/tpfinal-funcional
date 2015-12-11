import Graphics.UI.Gtk
import System.IO
main :: IO ()
main= do
  initGUI
  window <- windowNew
-- archivo
  handle <- openFile "archivoPrueba.txt" ReadMode
  contents <- hGetContents handle
  putStr contents
  hClose handle
-- 
  set window [windowTitle := "Text Editor", containerBorderWidth := 0,windowDefaultWidth := 800, windowDefaultHeight := 400]

  vb <- vBoxNew False 0
  containerAdd window vb

  hb <- hBoxNew False 0
  boxPackStart vb hb PackNatural 0

  txtfield <- textViewNew
  boxPackStart hb txtfield PackGrow 2
  --button <- buttonNewFromStock stockInfo
  --boxPackStart hb button PackNatural 0

  txtstack <- statusbarNew
  boxPackStart vb txtstack PackNatural 0
  id <- statusbarGetContextId txtstack "Line"

  widgetShowAll window
  --widgetSetSensitivity button False

  --onEntryActivate txtfield (saveText txtfield button txtstack id)
  --onPressed button (statusbarPop txtstack id)

--seteo del archivo en un buffer
  textViewSetBuffer txtfield 
--
  onDestroy window mainQuit
  mainGUI

saveText :: Entry -> Button -> Statusbar -> ContextId -> IO ()
saveText fld b stk id = do
    txt <- entryGetText fld
    let mesg | txt == reverse txt = "\"" ++ txt ++ "\""  ++
                                    " is equal to its reverse"
             | otherwise =  "\"" ++ txt ++ "\""  ++
                            " is not equal to its reverse"
    widgetSetSensitivity b True
    msgid <- statusbarPush stk id mesg
    return ()
