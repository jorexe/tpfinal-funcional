import System.IO
main = do
	handle <- openFile "archivoPrueba.txt" ReadMode
	contents <- hGetContents handle
	putStr contents
	hClose handle
