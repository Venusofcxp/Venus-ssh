#!/bin/bash

# Definições
PASTA_INSTALACAO="/root/listas_iptv"
SCRIPT_URL=""
SCRIPT_NOME="bot_iptv.py"

echo "🔧 Instalador IPTV - Iniciando instalação..."

# Atualizar pacotes
echo "📦 Atualizando pacotes..."
apt update && apt upgrade -y

# Instalar dependências necessárias
echo "📥 Instalando dependências..."
apt install -y python3 python3-pip nginx curl

# Criar pasta de instalação
echo "📂 Criando diretório $PASTA_INSTALACAO..."
mkdir -p "$PASTA_INSTALACAO"

# Baixar o script para a VPS
echo "⬇️ Baixando o script IPTV..."
curl -o "$PASTA_INSTALACAO/$SCRIPT_NOME" "$SCRIPT_URL"

# Instalar dependências Python
echo "🐍 Instalando bibliotecas Python..."
pip3 install flask python-telegram-bot

# Criar serviço systemd para rodar o bot automaticamente
echo "⚙️ Configurando serviço IPTV..."

cat <<EOF > /etc/systemd/system/bot_iptv.service
[Unit]
Description=Bot IPTV Telegram + Servidor Flask
After=network.target

[Service]
ExecStart=/usr/bin/python3 $PASTA_INSTALACAO/$SCRIPT_NOME
WorkingDirectory=$PASTA_INSTALACAO
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar o serviço
systemctl daemon-reload
systemctl enable bot_iptv
systemctl start bot_iptv

echo "✅ Instalação concluída! O bot IPTV está rodando."
