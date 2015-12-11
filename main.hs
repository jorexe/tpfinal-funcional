import Graphics.UI.Gtk

hello :: (ButtonClass o) => o -> IO ()
hello b = set b [buttonLabel := "Hello World"]

main :: IO ()
main = do
  initGUI
  window <- windowNew
  button <- buttonNew

  set window [windowDefaultWidth := 800, windowDefaultHeight := 400,
              containerChild := button, containerBorderWidth := 10]
  onClicked button (hello button)
  onDestroy window mainQuit
  widgetShowAll window
  mainGUI
