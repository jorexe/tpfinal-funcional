# tpfinal-funcional
Se toma como base el tutorial: http://www.muitovar.com/gtk2hs/index.html
Se emplea la librería gráfica GTK2HS.
## Funcionalidades básicas
Abrir archivo (con ventana de dialogo), guardarlo, editarlo, pegar lo que se tenga en el clipboard (equivalente a hacer CTRL+C).

## Ventana principal que contiene el texto
El texto del documento se carga en un TextView con letra negra.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/base.png)
En la parte superior se encuentran botones con las funcionalidades. En el borde izquierdo se muestran los número de línea.

## Resaltador de sintaxis de haskell
https://hackage.haskell.org/package/haskell-src-1.0.2.0/docs/Language-Haskell-Parser.html

Se emplea la función "parseModule" del parser "Language.Haskell.Parser" que viene en Haskell para parsear el código que viene del archivo. Si se obtiene como resultado un "ParseOk" se resalta gráficamente el código. Si se obtiene "ParseFailed" no se resalta el código.
La idea es que se vea forma similar a como lo realiza gedit, utilizando tags en el TextView para asignarle un color representativo a la sintaxis.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/gedit_haskell.png)

## Corrector ortográfico
Para detectar las palabras mal escritas, se emplea la librería Aspell para Haskell :https://hackage.haskell.org/package/haspell-1.1.0/docs/doc-index.html

Para resaltar las palabras mal escritas se utilizarian tags en el TextView del aplicativo, asignandoles color rojo a las palabras que no se encuentren en el diccionario.

Antes de tocar el botón del corrector:

	
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/antes.png)

Después de tocar el botón del corrector por primera vez.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/despues.png)

Si se presiona el botón "Salir de corrección" se vuelve al estado inicial.
NOTA:no se puede editar mientras se este en modo de correción.

## Abrir archivo
Se emplea la función readFile de Haskell.

