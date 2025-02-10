#!/bin/bash
clear

#--------------------------
# GERENCIADOR SSH - VENUS PRO
#--------------------------

# - Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # Sem cor

# - Verifica Execução Como Root
[[ "$EUID" -ne 0 ]] && {
    echo -e "${RED}[x] ESTE SCRIPT DEVE SER EXECUTADO COMO ROOT!${NC}"
    exit 1
}

# - Função para obter status do sistema em tempo real
status_servidor() {
    while true; do
        clear
        # CPU - Calculando uso corretamente
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')

        # RAM - Evitando erro de divisão por zero
        ram_info=$(free -m | awk 'NR==2')
        ram_total=$(echo "$ram_info" | awk '{print $2}')
        ram_usada=$(echo "$ram_info" | awk '{print $3}')
        ram_usage=$(awk -v usada="$ram_usada" -v total="$ram_total" 'BEGIN {if (total > 0) printf "%.2f%", (usada/total)*100}')

        # Tempo de atividade
        tempo_ativo=$(uptime -p)

        # Conexões e usuários
        usuarios_online=$(who | wc -l)
        conexoes_ativas=$(netstat -tan | grep ':22 ' | grep ESTABLISHED | wc -l)

        # Exibir painel VENUS PRO
        echo -e "${BLUE}========================================${NC}"
        echo -e "          🌟 ${YELLOW}VENUS PRO${NC} 🌟        "
        echo -e "${BLUE}========================================${NC}"
        echo -e ""
        echo -e "📊 ${GREEN}Status do Servidor:${NC}"
        echo -e "${BLUE}----------------------------------------${NC}"
        echo -e "🖥️ CPU: ${YELLOW}$cpu_usage${NC}   |  📈 RAM: ${YELLOW}$ram_usage${NC}"
        echo -e "⏳ Tempo ativo: ${YELLOW}$tempo_ativo${NC}"
        echo -e "🌐 Usuários Online: ${YELLOW}$usuarios_online${NC}"
        echo -e "📡 Conexões Ativas: ${YELLOW}$conexoes_ativas${NC}"
        echo -e "${BLUE}----------------------------------------${NC}"
        echo -e ""
        echo -e "📌 ${GREEN}MENU PRINCIPAL:${NC}"
        echo -e "${BLUE}----------------------------------------${NC}"
        echo -e "[${YELLOW}1${NC}] 🛠️ Gerenciar Usuários"
        echo -e "[${YELLOW}2${NC}] 🔌 Configurações de Rede"
        echo -e "[${YELLOW}3${NC}] 📶 Status da Conexão"
        echo -e "[${YELLOW}4${NC}] ⚙️ Ferramentas Extras"
        echo -e "[${YELLOW}5${NC}] 📜 Logs e Registros"
        echo -e "[${YELLOW}6${NC}] 🏆 Estatísticas"
        echo -e "[${YELLOW}7${NC}] 🖥️ Monitoramento"
        echo -e "[${YELLOW}8${NC}] 🔄 Reiniciar Servidor"
        echo -e "[${YELLOW}9${NC}] ❌ Sair"
        echo -e "${BLUE}----------------------------------------${NC}"
        echo -e "💡 ${YELLOW}Dica: Digite o número da opção desejada.${NC}"

        read -t 5 -p "Escolha uma opção: " opcao
        [[ -z "$opcao" ]] && continue  # Se não escolher nada, continua atualizando

        case "$opcao" in
            1) 
                clear
                echo -e "${GREEN}[1] Criar Usuário SSH${NC}"
                echo -e "${GREEN}[2] Remover Usuário SSH${NC}"
                echo -e "${GREEN}[3] Listar Usuários SSH${NC}"
                read -p "Escolha uma opção: " sub_opcao
                case "$sub_opcao" in
                    1) criar_usuario ;;
                    2) remover_usuario ;;
                    3) listar_usuarios ;;
                    *) echo -e "${RED}[x] Opção inválida!${NC}" ;;
                esac
                ;;
            2) configurar_ssh ;;
            3) ver_conexoes ;;
            4) echo -e "${YELLOW}[!] Em desenvolvimento...${NC}" ;;
            5) echo -e "${YELLOW}[!] Em desenvolvimento...${NC}" ;;
            6) echo -e "${YELLOW}[!] Em desenvolvimento...${NC}" ;;
            7) echo -e "${YELLOW}[!] Em desenvolvimento...${NC}" ;;
            8) reiniciar_servidor ;;
            9) echo -e "${GREEN}Saindo...${NC}"; exit ;;
            *) echo -e "${RED}[x] Opção inválida!${NC}" ;;
        esac
        read -p "Pressione ENTER para continuar..."
    done
}

# - Funções do Gerenciador SSH
criar_usuario() {
    read -p "Nome do usuário SSH: " usuario
    read -p "Senha: " senha
    read -p "Dias de validade: " dias
    expira=$(date -d "+$dias days" +"%Y-%m-%d")
    useradd -m -s /bin/false -e "$expira" "$usuario"
    echo "$usuario:$senha" | chpasswd
    echo -e "${GREEN}[✔] Usuário SSH '$usuario' criado com sucesso! Expira em: $expira.${NC}"
}

remover_usuario() {
    read -p "Nome do usuário SSH para remover: " usuario
    userdel -r "$usuario" && echo -e "${GREEN}[✔] Usuário '$usuario' removido com sucesso.${NC}" || echo -e "${RED}[x] Usuário não encontrado.${NC}"
}

listar_usuarios() {
    echo -e "${YELLOW}Usuários SSH Ativos:${NC}"
    awk -F: '{if ($3 >= 1000) print $1}' /etc/passwd
}

ver_conexoes() {
    echo -e "${YELLOW}Conexões Ativas:${NC}"
    netstat -tnpa | grep ':22 ' | grep 'ESTABLISHED'
}

configurar_ssh() {
    read -p "Nova porta SSH (padrão: 22): " nova_porta
    read -p "Número máximo de conexões por usuário (padrão: 2): " max_conexoes
    [[ -z "$nova_porta" ]] && nova_porta=22
    [[ -z "$max_conexoes" ]] && max_conexoes=2
    sed -i "s/^Port .*/Port $nova_porta/" /etc/ssh/sshd_config
    sed -i "s/^MaxSessions .*/MaxSessions $max_conexoes/" /etc/ssh/sshd_config
    sed -i "s/^MaxAuthTries .*/MaxAuthTries 2/" /etc/ssh/sshd_config
    systemctl restart ssh
    echo -e "${GREEN}[✔] Configuração SSH aplicada! Porta: $nova_porta | Máx Conexões: $max_conexoes.${NC}"
}

reiniciar_servidor() {
    echo -e "${RED}[!] Reiniciando servidor...${NC}"
    sleep 2
    reboot
}

# Iniciar o painel atualizado
status_servidor
