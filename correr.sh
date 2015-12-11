#!/bin/bash
rm -rf app
ghc --make main.hs -o app
./app
