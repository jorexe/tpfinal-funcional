# tp final-programación funcional

***Jorge Gomez, Fernando Bejarano***

En el presente informe, se detalla la implementación de un editor de texto con interfaz gráfica en lenguaje Haskell. 
Se emplea la librería gráfica GTK2HS ya que la misma es bastante madura y posee una excelente documentación. Otras librerías analizadas para realizar la implementación fueron: WxHaskell y QtHaskell [5]; las misma fueron descartadas debido a que ...COMPLETAR ESTO!!!.
Se toma como base el tutorial [1].

## LO QUE FALTA
+ Emprolijar este informe
+ Ponerle a este informe la presentación que piden los profesores.
+ Para implementar la búsqueda de palabras, falta poner en la barra de herramientas un cuadro para ingresar el texto y un botón para activar la búsqueda de la palabra. Una vez que se tiene la palabra a buscar, usar la función "markWord" (esta en el archivo "SearchModule.hs") que ya esta implementada y que te marca la palabra que le pases como parámetro.
+ implementar el marcado de paréntesis.
+ probar el programa a fondo.
+ ver como es el tema del scroleo. Ahora no esta implementado. Si el texto no entra en pantalla, no se ve por mas que se haga bajar el cursor.
+ actualizar todas las capturas de pantalla con la última versión de la aplicación. No van mas los prototipos, se tiene que ver la versión final.
+ Las capturas de pantalla de la versión final, van en la carpeta "images".
+ Los links no deberían estar sueltos por el informe, deberían estar bien citados como la introducción de mas arriba (usando corchetes y un numero)y la correspondiente entrada en bibliografía.

## Funcionalidades básicas
Abrir archivo (con ventana de dialogo), guardarlo, editarlo, pegar lo que se tenga en el clipboard (equivalente a presionar CTRL+C), copiar lo que se haya seleccionado al clipboard.

## Interfaz gráfica
El texto del documento se carga en un TextView (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html)
 con letra negra.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/base.png)

En la parte superior se encuentran botones con las funcionalidades. Los iconos de dichos botones son los que vienen por defecto en la librería GTK (http://www.pygtk.org/pygtk2reference/gtk-stock-items.html).

En el siguiente diagrama se puede apreciar un esquema sobre la implementación de la interfaz gráfica. Dentro de la ventana principal se ubica una caja vertical que contiene los principales elementos gráficos ordenados en forma vertical: barra de herramientas, un separador, y una caja horizontal. La caja horizontal contiene dos elementos alineados en forma horizontal: la tabla de botones para la función de colapsado de código, y la ventana de edición de texto.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/images/Diagrama-Final programacion funcional.png)

## Resaltado de sintaxis de haskell
https://hackage.haskell.org/package/haskell-src-1.0.2.0/docs/Language-Haskell-Parser.html

Se emplea la función "parseModule" del parser "Language.Haskell.Parser" que viene en Haskell para parsear el código que viene del archivo. Si se obtiene como resultado un "ParseOk" (el parseo del texto fue exitoso ya que presenta sintaxis de Haskell válida) se resalta gráficamente el código. Si se obtiene "ParseFailed" no se resalta el código.
La idea es que el resaltado de sintaxis se vea forma similar a como lo realiza el editor de texto "gedit", utilizando tags en la ventana de edición de texto (TextView) para asignarle un color representativo a cada elemento de la sintaxis.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/gedit_haskell.png)

Los colores que se emplean sobre la fuente de las letras son los siguientes:
+ nombre de función: negro en cursiva .
+ comentario: azul.
+ tipo de dato y constructores: verde.
+ las palabras reservadas ( por ejemplo "data"): marrón. La lista de estas palabras se obtuvo de [4].
+ el resto: en negro sin subrayado ni cursiva.

Esta funcionalidad se realiza en forma automática cuando se abre un archivo; en caso de que la sintaxis sea válida se la resalta. En forma adicional, se puede activar con un botón en la barra de herramientas. Si luego de haberse realizado el resaltado de la sintaxis se realiza algún cambio sobre el texto, es necesario volver a presionar este botón para que se ajuste el resaltado al nuevo texto que se tiene.


## Corrector ortográfico
Para detectar las palabras mal escritas, se emplea la librería Aspell para Haskell (Haspell) :https://hackage.haskell.org/package/haspell-1.1.0/docs/doc-index.html

Para resaltar las palabras mal escritas se utilizan etiquetas en la ventana de edición de texto (TextView) del aplicativo, asignándoles color de letra rojo a las palabras que no se encuentren en el diccionario.

Antes de tocar el botón del corrector:

	
![Alt text](https://github.com/jorexe/tpfinal-funcional/blob/haskellSintax/prototipo/antes.png)

Después de tocar el botón del corrector se obtiene lo siguiente:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/despues.png)


NOTA:se puede editar mientras se este en modo de corrección.

## Abrir archivo
Para abrir un archivo se debe tocar el botón correspondiente en la barra de herramientas. Al presionarlo, se abre una ventana que permite elegir el archivo que se desea abrir. Una vez seleccionado el archivo, se emplea la función readFile de Haskell para leerlo. Luego se carga el contenido del archivo en el buffer de la ventana de edición de texto (TextView http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html).

