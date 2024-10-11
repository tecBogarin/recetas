#!/bin/bash

# Variables
NODE_VERSION="22"  # Reemplaza con la versión de Node.js que necesites
NVM_VERSION="v0.39.5"
FILE_NAME="proyecto.zip"  # Nombre con el que se guardará el archivo descargado

# Función para imprimir mensajes
function echo_message() {
    echo ">>> $1"
}

# 1. Descargar el archivo desde Google Drive usando curl
echo_message "Descargando el archivo desde GitHub..."
curl -L -o $FILE_NAME "https://codeload.github.com/tecBogarin/react_empty/zip/refs/heads/main"

# 2. Verificar si la descarga fue exitosa
if [ -f "$FILE_NAME" ]; then
    echo_message "Archivo descargado correctamente: $FILE_NAME"
else
    echo_message "Error al descargar el archivo."
    exit 1
fi

sudo apt update -y
sudo apt install  unzip -y

# 3. Extraer el archivo (si es un zip)
if [[ "$FILE_NAME" == *.zip ]]; then
    echo_message "Extrayendo el archivo $FILE_NAME..."
    unzip $FILE_NAME -d proyecto
    if [ $? -eq 0 ]; then
        echo_message "Archivo extraído correctamente."
    else
        echo_message "Error al extraer el archivo."
        exit 1
    fi
fi

# 3. Instalar nvm
echo_message "Instalando nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

# 4. Añadir las líneas de configuración de nvm al archivo .bashrc si no existen
if ! grep -q 'export NVM_DIR="$HOME/.nvm"' "$HOME/.bashrc"; then
    echo_message "Configurando nvm en ~/.bashrc..."
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Esto carga nvm' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Esto carga nvm bash_completion' >> ~/.bashrc
fi

# 5. Recargar ~/.bashrc para aplicar los cambios en la sesión actual
echo_message "Recargando ~/.bashrc..."
source ~/.bashrc

# 6. Instalar la versión especificada de Node.js
echo_message "Instalando Node.js versión $NODE_VERSION..."
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION

# 7. Verificar la instalación de Node.js y npm
echo_message "Verificando la instalación de Node.js y npm..."
node_version=$(node -v)
npm_version=$(npm -v)
echo_message "Node.js instalado: $node_version"
echo_message "npm instalado: $npm_version"

echo_message "Instalación completada con éxito."
