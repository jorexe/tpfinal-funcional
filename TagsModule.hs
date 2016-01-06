--modulo que contiene los tags
module TagsModule where

import Graphics.UI.Gtk

--estilo de letra color verde
greenTag::IO TextTag
greenTag=do
	aux<- textTagNew Nothing
	set aux [
      		textTagForegroundSet := True,
		textTagForeground := ("green" :: String) 
		]
	return aux
--
--estilo de letra color negro con cursiva
blackItalic::IO TextTag
blackItalic=do
			aux<- textTagNew Nothing
			set aux [
      				textTagStyle := StyleItalic,
      				textTagForegroundSet := True,
				textTagForeground := ("black" :: String) 
				]
			return aux	
--
--estilo de letra color marrón
brownTag::IO TextTag
brownTag=do
	aux<- textTagNew Nothing
	set aux [
      		textTagForegroundSet := True,
		textTagForeground := ("brown" :: String) 
		]
	return aux

--

--estilo de letra color  azul
blueTag::IO TextTag
blueTag=do
	aux<- textTagNew Nothing
	set aux [
      		textTagForegroundSet := True,
		textTagForeground := ("blue" :: String) 
		]
	return aux
