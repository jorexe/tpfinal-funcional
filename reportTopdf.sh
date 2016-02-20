#!/bin/bash
echo 'pasando el informe a pdf'

pandoc README.md -o Informe.pdf --toc --number-sections
