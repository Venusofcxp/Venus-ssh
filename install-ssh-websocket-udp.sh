#!/bin/bash

# Cores para saída
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Função do menu
menu() {
    clear
    echo -e "${YELLOW}========= PAINEL DE GERENCIAMENTO =========${RESET}"
    echo -e "${GREEN}1. Reiniciar SSH${RESET}"
    echo -e "${GREEN}2. Reiniciar WebSocket${RESET}"
    echo -e "${GREEN}3. Abrir uma nova porta UDP${RESET}"
    echo -e "${GREEN}4. Sair${RESET}"
    echo -n "Escolha uma opção: "
    read opcao

    case $opcao in
        1) 
            echo -e "${GREEN}Reiniciando SSH...${RESET}"
            sudo systemctl restart ssh
            echo -e "${GREEN}SSH reiniciado!${RESET}"
            ;;
        2)
            echo -e "${GREEN}Reiniciando WebSocket...${RESET}"
            sudo systemctl restart ssh-websocket
            echo -e "${GREEN}WebSocket reiniciado!${RESET}"
            ;;
        3)
            echo -n "Digite a nova porta UDP para abrir: "
            read new_udp
            sudo ufw allow $new_udp/udp
            sudo ufw reload
            echo -e "${GREEN}Porta UDP $new_udp liberada!${RESET}"
            ;;
        4) 
            echo -e "${GREEN}Saindo...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${RESET}"
            ;;
    esac

    sleep 2
    menu
}

# Se for chamado com "menu", apenas executa o painel
if [[ "$1" == "menu" ]]; then
    menu
    exit 0
fi

echo -e "${YELLOW}========= INSTALAÇÃO INICIADA =========${RESET}"
echo -e "${GREEN}1. Atualizando sistema...${RESET}"
sudo apt update -y && sudo apt upgrade -y

echo -e "${GREEN}2. Instalando OpenSSH...${RESET}"
sudo apt install -y openssh-server

# Perguntar a porta do SSH
read -p "Digite a porta TCP para o SSH: " SSH_PORT
sudo sed -i "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config
sudo systemctl enable ssh
sudo systemctl restart ssh

echo -e "${GREEN}3. Criando usuário SSH...${RESET}"
read -p "Digite o nome de usuário SSH: " USERNAME
read -s -p "Digite a senha para $USERNAME: " PASSWORD
echo
sudo useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | sudo chpasswd
sudo usermod -aG sudo "$USERNAME"

echo -e "${GREEN}4. Instalando WebSocket (websocat)...${RESET}"
sudo apt install -y wget
wget -qO /usr/local/bin/websocat https://github.com/vi/websocat/releases/latest/download/websocat_amd64-linux
chmod +x /usr/local/bin/websocat

read -p "Digite a porta TCP para WebSocket: " WS_PORT
echo -e "${GREEN}5. Configurando WebSocket...${RESET}"
cat <<EOF | sudo tee /etc/systemd/system/ssh-websocket.service
[Unit]
Description=SSH over WebSocket
After=network.target

[Service]
ExecStart=/usr/local/bin/websocat -s $WS_PORT --basic-auth "$USERNAME:$PASSWORD" tcp:localhost:$SSH_PORT
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable ssh-websocket
sudo systemctl restart ssh-websocket

read -p "Deseja abrir uma porta UDP para jogos? (s/n): " OPEN_UDP
if [[ "$OPEN_UDP" == "s" ]]; then
    read -p "Digite a porta UDP para abrir: " UDP_PORT
    echo -e "${GREEN}6. Abrindo porta UDP $UDP_PORT...${RESET}"
    sudo ufw allow $UDP_PORT/udp
fi

echo -e "${GREEN}7. Configurando firewall...${RESET}"
sudo ufw allow $SSH_PORT/tcp
sudo ufw allow $WS_PORT/tcp
sudo ufw reload

# Criar o comando "menu" para abrir o painel
echo -e "${GREEN}8. Criando comando menu...${RESET}"
echo '#!/bin/bash' | sudo tee /usr/local/bin/menu > /dev/null
echo "bash <(curl -sL https://raw.githubusercontent.com/Venusofcxp/Venus-ssh/main/install-ssh-websocket-udp.sh) menu" | sudo tee -a /usr/local/bin/menu > /dev/null
sudo chmod +x /usr/local/bin/menu
sudo ln -sf /usr/local/bin/menu /usr/bin/menu

IP=$(curl -s ifconfig.me)
echo -e "${YELLOW}========= INSTALAÇÃO FINALIZADA =========${RESET}"
echo "Conecte-se via SSH: ssh $USERNAME@$IP -p $SSH_PORT"
echo "Conecte-se via WebSocket: ws://$IP:$WS_PORT (usuário: $USERNAME, senha: configurada)"
echo "Para abrir o painel, use o comando: ${GREEN}menu${RESET}"
if [[ "$OPEN_UDP" == "s" ]]; then
    echo "Porta UDP liberada: $UDP_PORT"
fi

exit 0
