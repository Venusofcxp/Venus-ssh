#!/bin/bash

# Cores para destaque
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
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
    echo -e "${CYAN}┃            ⇱ VENUS PRO ⇲               ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${RESET}"
    echo -e "${CYAN}┃ SISTEMA           MEMORIA RAM       PROCESSADOR  ┃${RESET}"
    echo -e "${CYAN}┃ OS: ${GREEN}$OS${CYAN}  Total: ${GREEN}${RAM_TOTAL}MB${CYAN}   Núcleos: ${GREEN}${CPU_CORES}${CYAN}    ┃${RESET}"
    echo -e "${CYAN}┃ Hora: ${GREEN}${HORA}${CYAN}    Em Uso: ${GREEN}${RAM_USO}MB${CYAN}    CPU: ${GREEN}${CPU_USO}%${CYAN}    ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${RESET}"
    echo -e "${CYAN}┃ Onlines: ${GREEN}${ONLINE}${CYAN}        Expirados: ${GREEN}${EXPIRED_USERS}${CYAN}      Total: ${GREEN}${TOTAL_USERS}${CYAN}      ┃${RESET}"
    echo -e "${CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${RESET}"

    echo -e "${CYAN}┃ [01] • CRIAR USUÁRIO        [13] • SPEEDTEST     ┃${RESET}"
    echo -e "${CYAN}┃ [02] • CRIAR TESTE          [14] • OTIMIZAR      ┃${RESET}"
    echo -e "${CYAN}┃ [03] • REMOVER USUÁRIO      [15] • TRÁFEGO       ┃${RESET}"
    echo -e "${CYAN}┃ [04] • RENOVAR USUÁRIO      [16] • FIREWALL      ┃${RESET}"
    echo -e "${CYAN}┃ [05] • USUÁRIOS ONLINE      [17] • INFO SISTEMA  ┃${RESET}"
    echo -e "${CYAN}┃ [06] • ALTERAR DATA         [18] • BANNER        ┃${RESET}"
    echo -e "${CYAN}┃ [07] • ALTERAR LIMITE       [19] • LIMITAR SSH   ┃${RESET}"
    echo -e "${CYAN}┃ [08] • ALTERAR SENHA        [20] • BADVPN        ┃${RESET}"
    echo -e "${CYAN}┃ [09] • REMOVER EXPIRADOS    [21] • AUTO MENU     ┃${RESET}"
    echo -e "${CYAN}┃ [10] • RELATÓRIO USUÁRIOS   [22] • BOT TELEGRAM  ┃${RESET}"
    echo -e "${CYAN}┃ [11] • BACKUP DE USUÁRIOS   [23] • FERRAMENTAS   ┃${RESET}"
    echo -e "${CYAN}┃ [12] • MODO DE CONEXÃO      [00] • SAIR          ┃${RESET}"
    
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
