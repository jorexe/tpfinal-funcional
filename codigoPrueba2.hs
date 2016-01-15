--Comentario
data Punto =Punto2D Float Float | Punto3D Float Float Float 


getX:: Punto -> Float
getX (Punto2D x y) = x
getX (Punto3D x y z)= x

sumX:: [Punto]->Float
sumX ((Punto2D x _ ):xs)=x + (sumX xs)
sumX ((Punto3D x _ _):xs)=x + (sumX xs)

something::Int->IO Int
something i = return i
