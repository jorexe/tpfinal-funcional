#!/bin/bash
sudo apt-get install ghc
sudo apt-get install libghc-gtk-dev

#programas necesarios para el corrector ortografico Haspell.
sudo apt-get install aspell
sudo apt-get install aspell-es
sudo apt-get install libaspell-dev
sudo apt-get install cabal-install
cabal update
cabal install haspell

