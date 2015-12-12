#!/bin/bash
rm -rf app
ghc --make main3.hs -o app
./app
