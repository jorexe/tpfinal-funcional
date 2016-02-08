import Graphics.UI.Gtk
import Control.Monad.IO.Class
import FileModule
import ClipboardModule
import SpellingModule
import SearchModule
import SyntaxHighlightModule
import FoldingModule
--cantidad de filas que se muestran, por ahora esta fijo
totalRows=39
infline=0
supline=38
main :: IO ()
main= do
    initGUI
    window <- windowNew
    set window [windowTitle := "Text Editor", containerBorderWidth := 0,windowDefaultWidth := 800, windowDefaultHeight := 400, windowResizable:=False]
    --We need to set the window color to white (RGB format)
    widgetModifyBg window StateNormal (Color 0xFFFF 0xFFFF 0xFFFF)
    --Menu
    newfile <- actionNew "NEW_FILE" "New"     (Just "Create a new file.") (Just stockNew)
    openfile <- actionNew "OPEN_FILE" "Open"    (Just "Open an existing file.") (Just stockOpen)
    savefile <- actionNew "SAVE_FILE" "Save"    (Just "Save the current file.") (Just stockSave)
    copytext <- actionNew "COPY_TEXT" "Copy"  (Just "Copy text to clipboard.") (Just stockCopy)
    pastetext <- actionNew "PASTE_TEXT" "Paste" (Just "Paste clipboard.") (Just stockPaste)
    quitapp <- actionNew "QUIT" "Exit"    (Just "Quit the editor.") (Just stockQuit)
    spellcheck <- actionNew "CHECK" "SpellCheck" (Just "Check spelling.") (Just stockSpellCheck)
    syntaxhighlight <-actionNew "SYNTAX" "highlight" (Just "Highlight Haskell syntax.") (Just stockIndent)
    
    defaultgroup <- actionGroupNew "DEFAULT_GROUP"
    mapM_ (actionGroupAddAction defaultgroup) [savefile, copytext, pastetext, newfile, openfile,spellcheck,syntaxhighlight, quitapp]

    uimanager <- uiManagerNew
    uiManagerAddUiFromString uimanager uitemplate
    uiManagerInsertActionGroup uimanager defaultgroup 0

    maybeToolbar <- uiManagerGetWidget uimanager "/ui/toolbar"
    let toolbar = case maybeToolbar of
                        (Just x) -> x
                        Nothing -> error "Cannot get toolbar from string." 
    
    --BoxContainer
    vb <- vBoxNew False 0
    hb <- hBoxNew False 0
    containerAdd window vb
    
    boxPackStart vb toolbar PackNatural 2

    --Search panel
    labelsearch <- labelNew (Just "Search Word:")
    boxPackStart hb labelsearch PackNatural 2
    searchEntry <- entryNew
    boxPackStart hb searchEntry PackNatural 2
    searchbutton <- buttonNewWithLabel "Search"
    boxPackStart hb searchbutton PackNatural 2
    

    containerAdd vb hb

    hseparator <- hSeparatorNew
    boxPackStart vb hseparator PackNatural 2

    --caja horizontal que contiene la tabla con los botones para colapsar código y el textview
    horizontalBox <- hBoxNew False 5
    sw <- scrolledWindowNew Nothing Nothing
    containerAdd vb horizontalBox
    
   --tabla con botones para colapsar código,se debería crear al leer el archivo (los botones dependen del archivo)
    --rows<-getTextViewRows textview --cantidad de filas en el textview
    --putStrLn ("cantidad de filas: " ++ (show rows) )
    table<- tableNew totalRows 1 True
    tableGetColSpacing table 0
    widgetSetSizeRequest table 50 675
    containerAdd horizontalBox table
   -- boxPackStart horizontalBox table PackNatural 4

    --TextView
    textview <- textViewNew 
    textViewSetWrapMode textview WrapChar
    widgetSetSizeRequest textview 700 400
    --textViewSetBorderWindowSize textview TextWindowRight 200
    --textViewSetBorderWindowSize textview TextWindowLeft 200
