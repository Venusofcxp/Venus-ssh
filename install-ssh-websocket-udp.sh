#!/bin/bash
clear
#--------------------------
# SCRIPT SSH-PLUS
# CANAL TELEGRAM: @TURBONET2023
#--------------------------

# - Cores
VERMELHO='\033[1;31m'
AMARELO='\033[1;33m'
VERDE='\033[1;32m'
RESET='\033[0m'

# - Verifica Execução Como Root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${VERMELHO}[x] Você precisa executar o script como usuário ROOT!${RESET}"
    exit 1
fi

# - Verifica Arquitetura Compatível
case "$(uname -m)" in
    'amd64' | 'x86_64')
        arco='64'
        ;;
    'aarch64' | 'armv8')
        arco='arm64'
        ;;
    *)
        echo -e "${VERMELHO}[x] Arquitetura incompatível!${RESET}"
        exit 1
        ;;
esac

# - Verifica OS Compatível
if grep -qs "ubuntu" /etc/os-release; then
    os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
    if [[ "$os_version" -lt 1804 ]]; then
        echo -e "${VERMELHO}[x] Versão do Ubuntu incompatível!\n${AMARELO}[!] Requer Ubuntu 18.04 ou superior!${RESET}"
        exit 1
    fi
elif [[ -e /etc/debian_version ]]; then
    os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
    if [[ "$os_version" -lt 9 ]]; then
        echo -e "${VERMELHO}[x] Versão do Debian incompatível!\n${AMARELO}[!] Requer Debian 9 ou superior!${RESET}"
        exit 1
    fi
else
    echo -e "${VERMELHO}[x] OS incompatível!\n${AMARELO}[!] Requer distros base Debian/Ubuntu!${RESET}"
    exit 1
fi

# - Configura tarefa no crontab para limpar regras do iptables a cada 6 horas
echo -e "${VERDE}Configurando tarefa no crontab para executar 'iptables -F' a cada 6 horas...${RESET}"
LINHA_CRON="0 */6 * * * iptables -F"
(crontab -l 2>/dev/null | grep -Fxq "$LINHA_CRON") || \
{ (crontab -l 2>/dev/null; echo "$LINHA_CRON") | crontab - && \
echo -e "${VERDE}Tarefa adicionada ao crontab com sucesso!${RESET}"; }

# - Atualiza Lista/Pacotes/Sistema
dpkg --configure -a
apt update -y && apt upgrade -y
apt install unzip python3 -y

# - Desabilita IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/70-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf

# - Baixa e executa o instalador
if [[ -e Plus ]]; then
    rm Plus
fi
wget -O Plus https://raw.githubusercontent.com/PhoenixxZ2023/PLUS/main/script/64/Plus && chmod +x Plus && ./Plus
