#!/bin/bash

# Verificar si se ha pasado la URL del proyecto como parámetro
if [ -z "$1" ]; then
  echo "Uso: $0 <URL del proyecto ReactJS>"
  exit 1
fi

# Definir la URL del proyecto
PROJECT_URL=$1

# Directorio donde se almacenará el proyecto descargado
PROJECT_DIR="/var/www/react-app"

# Función para verificar si un paquete está instalado e instalarlo si es necesario
check_and_install() {
  PACKAGE=$1
  if ! dpkg -l | grep -q "$PACKAGE"; then
    echo "$PACKAGE no está instalado. Instalando..."
    sudo apt update
    sudo apt install -y "$PACKAGE"
  else
    echo "$PACKAGE ya está instalado."
  fi
}

# Verificar e instalar wget si no está instalado
check_and_install "wget"

# Verificar e instalar unzip si no está instalado
check_and_install "unzip"

# Instalar Nginx si no está instalado
check_and_install "nginx"

# Crear el directorio para el proyecto si no existe
if [ ! -d "$PROJECT_DIR" ]; then
  sudo mkdir -p "$PROJECT_DIR"
fi

# Descargar el proyecto React desde la URL proporcionada
echo "Descargando el proyecto React desde: $PROJECT_URL"
sudo wget -O /tmp/react-project.zip "$PROJECT_URL"

# Descomprimir el proyecto en el directorio web
sudo unzip /tmp/react-project.zip -d "$PROJECT_DIR"
sudo rm /tmp/react-project.zip

# Configurar Nginx para servir el proyecto
NGINX_CONF="/etc/nginx/sites-available/react-app"
sudo bash -c "cat > $NGINX_CONF" << EOL
server {
    listen 80;
    server_name _;

    root $PROJECT_DIR/pruebasReact-main;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }
}
EOL

# Eliminar el archivo simbólico si ya existe
if [ -L /etc/nginx/sites-enabled/react-app ]; then
  sudo rm /etc/nginx/sites-enabled/react-app
fi

# Crear el enlace simbólico
sudo ln -s /etc/nginx/sites-available/react-app /etc/nginx/sites-enabled/

# Deshabilitar la configuración por defecto de Nginx para evitar conflictos
if [ -f /etc/nginx/sites-enabled/default ]; then
  sudo rm /etc/nginx/sites-enabled/default
fi

# Verificar la configuración de Nginx
sudo nginx -t

# Reiniciar Nginx para aplicar la nueva configuración
sudo systemctl restart nginx

echo "Instalación completada. El proyecto ReactJS está siendo servido por Nginx."
