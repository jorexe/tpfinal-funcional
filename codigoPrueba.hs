--CODIGO HASKELL DE EJEMPLO PARA PROBAR EL RESALTADO DE SINTAXIS

--esto deberia estar en el mismo color que el comentario: data, where
data Punto =Punto2D Float Float | Punto3D Float Float Float 

modulo:: Punto -> Float
modulo (Punto2D x y) = sqrt ( x^2 + y^2)
modulo (Punto3D x y z)= sqrt ( x^2 + y^2 +z^2)
	

resta':: Punto ->Punto ->Punto
resta' (Punto2D x1 y1) (Punto2D x2 y2) = Punto2D (x1-x2) (y1-y2)
resta' (Punto3D x1 y1 z1) (Punto3D x2 y2 z2) = Punto3D (x1-x2) (y1-y2) (z1-z2)

--función para obtener la distancia entre dos puntos
distanciaA:: Punto ->Punto -> Float
distanciaA punto1 punto2= modulo (resta' punto1 punto2)

doIncrement::Punto ->Punto
doIncrement (Punto2D x y)=Punto2D (x+1) (y+1)
doIncrement (Punto3D x y z)=Punto3D (x+1) (y+1) (z+1)
--
