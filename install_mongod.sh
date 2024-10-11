#! /bin/bash

# Verificar gnupg
if which gpg >/dev/null; then
    echo "gnupg está instalado."
else
    echo "gnupg no está instalado."
    sudo apt install gnupg -y
fi

# Verificar curl
if which curl >/dev/null; then
    echo "curl está instalado."
else
    echo "curl no está instalado."
    sudo apt install curl -y
fi

# To import the MongoDB public GPG key, run the following command:
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor


resultadoRelease=$(lsb_release -c | awk '{print $2}')

# Comprobar el resultado
if [ "$resultadoRelease" == "noble" ]; then
    echo "entro en noble"
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
elif [ "$resultadoRelease" == "focal" ]; then
    echo "entro en focal"
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
elif [ "$resultadoRelease" == "Jammy" ]; then
    echo "entro en focal"
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
else
    echo "No sé si falló"
    exit
fi

sudo apt-get update -y

sudo apt install -y mongodb-org

sudo systemctl status mongod