--    boxPackStart horizontalBox textview PackNatural 4
    --containerAdd sw 
    containerAdd sw textview
    containerAdd horizontalBox sw
    --containerAdd horizontalBox textview
    
    --BORRAR luego la siguiente linea, es para testing. abre un archivo 
    readFileIntoTextView "FileModule.hs" textview table 	
    
    
   
   
   
    
    --highlightSyntax textview

    buffer <- get textview textViewBuffer
    
    --Signals
    textview `on` moveViewport $ \ss i -> putStrLn "shown!"
    textview `on` pageHorizontally $ \i b -> putStrLn "Paged"
    textview `on` moveFocus $ \dirtype -> putStrLn "Focus moved!"
    textview `on` pasteClipboard $ putStrLn "Something Pasted!"
    textview `on` setAnchor $ putStrLn "Set anchor"
    textview `on` textViewPreeditChanged $ \s -> do insertmark <- textBufferGetInsert buffer
                                                    cursoriter <- textBufferGetIterAtMark buffer insertmark
                                                    off <- textIterGetLine cursoriter
                                                    putStrLn("insertAtCursor" ++ show (off) ++" "++s)
    textview `on` moveCursor $ (movedCursorEvent buffer table)

    tags <- textBufferGetTagTable buffer
    kindaRedItalic <- textTagNew Nothing
    set kindaRedItalic [
      textTagStyle := StyleItalic,
      textTagForegroundSet := True,
      --textTagForegroundGdk := Color 30000 0 0 ]
      textTagForeground := ("red" :: String) ]

    searchTag <- textTagNew Nothing
    set searchTag [
      textTagForegroundSet := True,
      textTagBackground := ("yellow" :: String)
      ]

    parenthesisTag <- textTagNew Nothing
    set parenthesisTag [
      textTagForegroundSet := True,
      textTagBackground := ("green" :: String)
      ]

    textTagTableAdd tags kindaRedItalic
    textTagTableAdd tags searchTag
    textTagTableAdd tags parenthesisTag

    textview `on` moveCursor $ (checkParenthesisEvent buffer parenthesisTag)
    --textview `on` moveCursor $ (showInfo buffer)
    --textview `on` keyPressEvent $ tryEvent $ do
    --  [Control] <- eventModifier
    --  "i" <- eventKeyName
    --  liftIO $ do
    --    (start, end) <- textBufferGetSelectionBounds buffer
    --    textBufferApplyTag buffer kindaRedItalic start end
    
    --Binding search button
    onClicked searchbutton $ searchWord searchEntry buffer searchTag

    --Bind de botones
    --actionSetSensitive cuta False
    onActionActivate quitapp (widgetDestroy window)
    mapM_ printexample [quitapp,syntaxhighlight]
    mapM_ highlightSyntaxMain [(syntaxhighlight,textview,table)]
    mapM_ pasteFromClipboard [(pastetext,textview)]
    mapM_ copyFromClipboard [(copytext,textview)]
    mapM_ createNewFile [(newfile,textview,table)]
    mapM_ savedisplaydialog [(savefile,textview)]
    mapM_ loaddisplaydialog [(openfile,textview,table,horizontalBox)]
    mapM_ runSpellCheck [(spellcheck,textview)]
    widgetShowAll window

    onDestroy window mainQuit
    mainGUI

uitemplate = "<ui><toolbar><toolitem action=\"NEW_FILE\" /><toolitem action=\"OPEN_FILE\" /><toolitem action=\"SAVE_FILE\" /><separator /><toolitem action=\"COPY_TEXT\" /><toolitem action=\"PASTE_TEXT\" /><separator /><toolitem action=\"QUIT\" /><toolitem action=\"CHECK\" /><toolitem action=\"SYNTAX\" /></toolbar></ui>"

showInfo :: TextBuffer -> MovementStep -> Int -> Bool -> IO()
showInfo b movementStep steps flag = do
    i <- textBufferGetInsert b >>= textBufferGetIterAtMark b
    p <- textIterGetOffset i
    c <- textIterGetChar i
    let cc = case c of
                Nothing -> ""
                Just ch -> [ch]
    putStrLn("Position: " ++ show p ++ "\nMovement step: " ++ show movementStep ++"\nSteps: " ++ show steps ++ "\nExtends selection: " ++ show flag ++"\nCharacter at cursor: " ++ cc)

printexample :: ActionClass self => self -> IO (ConnectId self)
printexample a = onActionActivate a $ do name <- actionGetName a
                                         putStrLn ("Action Name: " ++ name)

savedisplaydialog :: ActionClass self =>(self,TextView) -> IO (ConnectId self)
savedisplaydialog (a,textview) = onActionActivate a $ do
                fchdal <- fileChooserDialogNew (Just "Save As...Dialog") Nothing FileChooserActionSave [("Cancel", ResponseCancel), ("Save", ResponseAccept), ("Backup", ResponseUser 100)]
                fileChooserSetDoOverwriteConfirmation fchdal True
                widgetShow fchdal
                response <- dialogRun fchdal
                case response of
                    ResponseCancel -> putStrLn "You cancelled..."
                    ResponseAccept -> do nwf <- fileChooserGetFilename fchdal
                                         case nwf of Nothing -> putStrLn "Nothing" 
                                                     Just path -> writeFileFromTextView path textview
                    ResponseUser 100 -> putStrLn "You pressed the backup button"
                    ResponseDeleteEvent -> putStrLn "You closed the dialog window..."

                widgetDestroy fchdal