## Guardar un archivo
Para utilizar esta funcionalidad se debe presionar el correspondiente botón en la barra de herramientas.Al presionarlo se abre una ventana que permite elegir el nombre y la ubicación del archivo que se desea guardar. Después se emplea la función writeFile de Haskell para guardar el contenido de la ventana de edición de texto (TextView) en el archivo. 

## Nuevo archivo.
Se borra el contenido del buffer (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextBuffer.html#v%3AtextBufferDelete) de la ventana de edición de texto (TextView). También se eliminan los botones del colapsado de código que hayan quedado del archivo que se tenía abierto.

## Copiar 
Se copia en el clipboard, lo que se haya seleccionado de la ventana principal de edición de texto.

## Pegar
Se copia el contenido del clipboard en la posición del cursor en la ventana de edición de texto.

## Colapsar definiciones.
Cuando se tiene el texto resaltado con la sintaxis de Haskell, se ofrece la posibilidad de colapsar las definiciones de funciones. Se muestra un botón con el símbolo "[-]" en el margen izquierdo de la línea donde esta definida la función. Esto se puede apreciar en el siguiente captura de pantalla:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/antesColapsar.png)


Cuando se presiona dicho botón,  se colapsa la definición completa de la función y solo se deja el nombre; luego de realizar esto, dicho botón queda oscurecido para indicar que la función se encuentra activada.  Esto se puede ver en la siguiente captura de pantalla de la aplicación:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/despuesColapsar.png)

En caso de que se vuelva a presionar el botón, se vuelve a mostrar la definición de la función y botón vuelve a su estado anterior (no oscurecido para indicar que no esta activada esta funcionalidad).

Al presionar estos botones, si se colapsa una o más líneas debajo de una función, los botones de las funciones que se encuentran debajo de la primera deben ser movidos hacia arriba en la misma proporción de líneas. Cuando se realiza el proceso inverso ( se desactiva el colapsado del código sobre una función), se mueven hacia abajo los botones de las funciones que se encuentran abajo de la función a la cual se le aplica esta funcionalidad.

Para ocultar el texto, se emplean etiquetas sobre el texto en el buffer de la ventana de edición que lo vuelven "invisible" (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextTag.html#v%3AtextTagInvisible), aunque en realidad no se lo borra. Para volver a mostrar este texto, simplemente se quitan estas marcas y luego el texto vuelve a ser visible en la la ventana de edición.


## Macheo de paréntesis y de llaves [falta implementar]
En el caso de se ubique el cursor al lado de una apertura de paréntesis, se resalta dicha apertura de paréntesis junto con el paréntesis que cierra. Por otra parte, si no se cierra el paréntesis que abre, no se lo resalta.
Este mismo comportamiento se realiza con la apertura y cierre de llaves. Para el resaltado, se emplea el color amarillo como color de fondo del símbolo a resaltar; el color de la fuente no se modifica.
Esta funcionalidad se puede apreciar en el siguiente prototipo:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/parentesis.png)

## Búsqueda de palabras [falta implementar un botón y un cuadro para ingresar la palabra a buscar, lo otro esta]
Junto con los botones mencionados anteriormente, se ofrece en la barra superior un campo en el cual se puede ingresar una cadena de caracteres a buscar. Al lado de dicho campo hay un botón que al presionarlo se resaltan en rojo aquellas cadenas coincidan con la que se esta buscando.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/busqueda.png)

## Códigos y módulos implementados
+ Main2.hs: es el código principal de la aplicación. En el mismo se inicializa la interfaz gráfica y se inicializan las funciones que se pueden realizar con los botones de la barra de herramientas.
+ ClipboardModule.hs: implementa las operaciones de copiar al clipboard y pegar desde el clipboard.
+ FileModule.hs: implementa la lectura y escritura de archivos.
+ FoldingModule.hs: modulo que realiza la función de colapsado de código de una función.
+ SearchModule: implementa la búsqueda y el marcado de palabras.
+ SpellingModule.hs: implementa la corrección ortográfica.
+ SyntaxHighlightModule.hs: contiene la implementación del parseo y marcado de la sintaxis de Haskell.
+ SyntaxUtilsModule.hs: contiene funciones de uso común para los módulos "SyntaxHighlightModule.hs" y "FoldingModule.hs".
+ TagsModule: modulo que implementa tipos de tags que se utilizan en varios módulos.

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

Las mismas se pueden instalar utilizando el script para Linux "setupEnviroment.sh" que se encuentra junto con los archivos del proyecto. El mismo fue utilizado exitosamente en Ubuntu 14.04 .

## Compilación y ejecución del proyecto
Antes de compilar el programa, se necesitan tener instaladas las dependencias descriptas en el punto anterior.
Para compilar el programa, se utiliza el compilador de Haskell "ghc" ("Glasgow Haskell compiler"). En el script de Linux "correr.sh" se puede ver como se compila y se ejecuta el programa. En el mismo, el ejecutable que se obtienen se llama "app".

## Bibliografía
+ [1] http://www.muitovar.com/gtk2hs/index.html
+ [2] Bryan O'Sullivan, Don Stewart, and John Goerzen. Real World Haskell. O' Reilly, First Edition, 2009.
+ [3] Miran Lipovaca. Learn you a Haskell for great good. No starch press, 2011.
+ [4] http://blog.codeslower.com/static/CheatSheet.pdf
+ [5] Gideon Sireling. Graphical user interfaces in Haskell. 2011.
