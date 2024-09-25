#!/bin/bash
# Script para instalar PostgreSQL y pgAdmin en Ubuntu Server 24.04

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

# # Instalación de pgAdmin
# echo "Instalando pgAdmin..."
# curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo tee /etc/apt/trusted.gpg.d/pgadmin.asc
# sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/focal pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
# sudo apt install pgadmin4-web -y

# # Configurar pgAdmin
# echo "Configurando pgAdmin..."
# sudo /usr/pgadmin4/bin/setup-web.sh

# Mensaje final
echo "Instalación completada. PostgreSQL esta instalado."
# echo "Puedes acceder a pgAdmin en: http://<tu-ip-servidor>/pgadmin4"
echo "Recuerda usar la contraseña configurada para el usuario 'postgres'. pwd : TuContraseñaSegura"

#
# chmod +x install_postgresql_pgadmin.sh
