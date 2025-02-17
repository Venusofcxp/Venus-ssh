#!/bin/bash

# Atualizando o sistema
echo "Atualizando o sistema..."
apt update && apt upgrade -y

# Instalando dependências
echo "Instalando dependências..."
apt install -y python3 python3-pip git nginx

# Instalando o Flask, python-telegram-bot e outras bibliotecas necessárias
echo "Instalando pacotes Python..."
pip3 install flask python-telegram-bot requests

# Baixando o script do GitHub
echo "Clonando o repositório do GitHub..."
git clone https://raw.githubusercontent.com/Venusofcxp/Venus-ssh/refs/heads/main/bot_iptv.py

# Navegando até o diretório do projeto
cd /root/bot_iptv.py

# Configurando o arquivo de ambiente (como o IP da VPS)
echo "Atualizando configurações no script Python..."
sed -i 's/SEU_TOKEN_AQUI/SEU_TOKEN_DO_BOT/' bot_iptv.py
sed -i 's/SEU_IP_AQUI/$(curl -s ifconfig.me)/' bot_iptv.py

# Criando o diretório para armazenar as listas IPTV
mkdir -p /root/listas_iptv

# Iniciando o script do bot
echo "Iniciando o bot..."
python3 bot_iptv.py &

# Configurando Nginx
echo "Configurando o Nginx..."
cat <<EOL > /etc/nginx/sites-available/iptv
server {
    listen 80;
    server_name $HOSTNAME;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOL

ln -s /etc/nginx/sites-available/iptv /etc/nginx/sites-enabled/
systemctl restart nginx

echo "Instalação completa! O bot está em execução e o servidor Nginx está configurado."
