# tpfinal-funcional
Se toma como base el tutorial: http://www.muitovar.com/gtk2hs/index.html

## Funcionalidades básicas
Abrir archivo (con ventana de dialogo), guardarlo, editarlo.

## Ventana principal que contiene el texto
El texto del documento se carga en un label con letra negra.
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/base.png)
## Resaltador de sintaxis de haskell
https://wiki.haskell.org/Parsing_expressions_and_statements
https://www.haskell.org/onlinereport/syntax-iso.html


## Corrector ortográfico
Para detectar las palabras mal escritas, se emplea el código de http://www.serpentine.com/blog/2007/05/14/norvigs-spell-checker-and-idiomatic-haskell/; en dicho código esta implementado un algoritmo que recibe como parámetro una palabra y devuelve la palabra correcta de acuerdo al diccionario que se tenga.Si la palabra original y la corregida (obtenida con esta implementación) no coinciden, se detecta una palabra mal escrita. 

Para resaltar las palabras mal escritas se separa la palabra errónea en un label aparte  y se le cambia el color de la letra a rojo. Solo se destacaría la siguiente palabra mal escrita, no todas a la vez. También se muestra una sugerencia de una posible corrección. Para esa parte gráfica se emplea como base el tuturial en : http://www.muitovar.com/gtk2hs/chap5-3.html.

Antes de tocar el botón del corrector:

	
![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/antes.png)

Después de tocar el botón del corrector.

![Alt text](https://raw.githubusercontent.com/jorexe/tpfinal-funcional/master/prototipo/despues.png)

## Abrir archivo
