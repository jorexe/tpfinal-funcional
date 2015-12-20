data Punto =Punto2D Float Float | Punto3D Float Float Float 


getX:: Punto -> Float
getX (Punto2D x y) = x
getX (Punto3D x y z)=x
