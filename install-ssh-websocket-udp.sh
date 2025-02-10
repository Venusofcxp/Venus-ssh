#!/bin/bash

# Cores para destaque
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
RESET="\e[0m"

# Função para exibir o painel principal
menu() {
    clear

    # Obtendo informações do sistema
    OS=$(lsb_release -d | cut -f2-)
    RAM_TOTAL=$(free -m | awk '/^Mem/ {print $2}')
    RAM_USO=$(free -m | awk '/^Mem/ {print $3}')
    CPU_CORES=$(nproc)
    CPU_USO=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    ONLINE=$(who | wc -l)
    TOTAL_USERS=$(grep -c '^' /etc/passwd)
    EXPIRED_USERS=$(find /etc/ -name "shadow" -exec awk -F: '($2=="!!"){print $1}' {} \; | wc -l)
    HORA=$(date +"%T")

    # Layout do painel
    echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "${CYAN}┃               ⇱ VENUS PRO ⇲               ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${RESET}"
    echo -e "${CYAN}┃ SISTEMA           MEMORIA RAM       PROCESSADOR  ┃${RESET}"
    echo -e "${CYAN}┃ OS: ${GREEN}$OS${CYAN}  Total: ${GREEN}${RAM_TOTAL}MB${CYAN}   Núcleos: ${GREEN}${CPU_CORES}${CYAN}    ┃${RESET}"
    echo -e "${CYAN}┃ Hora: ${GREEN}${HORA}${CYAN}    Em Uso: ${GREEN}${RAM_USO}MB${CYAN}    CPU: ${GREEN}${CPU_USO}%${CYAN}    ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${RESET}"
    echo -e "${CYAN}┃ Onlines: ${GREEN}${ONLINE}${CYAN}        Expirados: ${GREEN}${EXPIRED_USERS}${CYAN}      Total: ${GREEN}${TOTAL_USERS}${CYAN}      ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${RESET}"

    echo -e "${CYAN}┃ [${RED}01${RESET}] • CRIAR USUÁRIO        [${RED}13${RESET}] • SPEEDTEST     ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}02${RESET}] • CRIAR TESTE          [${RED}14${RESET}] • OTIMIZAR      ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}03${RESET}] • REMOVER USUÁRIO      [${RED}15${RESET}] • TRÁFEGO       ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}04${RESET}] • RENOVAR USUÁRIO      [${RED}16${RESET}] • FIREWALL      ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}05${RESET}] • USUÁRIOS ONLINE      [${RED}17${RESET}] • INFO SISTEMA  ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}06${RESET}] • ALTERAR DATA         [${RED}18${RESET}] • BANNER        ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}07${RESET}] • ALTERAR LIMITE       [${RED}19${RESET}] • LIMITAR SSH   ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}08${RESET}] • ALTERAR SENHA        [${RED}20${RESET}] • BADVPN        ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}09${RESET}] • REMOVER EXPIRADOS    [${RED}21${RESET}] • AUTO MENU     ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}10${RESET}] • RELATÓRIO USUÁRIOS   [${RED}22${RESET}] • BOT TELEGRAM  ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}11${RESET}] • BACKUP DE USUÁRIOS   [${RED}23${RESET}] • FERRAMENTAS   ┃${RESET}"
    echo -e "${CYAN}┃ [${RED}12${RESET}] • MODO DE CONEXÃO      [${RED}00${RESET}] • SAIR          ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    
    echo -n -e "${CYAN}┗┫ INFORME UMA OPÇÃO: ${RESET}"
    
    read opcao

    case $opcao in
        1) echo -e "${GREEN}Criando usuário SSH...${RESET}";;
        2) echo -e "${GREEN}Criando teste SSH...${RESET}";;
        3) echo -e "${GREEN}Removendo usuário SSH...${RESET}";;
        4) echo -e "${GREEN}Renovando usuário SSH...${RESET}";;
        5) echo -e "${GREEN}Listando usuários online...${RESET}";;
        0) echo -e "${GREEN}Saindo...${RESET}"; exit 0;;
        *) echo -e "${RED}Opção inválida!${RESET}"; sleep 2; menu;;
    esac

    sleep 2
    menu
}

# Se for chamado com "menu", apenas executa o painel
if [[ "$1" == "menu" ]]; then
    menu
    exit 0
fi

# Criar o comando menu globalmente
echo '#!/bin/bash' | sudo tee /usr/local/bin/menu > /dev/null
echo "bash <(curl -sL https://raw.githubusercontent.com/Venusofcxp/Venus-ssh/main/install-ssh-websocket-udp.sh) menu" | sudo tee -a /usr/local/bin/menu > /dev/null
sudo chmod +x /usr/local/bin/menu
sudo ln -sf /usr/local/bin/menu /usr/bin/menu

echo -e "${GREEN}Instalação concluída! Digite 'menu' para abrir o painel.${RESET}"
