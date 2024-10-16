#!/bin/bash

# Verificar si se proporcionó un argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <version_node>"
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
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

# Cargar NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Esto carga nvm

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

# Actualiza los paquetes
echo "Actualizando el sistema..."
sudo apt update -y
sudo apt upgrade -y

# Instalar PostgreSQL
echo "Instalando PostgreSQL..."
sudo apt install postgresql postgresql-contrib -y

# Verifica que PostgreSQL esté corriendo
echo "Habilitando y verificando que PostgreSQL está corriendo..."
sudo systemctl enable postgresql
sudo systemctl start postgresql
# sudo systemctl status postgresql

# Configuración básica de PostgreSQL
echo "Configurando PostgreSQL..."
# Cambia la contraseña del usuario 'postgres'
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'TuContraseñaSegura';"

# Obtener la versión de PostgreSQL instalada
PG_VERSION=$(ls /etc/postgresql | sort -V | tail -n 1)

# Permitir acceso remoto editando el archivo pg_hba.conf
echo "Configurando acceso remoto a PostgreSQL..."
sudo bash -c "echo 'host    all             all             0.0.0.0/0            md5' >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf"
sudo bash -c "echo 'listen_addresses = '\''*'\'' ' >> /etc/postgresql/$PG_VERSION/main/postgresql.conf"

# Reiniciar el servicio de PostgreSQL para aplicar cambios
echo "Reiniciando PostgreSQL..."
sudo systemctl restart postgresql

# Mensaje final
echo "Instalación completada. PostgreSQL esta instalado."
# echo "Puedes acceder a pgAdmin en: http://<tu-ip-servidor>/pgadmin4"
echo "Recuerda usar la contraseña configurada para el usuario 'postgres'. pwd : TuContraseñaSegura"