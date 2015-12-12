# tpfinal-funcional
Se toma como base el tutorial: http://www.muitovar.com/gtk2hs/index.html
Se emplea la librería gráfica GTK2HS.
## Funcionalidades básicas
Abrir archivo (con ventana de dialogo), guardarlo, editarlo, pegar lo que se tenga en el clipboard (equivalente a hacer CTRL+C).

## Ventana principal que contiene el texto
El texto del documento se carga en un label con letra negra.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/base.png)
En la parte superior se encuentran botones con las funcionalidades. En el borde izquierdo se muestran los número de línea.
Para agregar las letras que se ingresan por el teclado y para desplazar el cursor dentro del documento con las flechas del teclado, se crea un "eventBox" y dentro del mismo se inserta el label que contiene el texto. Al "eventBox" se le agrega un manejador de eventos para los inputs provenientes del teclado. Se emplea como referencia: http://www.muitovar.com/gtk2hs/chap6-2.html.
Nota:para facilitar el desarrollo del programa, no se muestra la posición del cursor dentro del texto.
## Resaltador de sintaxis de haskell
https://hackage.haskell.org/package/haskell-src-1.0.2.0/docs/Language-Haskell-Parser.html

Se emplea la función "parseModule" del parser "Language.Haskell.Parser" que viene en Haskell para parsear el código que viene del archivo. Si se obtiene como resultado un "ParseOk" se resalta gráficamente el código. Si se obtiene "ParseFailed" no se resalta el código.
La idea es que se vea forma similar a como lo realiza gedit.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/gedit_haskell.png)

Para lograr esto, cada palabra se pondrá en un label y, dependiendo del tipo de elemento de la sintaxis que representa, se le asignará un color. Para el coloreado de un label: http://www.muitovar.com/gtk2hs/chap5-3.html.
Para juntar multiples labels se utiliza "packing":http://www.muitovar.com/gtk2hs/chap3-2.html.

## Corrector ortográfico
Para detectar las palabras mal escritas, se emplea la librería Aspell para Haskell :https://hackage.haskell.org/package/haspell-1.1.0/docs/doc-index.html

Para resaltar las palabras mal escritas se separa la palabra errónea en un label aparte  y se le cambia el color de la letra a rojo. Solo se destacaría la siguiente palabra mal escrita, no todas a la vez.  Para esa parte gráfica se emplea como base el tuturial en : http://www.muitovar.com/gtk2hs/chap5-3.html.

Antes de tocar el botón del corrector:

	
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/antes.png)

Después de tocar el botón del corrector por primera vez.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/despues.png)

Si se presiona el botón "Salir de corrección" se vuelve al estado inicial.
NOTA:no se puede editar mientras se este en modo de correción.

## Abrir archivo
Se emplea la función readFile de Haskell.

