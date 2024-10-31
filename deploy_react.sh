#!/bin/bash

# Verificar si se ha proporcionado la ruta del proyecto como argumento
if [ -z "$1" ]; then
  echo "Por favor, proporciona la URL del proyecto."
  exit 1
fi

PROJECT_URL="$1"

# Función para mostrar mensajes
messages() {
  echo "$1"
}

# Función para verificar e instalar dependencias
check_and_install() {
  local PACKAGE="$1"
  if ! dpkg -l | grep -q "$PACKAGE"; then
    messages "$PACKAGE no está instalado. Instalando..."
    sudo apt update -y
    sudo apt install -y "$PACKAGE"
  else
    messages "$PACKAGE ya está instalado."
  fi
}

# Función para instalar Node.js usando NVM
install_nodejs() {
  # Descargar e instalar NVM
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # Cargar NVM manualmente en el script
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"                   # Cargar nvm
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # Cargar auto-completado

  # Solicitar la versión de Node.js que desea instalar
  read -p "¿Cuál versión de Node.js deseas instalar? " version
  messages "La versión que instalaremos será: $version"

  # Instalar y usar la versión específica de Node.js
  nvm install "$version"
  nvm use "$version"
  nvm alias default "$version"
}

create_publish() {
  cd pruebasReact-main
  npm install
  npm run build
}

publish_nginx() {
  DOMAIN=$(hostname -I | awk '{print $1}')
  NGINX_ROOT="/var/www/html"
  sudo rm -rf "$NGINX_ROOT"/*
  sudo cp -r dist/* "$NGINX_ROOT/"
  sudo rm /etc/nginx/sites-available/default
  sudo rm /etc/nginx/sites-enabled/default
  sudo bash -c "cat > /etc/nginx/sites-available/react-app.conf" <<EOL
server {
    listen 80;
    server_name $DOMAIN; # Cambia esto por tu dominio o IP

    root $NGINX_ROOT;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }
}
EOL

  sudo ln -sf /etc/nginx/sites-available/react-app.conf /etc/nginx/sites-enabled/
  sudo systemctl restart nginx

}

# Verificar e instalar las dependencias necesarias
check_and_install "wget"
check_and_install "unzip"
check_and_install "nginx"
check_and_install "build-essential"
check_and_install "libssl-dev"

# Verificar si NVM está instalado, si no, instalarlo
if command -v nvm >/dev/null 2>&1; then
  messages "NVM está instalado. Versión: $(nvm --version)"
else
  install_nodejs
fi

# Descargar el archivo y descomprimirlo
sudo wget -O pruebasReact.zip "$PROJECT_URL"
unzip pruebasReact.zip
sudo rm pruebasReact.zip

create_publish

publish_nginx