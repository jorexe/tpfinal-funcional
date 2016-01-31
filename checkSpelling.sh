#!/bin/bash
echo 'Revisando errores de ortografía en el informe'
 aspell list --lang=es < ./README.md
