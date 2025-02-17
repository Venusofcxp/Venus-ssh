import os
import time
import json
from flask import Flask, send_file
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, CallbackContext

# 🔑 Token do Bot do Telegram
TOKEN = "7881564314:AAHI25QLlHg-Hw61erwtQyy4mQAaIVljypg"

# 🔧 Configuração da VPS
IP_VPS = "187.102.244.59"
PASTA_LISTAS = "/root/listas_iptv"

# 📂 Criar diretório para armazenar as listas
if not os.path.exists(PASTA_LISTAS):
    os.makedirs(PASTA_LISTAS)

# 🚀 Iniciar o Flask para hospedar os arquivos IPTV
app = Flask(__name__)

@app.route('/lista/<nome_lista>')
def baixar_lista(nome_lista):
    caminho_lista = os.path.join(PASTA_LISTAS, nome_lista)
    if os.path.exists(caminho_lista):
        return send_file(caminho_lista, as_attachment=True)
    return "Lista não encontrada", 404

# 🛠️ Função para iniciar o bot
async def start(update: Update, context: CallbackContext) -> None:
    await update.message.reply_text("🤖 Bem-vindo ao Gerenciador IPTV!\n\n"
                                    "📤 Envie um arquivo `.m3u` para armazenar.\n"
                                    "🔗 Use /gerar para criar um link com expiração.")

# 📤 Upload de listas IPTV
async def receber_arquivo(update: Update, context: CallbackContext) -> None:
    arquivo = update.message.document
    nome_arquivo = arquivo.file_name
    caminho_arquivo = os.path.join(PASTA_LISTAS, nome_arquivo)
    
    # Baixar o arquivo enviado
    file = await context.bot.get_file(arquivo.file_id)
    await file.download_to_drive(caminho_arquivo)
    
    await update.message.reply_text(f"✅ Lista `{nome_arquivo}` salva com sucesso!")

# 🔗 Gerar link IPTV com expiração
async def gerar_link(update: Update, context: CallbackContext) -> None:
    args = context.args
    if len(args) < 2:
        await update.message.reply_text("⚠️ Use: `/gerar <nome_lista> <dias>`")
        return
    
    nome_lista = args[0]
    dias = int(args[1])
    caminho_lista = os.path.join(PASTA_LISTAS, nome_lista)

    if not os.path.exists(caminho_lista):
        await update.message.reply_text("❌ Lista não encontrada!")
        return
    
    expira_em = time.time() + (dias * 86400)
    link = f"http://{IP_VPS}/lista/{nome_lista}"

    # Salvar expiração
    exp_file = f"{caminho_lista}.json"
    with open(exp_file, "w") as f:
        json.dump({"expira": expira_em}, f)

    await update.message.reply_text(f"🔗 Link gerado:\n\n{link}\n\n🕒 Expira em {dias} dias!")

# 🔥 Remover listas expiradas
async def limpar_listas():
    while True:
        await asyncio.sleep(3600)  # Verificar a cada 1 hora
        for arquivo in os.listdir(PASTA_LISTAS):
            if arquivo.endswith(".json"):
                with open(os.path.join(PASTA_LISTAS, arquivo)) as f:
                    dados = json.load(f)
                if time.time() > dados["expira"]:
                    os.remove(os.path.join(PASTA_LISTAS, arquivo.replace(".json", "")))
                    os.remove(os.path.join(PASTA_LISTAS, arquivo))

# 🚀 Iniciar o Bot
async def main():
    application = Application.builder().token(TOKEN).build()

    # Comandos
    application.add_handler(CommandHandler("start", start))
    application.add_handler(MessageHandler(filters.Document.ALL, receber_arquivo))
    application.add_handler(CommandHandler("gerar", gerar_link))

    # Iniciar o bot
    await application.start_polling()

    # Iniciar o servidor Flask
    app.run(host="0.0.0.0", port=80)

# Executar a função principal
if __name__ == '__main__':
    import asyncio
    from threading import Thread
    
    # Rodar a função de limpar listas expiradas em segundo plano
    Thread(target=lambda: asyncio.run(limpar_listas())).start()

    asyncio.run(main())
