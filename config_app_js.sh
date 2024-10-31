#!/bin/bash

# Verificar si se proporcionó un argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <version_node>"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Uso: $0 <version_node>  <URL del proyecto ReactJS>"
  exit 1
fi

# Verificar si curl está instalado
if ! command -v curl > /dev/null; then
  echo "Error: curl no está instalado. Instalándo"
  sudo apt install curl -y
fi

# Verificar si NGINX está instalado
echo "Verificando si NGINX está instalado..."
if ! command -v nginx > /dev/null; then
  echo "Instalando NGINX..."

  # Detectar el sistema operativo e instalar nginx
  if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    sudo apt update
    sudo apt install -y nginx
  elif [ -f /etc/redhat-release ]; then
    # CentOS/Fedora/RHEL
    sudo yum install -y nginx
  elif [ -f /etc/arch-release ]; then
    # Arch Linux
    sudo pacman -Syu --noconfirm nginx
  else
    echo "Sistema operativo no soportado para la instalación automática de NGINX."
    exit 1
  fi

  # Iniciar y habilitar NGINX
  sudo systemctl start nginx
  sudo systemctl enable nginx

  echo "NGINX instalado y en ejecución."
else
  echo "NGINX ya está instalado."
fi

# Versión de Node.js
NODE_VERSION=$1

# Instalar NVM
echo "Instalando NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Cargar NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Esto carga nvm

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

# Verificar si NVM se instaló correctamente
if ! command -v nvm > /dev/null; then
    echo "Error: NVM no se instaló correctamente."
    exit 1
fi

# Instalar la versión de Node.js solicitada
echo "Instalando Node.js versión $NODE_VERSION..."
nvm install "$NODE_VERSION"

# Usar la versión instalada por defecto
nvm use "$NODE_VERSION"

# Establecer la versión instalada como la predeterminada
nvm alias default "$NODE_VERSION"

# Verificar instalación
echo "Versión de Node.js instalada:"
node -v

echo "Versión de NPM instalada:"
npm -v

echo "Instalación completada con éxito."

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

cd $PROJECT_DIR/pruebasReact-main
npm install && npm run build

# Configurar Nginx para servir el proyecto
NGINX_CONF="/etc/nginx/sites-available/react-app"
sudo bash -c "cat > $NGINX_CONF" << EOL
server {
    listen 80;
    server_name _;

    root $PROJECT_DIR/pruebasReact-main/dist;
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