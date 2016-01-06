# tp final-programación funcional

***Jorge Gomez,Fernando Bejarano***

En el presente informe, se detalla la implementación de un editor de texto con interface gráfica en lenguaje Haskell. 
Se emplea la librería gráfica GTK2HS.
Se toma como base el tutorial [1].

## Funcionalidades básicas
Abrir archivo (con ventana de dialogo), guardarlo, editarlo, pegar lo que se tenga en el clipboard (equivalente a hacer CTRL+C), copiar lo que se haya seleccionado al clipboard.

## Ventana principal que contiene el texto
El texto del documento se carga en un TextView (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html)
 con letra negra.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/base.png)

En la parte superior se encuentran botones con las funcionalidades. Los iconos de dichos botones son los que vienen por defecto en la librería GTK (http://www.pygtk.org/pygtk2reference/gtk-stock-items.html).

## Resaltador de sintaxis de haskell
https://hackage.haskell.org/package/haskell-src-1.0.2.0/docs/Language-Haskell-Parser.html

Se emplea la función "parseModule" del parser "Language.Haskell.Parser" que viene en Haskell para parsear el código que viene del archivo. Si se obtiene como resultado un "ParseOk" se resalta gráficamente el código. Si se obtiene "ParseFailed" no se resalta el código.
La idea es que se vea forma similar a como lo realiza el editor de texto "gedit", utilizando tags en el TextView para asignarle un color representativo a la sintaxis.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/gedit_haskell.png)

Los colores que se emplean sobre la fuente de las letras son los siguientes:
+ nombre de función: negro en cursiva .
+ comentario: azul.
+ tipo de dato y constructores: verde.
+ las palabras reservadas ( por ejemplo "data"): marrón. La lista de estas palabras se obtuvo de [4].
+ el resto: en negro sin subrayado ni cursiva.

Esta funcionalidad se realiza en forma automática cuando se abre un archivo con extensión ".hs" (archivo fuente de Haskell). En forma adicional, se puede activar con un botón. Si luego de haberse realizado el resaltado de la sintaxis se realiza algún cambio sobre el texto, es necesario volver a presionar el botón para que se ajuste el resaltado al nuevo texto que se tiene.


## Corrector ortográfico
Para detectar las palabras mal escritas, se emplea la librería Aspell para Haskell :https://hackage.haskell.org/package/haspell-1.1.0/docs/doc-index.html

Para resaltar las palabras mal escritas se utilizan tags en el TextView del aplicativo, asignandoles color de letra rojo a las palabras que no se encuentren en el diccionario.

Antes de tocar el botón del corrector:

	
![Alt text](https://github.com/jorexe/tpfinal-funcional/blob/haskellSintax/prototipo/antes.png)

Después de tocar el botón del corrector se obtiene lo siguiente:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/despues.png)


NOTA:se puede editar mientras se este en modo de correción.

## Abrir archivo
Se abre una ventana que permite elegir el archivo que se desea abrir. Una vez seleccionado el archivo, se emplea la función readFile de Haskell. Luego se carga el contenido del archivo en el buffer de la ventana de edición de texto (TextView http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html).

## Guardar un archivo
Se abre una ventana que permite elegir el nombre y la ubicación del archivo que se desea guardar. Después se emplea la función writeFile de Haskell para guardar el contenido de la ventana de edición de texto (TextView) en el archivo. 

## Nuevo archivo.
Se borra el contenido del buffer (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextBuffer.html#v%3AtextBufferDelete) de la ventana de edición de texto.

## Copiar 
Se copia en el clipboard, lo que se haya seleccionado de la ventana principal.

## Pegar
Se copia en la posición del cursor en la ventana de edición, el contenido del clipboard.

## Colapsar definiciones [falta implementar].
Cuando se tiene el texto resaltado con la sintaxis de Haskell, se ofrece la posibilidad de colapsar las definiciones de funciones. Se muestra un botón con el símbolo "-" en el margen izquierdo de la línea donde esta definida la función. Esto se puede apreciar en el siguiente prototipo de la aplicación:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/antesColapsar.png)


Cuando se presiona dicho botón,  se colapsa la definición completa de la función y solo se deja el nombre; también se cambia el botón anterior por uno con el símbolo "+". En caso de que se presione el botón con el símbolo "+" se vuelve a mostrar la definición de la función. Esto se puede ver en el siguiente prototipo de la aplicación:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/despuesColapsar.png)

Para ocultar el texto, se emplean tags sobre el texto en el buffer que lo vuelven "invisible"(http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextTag.html#v%3AtextTagInvisible), aunque en realidad no se lo borra.


## Macheo de paréntesis y de llaves [falta implementar]
En el caso de se ubique el cursor al lado de una apertura de paréntesis, se resalta dicha apertura de paréntesis junto con el paréntesis que cierra. Por otra parte, si no se cierra el paréntesis que abre, no se lo resalta.
Este mismo comportamiento se realiza con la apertura y cierre de llaves. Para el resaltado, se emplea el color amarillo como color de fondo del símbolo a resaltar; el color de la fuente no se modifica.
Esta funcionalidad se puede apreciar en el siguiente prototipo:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/parentesis.png)

## Búsqueda de palabras [falta implementar un boton y un cuadro para ingresar la palabra a buscar]
Junto con los botones mencionados anteriormente, se ofrece en la barra superior un campo en el cual se puede ingresar una cadena de caracteres a buscar. Al lado de dicho campo hay un botón que al presionarlo se resaltan en rojo aquellas cadenas coincidan con la que se esta buscando.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/busqueda.png)



## Dependencias del proyecto
El proyecto depende de las siguientes programas y librerías:
+ ghc
+ gtk
+ aspell
+ aspell-es
+ libaspell-dev
+ haspell
+ happy
+ haskell-src

Las mismas se pueden instalar utilizando el script para Linux "setupEnviroment.sh" que se encuentra junto con los archivos del proyecto.

## Compilación y ejecución del proyecto
Antes de compilar el programa, se necesitan tener instaladas las dependencias descriptas en el punto anterior.
Para compilar el programa, se utiliza el compilador de Haskell "ghc". En el script de Linux "correr.sh" se puede ver como se compila y se ejecuta el programa. En el mismo, el ejecutable que se obtienen se llama "app".

## Bibliografía
+ [1] http://www.muitovar.com/gtk2hs/index.html
+ [2] Bryan O'Sullivan, Don Stewart, and John Goerzen. Real World Haskell. O' Reilly, First Edition, 2009.
+ [3] Miran Lipovaca. Learn you a Haskell for great good. No starch press, 2011.
+ [4] http://blog.codeslower.com/static/CheatSheet.pdf
