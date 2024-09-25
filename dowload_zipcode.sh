#!/bin/bash

# Definir variables
FILE_ID="1cnbNPTmyvueZilIHcsUPwN_HgkpAL4PB"
OUTPUT_FILE="archivo_descargado.txt"
CONVERTED_FILE="archivo_convertido_utf8.txt"

# Descargar el archivo desde Google Drive usando curl
curl -L "https://drive.google.com/uc?export=download&id=${FILE_ID}" -o ${OUTPUT_FILE}

# Verificar si curl fue exitoso
if [ $? -eq 0 ]; then
    echo "Archivo descargado exitosamente: ${OUTPUT_FILE}"

    # Convertir el archivo de ISO-8859-1 a UTF-8 usando iconv
    iconv -f ISO-8859-1 -t UTF-8 ${OUTPUT_FILE} -o ${CONVERTED_FILE}

    # Verificar si iconv fue exitoso
    if [ $? -eq 0 ]; then
        echo "Archivo convertido a UTF-8 exitosamente: ${CONVERTED_FILE}"
    else
        echo "Error al convertir el archivo con iconv."
    fi
else
    echo "Error al descargar el archivo con curl."
fi
