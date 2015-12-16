#!/bin/bash
rm -rf app
ghc --make main2.hs FileModule.hs -o app
./app
