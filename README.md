# tp final-funcional

***Jorge Gomez,Fernando Bejarano***

En el presente informe, se detalla la implementación de un editor de texto con interfaz gráfica en lenguaje Haskell. 

Se toma como base el tutorial: http://www.muitovar.com/gtk2hs/index.html
Se emplea la librería gráfica GTK2HS.
## Funcionalidades básicas
Abrir archivo (con ventana de dialogo), guardarlo, editarlo, pegar lo que se tenga en el clipboard (equivalente a hacer CTRL+C), copiar lo que se haya seleccionado al clipboard.

## Ventana principal que contiene el texto
El texto del documento se carga en un TextView (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html)
 con letra negra.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/base.png)
En la parte superior se encuentran botones con las funcionalidades. En el borde izquierdo se muestran los número de línea.

## Resaltador de sintaxis de haskell
https://hackage.haskell.org/package/haskell-src-1.0.2.0/docs/Language-Haskell-Parser.html

Se emplea la función "parseModule" del parser "Language.Haskell.Parser" que viene en Haskell para parsear el código que viene del archivo. Si se obtiene como resultado un "ParseOk" se resalta gráficamente el código. Si se obtiene "ParseFailed" no se resalta el código.
La idea es que se vea forma similar a como lo realiza gedit, utilizando tags en el TextView para asignarle un color representativo a la sintaxis.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/gedit_haskell.png)

Los colores que se emplean son los siguientes:
+ nombre de función: negro en cursiva y subrayado.
+ comentario: azul.
+ tipo de dato y constructores: verde.
+ palabra reservada "data": marrón.
+ el resto: en negro sin subrayado ni cursiva.
## Corrector ortográfico
Para detectar las palabras mal escritas, se emplea la librería Aspell para Haskell :https://hackage.haskell.org/package/haspell-1.1.0/docs/doc-index.html

Para resaltar las palabras mal escritas se utilizarian tags en el TextView del aplicativo, asignandoles color rojo a las palabras que no se encuentren en el diccionario.

Antes de tocar el botón del corrector:

	
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/antes.png)

Después de tocar el botón del corrector por primera vez.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/despues.png)


NOTA:se puede editar mientras se este en modo de correción.

## Abrir archivo
Se abre una ventana que permite elegir el archivo que se desea abrir. Una vez seleccionado el archivo, se emplea la función readFile de Haskell. Luego se carga el contenido del archivo en el buffer de la ventana de edición de texto (TextView http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html).

## Guardar un archivo
Se abre una ventana que permite elegir el nombre y la ubicación del archivo que se desea guardar. Después se emplea la función writeFile de Haskell para guardar el contenido de la ventana de edición de texto (TextView) en el archivo. 

## Nuevo archivo.
Se borra el contenido del buffer (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextBuffer.html#v%3AtextBufferDelete) de la ventana de edición de texto.

