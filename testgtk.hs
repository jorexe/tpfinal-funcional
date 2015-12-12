{-# LANGUAGE
OverloadedStrings
  #-}

import Graphics.UI.Gtk
import Control.Monad.IO.Class

main = do
  initGUI
  window <- windowNew
  window `on` objectDestroy $ mainQuit

  view <- textViewNew
  window `containerAdd` view

  widgetShowAll window
  mainGUI