loaddisplaydialog :: ActionClass self => (self,TextView,Table,HBox) -> IO (ConnectId self)
loaddisplaydialog (a,textview,table,hbox) = onActionActivate a $ do
                fchdal <- fileChooserDialogNew (Just "Load As...Dialog") Nothing FileChooserActionOpen [("Cancel", ResponseCancel), ("Open", ResponseAccept), ("Backup", ResponseUser 100)]
                --fileChooserSetDoOverwriteConfirmation fchdal True
                widgetShow fchdal
                response <- dialogRun fchdal
                case response of
                    ResponseCancel -> putStrLn "You cancelled..."
                    ResponseAccept -> do nwf <- fileChooserGetFilename fchdal
                                         case nwf of Nothing -> putStrLn "Nothing" 
                                                     Just path -> readFileIntoTextView path textview table 

                    ResponseUser 100 -> putStrLn "You pressed the backup button"
                    ResponseDeleteEvent -> putStrLn "You closed the dialog window..."

                widgetDestroy fchdal

checkParenthesisEvent :: TextBuffer -> TextTag -> MovementStep -> Int -> Bool -> IO()
checkParenthesisEvent buffer parenthesisTag _ _ _ = do
                                                        insertmark <- textBufferGetInsert buffer
                                                        tags <- textBufferGetTagTable buffer
                                                        textTagTableRemove tags parenthesisTag
                                                        currentiter <- textBufferGetIterAtMark buffer insertmark
                                                        prevop <- searchNextParenthesis buffer '(' (-1) currentiter 0
                                                        case prevop of
                                                                Nothing -> return ()
                                                                _ -> do
                                                                        nextclo <- searchNextParenthesis buffer ')' (1) currentiter 0
                                                                        highlightParenthesis buffer prevop nextclo parenthesisTag

highlightParenthesis :: TextBuffer -> Maybe TextIter -> Maybe TextIter -> TextTag -> IO()
highlightParenthesis buffer (Just prev) (Just next) tag = do
                                                                tags <- textBufferGetTagTable buffer
                                                                textTagTableAdd tags tag
                                                                highlightChar buffer prev tag
                                                                highlightChar buffer next tag
highlightParenthesis _ _ _ _ = do return ()

highlightChar :: TextBuffer -> TextIter -> TextTag -> IO()
highlightChar buffer iter tag = do
                                    endoffset <- textIterGetOffset iter
                                    end <- textBufferGetIterAtOffset buffer (endoffset+1)
                                    textBufferApplyTag buffer tag iter end

printChar :: Maybe Char -> IO ()
printChar (Just a) = putStrLn([a])
printChar _ = return()

isOpenParenthesis :: Maybe Char -> Bool
isOpenParenthesis (Just a) = a == '('
isOpenParenthesis _ = False

movedCursorEvent :: TextBuffer->Table  -> MovementStep -> Int -> Bool-> IO ()
movedCursorEvent  buffer table MovementDisplayLines dir b  = do
                                                              insertmark <- textBufferGetInsert buffer
                                                              cursoriter <- textBufferGetIterAtMark buffer insertmark
                                                              line <- textIterGetLine cursoriter
                                                              offset <- textIterGetOffset cursoriter
						
							      botomLimit<-textBufferGetLineCount buffer
							      if( (line== (botomLimit-1)) && dir >0)
									then putStrLn("[movedCursorEvent] reached limit")
							      else
		                                                      if (line > supline)
		                                                          then do 
		                                                              let infline =infline + 1
		                                                              let supline =supline + 1
		                                                              putStrLn("Scrolled")
		                                                              --MUEVE LOS BOTONES
		                                                              moveAllButtons table (-dir)
		                                                      else do
		                                                          if (line < infline)
		                                                              then do
		                                                                  let infline =infline - 1
		                                                                  let supline =supline - 1
		                                                                  putStrLn("Scrolled")
		                                                                  --MUEVE LOS BOTONES
		                                                                  moveAllButtons table (dir)
		                                                          else do
		                                                              putStrLn("")
		                                                      --Si la linea es inferior a la minima, restar los 2
		                         		      putStrLn("Cursor moving to line:" ++ show (line)++" .Dir:"++show (dir)++ " " ++ show b ++ "BotomLimit: " ++ (show botomLimit))
movedCursorEvent buffer _ a b _ = do putStrLn("Cursor moved")

searchWord :: Entry -> TextBuffer -> TextTag -> IO()
searchWord searchEntry buffer tag =  do str <- entryGetText searchEntry
                                        markWord buffer tag str


