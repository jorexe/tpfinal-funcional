import Graphics.UI.Gtk

main :: IO ()
main= do
    initGUI
    window <- windowNew
    set window [windowTitle := "Text Editor", containerBorderWidth := 0,windowDefaultWidth := 800, windowDefaultHeight := 400]
    --We need to set the window color to white (RGB format)
    widgetModifyBg window StateNormal (Color 0xFFFF 0xFFFF 0xFFFF)
    --Menu
    newfile <- actionNew "NEW_FILE" "New"     (Just "Create a new file.") (Just stockNew)
    openfile <- actionNew "OPEN_FILE" "Open"    (Just "Open an existing file.") (Just stockOpen)
    savefile <- actionNew "SAVE_FILE" "Save"    (Just "Save the current file.") (Just stockSave)
    copytext <- actionNew "COPY_TEXT" "Copy"  (Just "Copy text to clipboard.") (Just stockCopy)
    pastetext <- actionNew "PASTE_TEXT" "Paste" (Just "Paste clipboard.") (Just stockPaste)
    quitapp <- actionNew "QUIT" "Exit"    (Just "Quit the editor.") (Just stockQuit)

    defaultgroup <- actionGroupNew "DEFAULT_GROUP"
    mapM_ (actionGroupAddAction defaultgroup) [savefile, copytext, pastetext, newfile, openfile, quitapp]

    uimanager <- uiManagerNew
    uiManagerAddUiFromString uimanager uitemplate
    uiManagerInsertActionGroup uimanager defaultgroup 0

    maybeToolbar <- uiManagerGetWidget uimanager "/ui/toolbar"
    let toolbar = case maybeToolbar of
                        (Just x) -> x
                        Nothing -> error "Cannot get toolbar from string." 
    --Bind de botones
    --actionSetSensitive cuta False
    onActionActivate quitapp (widgetDestroy window)
    mapM_ printexample [newfile,copytext,pastetext,quitapp]
    mapM_ savedisplaydialog [savefile]
    mapM_ loaddisplaydialog [openfile]
    --BoxContainer
    vb <- vBoxNew False 0
    containerAdd window vb

    boxPackStart vb toolbar PackNatural 2
    hseparator <- hSeparatorNew
    boxPackStart vb hseparator PackNatural 2


    --TextView
    textview <- textViewNew
    boxPackStart vb textview PackGrow 4
    textViewSetWrapMode textview WrapChar


    widgetShowAll window

    onDestroy window mainQuit
    mainGUI

uitemplate = "<ui><toolbar><toolitem action=\"NEW_FILE\" /><toolitem action=\"OPEN_FILE\" /><toolitem action=\"SAVE_FILE\" /><separator /><toolitem action=\"COPY_TEXT\" /><toolitem action=\"PASTE_TEXT\" /><separator /><toolitem action=\"QUIT\" /></toolbar></ui>"

printexample :: ActionClass self => self -> IO (ConnectId self)
printexample a = onActionActivate a $ do name <- actionGetName a
                                         putStrLn ("Action Name: " ++ name)

savedisplaydialog :: ActionClass self => self -> IO (ConnectId self)
savedisplaydialog a = onActionActivate a $ do
                fchdal <- fileChooserDialogNew (Just "Save As...Dialog") Nothing FileChooserActionSave [("Cancel", ResponseCancel), ("Save", ResponseAccept), ("Backup", ResponseUser 100)]
                fileChooserSetDoOverwriteConfirmation fchdal True
                widgetShow fchdal
                response <- dialogRun fchdal
                case response of
                    ResponseCancel -> putStrLn "You cancelled..."
                    ResponseAccept -> do nwf <- fileChooserGetFilename fchdal
                                         case nwf of Nothing -> putStrLn "Nothing" 
                                                     Just path -> putStrLn ("New file path is:\n" ++ path)
                    ResponseUser 100 -> putStrLn "You pressed the backup button"
                    ResponseDeleteEvent -> putStrLn "You closed the dialog window..."

                widgetDestroy fchdal

loaddisplaydialog :: ActionClass self => self -> IO (ConnectId self)
loaddisplaydialog a = onActionActivate a $ do
                fchdal <- fileChooserDialogNew (Just "Save As...Dialog") Nothing FileChooserActionOpen [("Cancel", ResponseCancel), ("Open", ResponseAccept), ("Backup", ResponseUser 100)]
                --fileChooserSetDoOverwriteConfirmation fchdal True
                widgetShow fchdal
                response <- dialogRun fchdal
                case response of
                    ResponseCancel -> putStrLn "You cancelled..."
                    ResponseAccept -> do nwf <- fileChooserGetFilename fchdal
                                         case nwf of Nothing -> putStrLn "Nothing" 
                                                     Just path -> putStrLn ("File path is:\n" ++ path)
                    ResponseUser 100 -> putStrLn "You pressed the backup button"
                    ResponseDeleteEvent -> putStrLn "You closed the dialog window..."

                widgetDestroy fchdal