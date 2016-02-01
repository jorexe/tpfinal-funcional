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
Abrir archivo (con ventana de dialogo), guardarlo, editarlo, pegar lo que se tenga en el clipboard (equivalente a presionar CTRL+C) a la ventana de edición de texto, copiar el texto seleccionado al clipboard.

## Interfaz gráfica

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/base.png)

En la parte superior de la ventana de la aplicación se encuentra una barra de herramientas con los botones que proveen las funcionalidades. Los iconos de dichos botones son los que vienen por defecto en la librería GTK [7].

El texto del documento se carga con letra negra en un TextView [8] .

En el siguiente diagrama se puede apreciar un esquema sobre la implementación de la interfaz gráfica. Dentro de la ventana principal se ubica una caja vertical que contiene los principales elementos gráficos ordenados en forma vertical: la barra de herramientas, un separador, y una caja horizontal. La caja horizontal contiene dos elementos alineados en forma horizontal: la tabla de botones para la función de colapsado de código, y la ventana de edición de texto (TextView).
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/images/Diagrama-Final programacion funcional.png)


## Resaltado de sintaxis de haskell

El módulo que se utiliza para realizar el parseo de la sintaxis de Haskel es "Language.Haskell.Parser"  [9].

Se emplea la función "parseModule" del parser "Language.Haskell.Parser" que viene en Haskell para parsear el código que viene del archivo. Si se obtiene un resultado de tipo "ParseOk" (el parseo del texto fue exitoso ya que presenta sintaxis de Haskell válida) se resalta gráficamente el código. Si se obtiene un resultado de tipo "ParseFailed" no se resalta el código.
La idea es que el resaltado de sintaxis se vea forma similar a como lo realiza el editor de texto "gedit", utilizando etiquetas en la ventana de edición de texto (TextView) para asignarle un color representativo a cada elemento de la sintaxis.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/gedit_haskell.png)

Los colores que se emplean sobre la fuente de las letras para representar elementos de la sintaxis son los siguientes:
+ nombre de función: negro en cursiva.
+ comentario: azul.
+ tipo de dato y constructores: verde.
+ las palabras reservadas ( por ejemplo "data"): marrón. La lista de estas palabras se obtuvo de [4] y es la siguiente: "case", "class", "data", "deriving", "do","else", "if", "import", "in", "infix", "infixl", "infixr","instance", "let", "of", "module", "newtype", "then", "type", "where".
+ el resto: en negro sin subrayado ni cursiva.

Esta funcionalidad se realiza en forma automática cuando se abre un archivo. En caso de que la sintaxis no sea válida, no se la resalta. En forma adicional, esta funcionalidad se puede activar con un botón en la barra de herramientas. Si luego de haberse realizado el resaltado de la sintaxis se realiza algún cambio sobre el texto, es necesario volver a presionar este botón para que se ajuste el resaltado al nuevo texto que se tiene.


## Corrector ortográfico
Para detectar las palabras mal escritas , se emplea la librería Aspell para Haskell (Haspell) [6]. Esta librería indica como incorrectas a aquellas palabras que no se encuentren en el diccionario que se esta empleando; la implementación hecha para este trabajo ofrece soporte para el diccionario español.

En cuanto al código, se lee el texto hasta que se encuentra un separador de palabras. Se considera como separador de palabras a los espacios, el símbolo ":" y el punto y coma. Cuando se encuentra un separador, se analiza el texto leido hasta dicho separador; en este sentido se emplea la función "spellCheckerWithOptions" de la librería Aspell para determinar si la palabra esta correctamente escrita. En caso de que dicha palabra no sea correcta, se procede a marcarla en la ventana de edición de texto.

Para marcar las palabras mal escritas se utilizan etiquetas en la ventana de edición de texto (TextView) del aplicativo, asignándoles color de letra rojo con italica. Se emplean iteradores que poseen la posición de comienzo y de fin de la palabra que se analiza en el buffer de la ventana de edición de texto; estos iteradores se especifican junto con la etiqueta para realizar el marcado. Por ejemplo, dado el siguiente texto con errores ortográficos la aplicación se ve de la siguiente manera antes de tocar el botón del corrector:

	
![Alt text](https://github.com/jorexe/tpfinal-funcional/blob/haskellSintax/prototipo/antes.png)

Después de tocar el botón del corrector se obtiene lo siguiente:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/despues.png)


NOTA:se puede editar mientras se este en modo de corrección. Luego de editar, es necesario volver a activar esta funcionalidad para que se actualice el marcado de la ortografía.

## Abrir archivo
Para abrir un archivo se debe tocar el botón correspondiente en la barra de herramientas. Al presionarlo, se abre una ventana de diálogo que permite elegir el archivo que se desea abrir. Una vez seleccionado el archivo, se carga el contenido del mismo en la ventana de edición de texto.

