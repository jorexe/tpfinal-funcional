import Graphics.UI.Gtk.Glade

main :: IO ()
main = do
  initGUI
  window <- windowNew
  widgetShowAll window
  mainGUI