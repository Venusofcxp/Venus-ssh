#!/bin/bash

# Script de instalação do bot IPTV

echo "Iniciando a instalação do bot IPTV..."

# Atualizando o sistema
sudo apt update -y
sudo apt upgrade -y

# Instalando dependências necessárias
echo "Instalando dependências..."
sudo apt install -y python3-pip python3-dev python3-venv git

# Criando um diretório para o projeto
cd /root
mkdir -p bot_iptv
cd bot_iptv

# Clonando o repositório do GitHub (substitua pelo seu repositório)
git clone https://raw.githubusercontent.com/Venusofcxp/Venus-ssh/refs/heads/main/bot_iptv.py .

# Instalando as dependências do Python
pip3 install -r requirements.txt

# Configurando o Flask e o Telegram Bot
echo "Configurando o Flask e o Telegram Bot..."
pip3 install flask python-telegram-bot

# Criando um arquivo para rodar o script Python
cat <<EOL > run_bot.sh
#!/bin/bash
echo "Iniciando o bot IPTV..."
python3 bot_iptv.py
EOL

# Tornando o arquivo executável
chmod +x run_bot.sh

# Configurando o Nginx
echo "Instalando e configurando o Nginx..."
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Adicionando configuração do Nginx (substitua conforme necessário)
cat <<EOL | sudo tee /etc/nginx/sites-available/iptv_bot
server {
    listen 80;
    server_name 187.102.244.59;  # Substitua pelo seu IP ou domínio

    location / {
        proxy_pass http://127.0.0.1:5000;  # Redirecionando para o Flask
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOL

# Habilitando o site no Nginx
sudo ln -s /etc/nginx/sites-available/iptv_bot /etc/nginx/sites-enabled/
sudo nginx -t  # Testar configuração do Nginx
sudo systemctl restart nginx

# Rodando o bot em segundo plano
echo "Rodando o bot em segundo plano..."
nohup ./run_bot.sh &

echo "Instalação concluída com sucesso!"
echo "O bot IPTV está em execução e o servidor Nginx está configurado."