En cuanto al código, lo que se realiza internamente es utilizar la función "openFile" del módulo "System.IO" para abrir el archivo en modo lectura. Como resultado de esto, se obtiene un "Handle"; mas tarde se obtiene el texto del archivo empleando la función "hGetContents" la cual recive como parámetro el handle.
Una vez que se tiene el contenido del archivo, se lo carga en el buffer de la ventana de edición de texto (TextView http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html). Por último, se cierra el handle. 

## Guardar un archivo
Para utilizar esta funcionalidad se debe presionar el correspondiente botón en la barra de herramientas. Al presionarlo se abre una ventana que permite elegir el nombre y la ubicación del archivo que se desea guardar. Luego de confirmar estos datos, se guarda el contenido de la ventana de edición de texto (TextView) en un archivo.

Internamente se extrae el texto de la ventana de edición, y se emplea la función "writeFile" del módulo "System.IO" de Haskell para grabar este texto en archivo con el nombre y ubicación indicados. 

## Nuevo archivo.
Se borra el contenido del buffer (http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextBuffer.html#v%3AtextBufferDelete) de la ventana de edición de texto (TextView). También se eliminan los botones del colapsado de código que hayan quedado del archivo que se tenía abierto.

## Copiar 
Se copia en el clipboard, lo que se haya seleccionado de la ventana principal de edición de texto. Para lograr esto, se obtiene el clipboard de selección de la interfaz gráfica y el clipboard general del sistema operativo. Por último,  el texto seleccionado en el clipboard de la interfaz gráfica (texto marcado en la ventana de edición) se graba en el clipboard del sistema operativo.

## Pegar
Se copia el contenido del clipboard en la posición del cursor en la ventana de edición de texto. Internamente, se obtiene el clipboard del sistema operativo, se obtiene el texto que se encuentra en dicho clipboard y por último se lo copia en el buffer de la ventana de edición de texto.
## Colapsar definiciones.
Cuando se tiene el texto resaltado con la sintaxis de Haskell, se ofrece la posibilidad de colapsar las definiciones de funciones de Haskell. Se muestra un botón con el símbolo "[-]" en el margen izquierdo de la línea donde esta definida la función. Esto se puede apreciar en la siguiente captura de pantalla:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/antesColapsar.png)


Cuando se presiona dicho botón,  se colapsa la definición completa de la función y solo se deja el nombre; luego de realizar esto, dicho botón queda oscurecido para indicar que la función se encuentra activada.  Esto se puede ver en la siguiente captura de pantalla de la aplicación:

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/haskellSintax/prototipo/despuesColapsar.png)

En caso de que se vuelva a presionar el botón, se vuelve a mostrar la definición de la función y botón vuelve a su estado anterior (no oscurecido para indicar que no esta activada esta funcionalidad).

Al presionar estos botones, si se colapsa una o más líneas debajo de una función, los botones de las funciones que se encuentran debajo de la primera deben ser movidos hacia arriba en la misma proporción de líneas que se colapsaron. Cuando se realiza el proceso inverso ( se desactiva el colapsado del código sobre una función), se mueven hacia abajo los botones de las funciones que se encuentran abajo de la función a la cual se le restauran la definición.

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
+ TagsModule: modulo que implementa distintas marcas que se utilizan en varios módulos y que se pueden aplicar sobre partes del texto.

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

Las mismas se pueden instalar utilizando el script para Linux "setupEnviroment.sh" que se encuentra junto con los archivos del proyecto. El mismo fue utilizado exitosamente en la distribución de linux "Ubuntu 14.04" .

## Compilación y ejecución del proyecto
Antes de compilar el programa, se necesitan tener instaladas las dependencias descriptas en el punto anterior.
Para compilar el programa, se utiliza el compilador de Haskell "ghc" ("Glasgow Haskell compiler"). En el script de Linux "correr.sh" se puede ver como se compila y se ejecuta el programa. En el mismo, el ejecutable que se obtienen se llama "app".

## Bibliografía
+ [1] http://www.muitovar.com/gtk2hs/index.html
+ [2] Bryan O'Sullivan, Don Stewart, and John Goerzen. Real World Haskell. O' Reilly, First Edition, 2009.
+ [3] Miran Lipovaca. Learn you a Haskell for great good. No starch press, 2011.
+ [4] http://blog.codeslower.com/static/CheatSheet.pdf
+ [5] Gideon Sireling. Graphical user interfaces in Haskell. 2011.
+ [6] Haspell: Haskell bindings to Aspell.
+ https://hackage.haskell.org/package/haspell-1.1.0/docs/doc-index.html
+ [7] Stock Items. The gtk Class Reference.
+ http://www.pygtk.org/pygtk2reference/gtk-stock-items.html
+ [8] TextView.
+ http://projects.haskell.org/gtk2hs/docs/devel/Graphics-UI-Gtk-Multiline-TextView.html
+ [9] Haskell parser.
+ https://hackage.haskell.org/package/haskell-src-1.0.2.0/docs/Language-Haskell-Parser.html
