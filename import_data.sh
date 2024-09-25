#!/bin/bash

# Verifica si se pasó un parámetro para la ruta
if [ -z "$1" ]; then
    echo "Por favor proporciona la ruta al archivo."
    exit 1
fi

# Asigna el primer parámetro a una variable
FILE_PATH=$1

# Crear un archivo temporal para almacenar el archivo sin las dos primeras líneas
TMP_FILE="/tmp/archivo_convertido_utf8.txt"

# Eliminar las dos primeras líneas y guardar el resultado en el archivo temporal
sed '1,2d' "$FILE_PATH" > "$TMP_FILE"

# Asegurar permisos de lectura en /tmp/
sudo chmod 644 "$TMP_FILE"

# Cambiar al usuario postgres y ejecutar comandos como postgres
sudo -u postgres bash <<EOF

# Eliminar la base de datos si existe
psql -c "DROP DATABASE IF EXISTS tallersistemasoperativos;"

# Crear la base de datos
psql -c "CREATE DATABASE tallersistemasoperativos;"

# Esperar un momento para que la base de datos se cree correctamente
sleep 2

# Conectarse a la base de datos y eliminar la tabla si existe
psql -d tallersistemasoperativos -c "DROP TABLE IF EXISTS datos;"

# Crear la tabla nuevamente
psql -d tallersistemasoperativos -c "
CREATE TABLE datos (
    d_codigo VARCHAR,
    d_asenta VARCHAR,
    d_tipo_asenta VARCHAR,
    D_mnpio VARCHAR,
    d_estado VARCHAR,
    d_ciudad VARCHAR,
    d_CP VARCHAR,
    c_estado VARCHAR,
    c_oficina VARCHAR,
    c_CP VARCHAR,
    c_tipo_asenta VARCHAR,
    c_mnpio VARCHAR,
    id_asenta_cpcons VARCHAR,
    d_zona VARCHAR,
    c_cve_ciudad VARCHAR
);"

# Cargar los datos desde el archivo CSV en la tabla 'datos'
psql -d tallersistemasoperativos -c "\copy datos FROM '$TMP_FILE' WITH (FORMAT csv, HEADER true, DELIMITER '|');"

EOF

echo "Base de datos y tabla recreadas con éxito. Datos cargados desde $TMP_FILE."