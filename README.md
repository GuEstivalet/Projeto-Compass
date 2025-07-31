#  Projeto: Servidor Web Monitorado na AWS

## Resumo

Este projeto detalha a configuração de um ambiente de servidor web com Nginx na Amazon Web Services (AWS) e a implementação de um sistema básico de monitoramento de disponibilidade, com notificações via Discord. Ele abrange a infraestrutura de rede, instalação de serviços e automação de monitoramento, consolidando habilidades essenciais em Linux, AWS e Bash Scripting, realizadas manualmente na instância.

## 🎯 Objetivos de Aprendizagem

Infraestrutura AWS: Compreender e aplicar conceitos de VPC, Subnets (públicas e privadas), Internet Gateway (IGW), NAT Gateway, Route Tables e Security Groups.

Instâncias EC2: Provisionar, configurar e gerenciar máquinas virtuais na nuvem.

Servidor Web Nginx: Instalar e configurar o Nginx para servir conteúdo estático.

Bash Scripting: Desenvolver scripts para automação de tarefas e monitoramento.

Agendamento de Tarefas: Utilizar cron para automatizar a execução de scripts.

Notificações: Integrar alertas de monitoramento com serviços de comunicação como o Discord.

## 📋 Pré-requisitos para o Projeto
Para replicar e executar este projeto com sucesso, você precisará dos seguintes:

Fundamentos de Linux: Familiaridade com comandos básicos de terminal (ex: cd, ls, sudo, apt, systemctl, tail, ssh, crontab).

Conceitos Básicos de Redes: Noções de IP, portas (HTTP, SSH), sub-redes e como a comunicação funciona.

Conceitos Fundamentais e Conta AWS: Uma conta AWS ativa com permissões para criar e gerenciar recursos como EC2 e VPC.

Conta Discord para Webhook: Necessário para configurar e receber as notificações de monitoramento.

Bash Scripting: Habilidade básica para entender e modificar scripts simples em Bash.

## 💻 Etapas Detalhadas do Projeto

### 1. Configuração do Ambiente AWS

Nesta etapa, você construirá a base de rede e as instâncias EC2 para o seu servidor web e o bastion host.

Tarefas de Rede:
Crie uma VPC na AWS.

Crie duas sub-redes públicas (ex: subnet-public-1, subnet-public-2) para acesso externo.

Crie duas sub-redes privadas (ex: subnet-private-1, subnet-private-2) para backend/futuros serviços.

Crie e anexe um Internet Gateway (IGW) à sua VPC.

Crie uma tabela de rotas pública e associe-a às suas sub-redes públicas, adicionando uma rota para 0.0.0.0/0 apontando para o IGW.

Crie uma tabela de rotas privada e associe-a às suas sub-redes privadas.

Crie um NAT Gateway em uma das suas sub-redes públicas e associe um Elastic IP a ele.

Na tabela de rotas privada, adicione uma rota para 0.0.0.0/0 apontando para o NAT Gateway. Isso permitirá que instâncias na sub-rede privada acessem a internet para atualizações, mas sem serem acessíveis diretamente de fora.

Ao fim, a topologia da sua VPC deve se parecer com o exemplo abaixo:

<img width="1247" height="430" alt="image" src="https://github.com/user-attachments/assets/0fb2db7f-4c0c-44dd-8fc4-8c545dfb71f9" />


Criação das Instâncias EC2:
Crie uma instância EC2 para Bastion Host (Ubuntu/Debian):

Lance na subnet-public-1.

Habilite "Auto-assign public IP".

Crie ou use um Security Group que permita SSH (Porta 22) do seu IP.

Crie um Elastic IP e associe-o ao seu Bastion Host.

Crie uma instância EC2 para Web Server (Ubuntu/Debian):

Lance na subnet-private-1.

Desabilite "Auto-assign public IP".

Crie ou use um Security Group para o Web Server que permita:

SSH (Porta 22): De dentro da VPC (ex: do Security Group do Bastion Host).

HTTP (Porta 80): Se o seu site for acessado de forma pública através de um Load Balancer, o Security Group deverá permitir a entrada HTTP da origem do Load Balancer. Lembre-se que o NAT Gateway só permite tráfego de saída.

A configuração da instância pode ser feita como no exemplo abaixo:

<img width="858" height="88" alt="Captura de tela 2025-07-30 232601" src="https://github.com/user-attachments/assets/a028828b-fb88-4c39-b2b2-bba800288543" />


### 2. Configuração de Acesso SSH via Bastion Host

Após criar suas instâncias, configure o acesso SSH seguro através do Bastion Host.

Preparação da Chave SSH:
Certifique-se de que sua chave SSH (projeto.pem) tenha as permissões corretas na sua máquina local:

Bash
```
chmod 400 ~/.ssh/projeto.pem
```
Configuração do Arquivo ~/.ssh/config:
Edite (ou crie) o arquivo ~/.ssh/config na sua máquina local:

Bash

```
vi ~/.ssh/config
```
Adicione o seguinte conteúdo, substituindo <Ip elastico do seu bastion> e <Ip privado do seu webserver> pelos valores reais:

Snippet de código

```
Host bastion
  HostName <Ip elastico do seu bastion>
  User ubuntu
  IdentityFile ~/.ssh/projeto.pem

Host webserver
  HostName <Ip privado do seu webserver>
  User ubuntu
  IdentityFile ~/.ssh/projeto.pem
  ProxyJump bastion
```
Este arquivo de configuração SSH permite que você acesse o servidor webserver de forma segura, saltando (ProxyJump) primeiro para o bastion host, que atua como um ponto de entrada intermediário e seguro para sua rede privada.

Conectando-se ao Web Server:
Agora, você pode acessar diretamente seu webserver com um comando simplificado:

Bash
```
ssh webserver
```
3. Configuração Manual do Servidor Web e Monitoramento
Após acessar o webserver via SSH (através do bastion host), execute os seguintes comandos:

a. Atualizar o Sistema e Instalar Nginx
Primeiro, atualize os pacotes do sistema e instale o Nginx:

Bash
```
sudo apt update && sudo apt upgrade -y
sudo apt install nginx -y
```

b. Criar e Configurar a Página HTML
Crie o diretório para o seu projeto e a página HTML:

Bash
```
sudo mkdir -p /var/www/html/meu-projeto
sudo vi /var/www/html/meu-projeto/index.html
```
Cole o seguinte conteúdo no arquivo index.html (e salve com Esc + :wq + Enter):

HTML
```
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projeto de Configuração de Servidor Web</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #f0f0f0; color: #333; }
        .container { background-color: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); display: inline-block; }
        h1 { color: #007bff; }
        p { font-size: 1.2em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Bem-vindo ao Meu Servidor Web no AWS!</h1>
        <p>Este é o meu projeto de configuração de servidor web monitorado.</p>
        <p>Servidor Nginx está funcionando com sucesso!</p>
        <p>Data e Hora de Criação: $(date)</p>
    </div>
</body>
</html>
```
c. Configurar Nginx para Servir a Página
Crie um novo arquivo de configuração para o seu site no Nginx:

Bash
```
sudo vi /etc/nginx/sites-available/meu-projeto
```
Cole o seguinte conteúdo (e salve):

Nginx
```
server {
    listen 80;
    server_name _; # Pode ser o IP privado do seu webserver ou um domínio
    root /var/www/html/meu-projeto;
    index index.html index.htm;
    location / { try_files $uri $uri/ =404; }
}
```
Desabilite o site padrão do Nginx (opcional, mas boa prática) e habilite o seu novo site:

Bash
```
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/meu-projeto /etc/nginx/sites-enabled/
```

Reinicie o Nginx para aplicar as configurações e habilite-o para iniciar com o sistema:

Bash

```
sudo systemctl restart nginx
sudo systemctl enable nginx
```

d. Configurar Auto-Restart para o Nginx
Para garantir que o Nginx reinicie automaticamente em caso de falha, edite o serviço systemd:

Bash

```
sudo systemctl edit nginx
```
Adicione as seguintes linhas na seção [Service] (se não existir, o systemctl edit criará um novo arquivo de override):


```
[Service]
Restart=on-failure
RestartSec=5s
```
Salve e recarregue o daemon do systemd e reinicie o Nginx para aplicar:

Bash

```
sudo systemctl daemon-reload
sudo systemctl restart nginx
```
e. Criar Script de Monitoramento
Crie um diretório para seus scripts e o arquivo do script de monitoramento:

Bash
```
mkdir ~/scripts
vi ~/scripts/monitor.sh
```
Cole o conteúdo do script de monitoramento (e salve):

Bash
```
#!/bin/bash

LOG_FILE="/var/log/monitoramento.log"
TARGET_URL="http://localhost" # Monitore o site localmente
DISCORD_WEBHOOK_URL="seu_webhook"

HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $TARGET_URL)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "[$TIMESTAMP] Site disponível (Status: $HTTP_STATUS)." | sudo tee -a $LOG_FILE
else
    MESSAGE="[$TIMESTAMP] ALERTA: Site indisponível! (Status: $HTTP_STATUS) em $(hostname)."
    echo "$MESSAGE" | sudo tee -a $LOG_FILE
    curl -H "Content-Type: application/json" -X POST -d '{"content": "'"$MESSAGE"'"}' $DISCORD_WEBHOOK_URL
fi
```
f. Automatizar o Monitoramento com Cron
Torne o script executável:

Bash

```
chmod +x ~/scripts/monitor.sh
```
Crie o arquivo de log e defina as permissões corretas para o usuário ubuntu:

Bash

```
sudo touch /var/log/monitoramento.log
sudo chown ubuntu:ubuntu /var/log/monitoramento.log
```
Abra o editor de tarefas agendadas do usuário atual:

Bash
```
crontab -e
```
Adicione a seguinte linha no final do arquivo e salve (para que a tarefa seja agendada a cada minuto):

```
* * * * * /home/ubuntu/scripts/monitor.sh
```
## 4. Testes e Verificação
Após toda a configuração manual, é crucial verificar se tudo está funcionando conforme o esperado.

### Teste de Acesso ao Site

Lembre-se: sua instância do Web Server está em uma sub-rede privada e não é diretamente acessível da internet sem um ponto de entrada público.

### Verificando o Nginx via SSH
Conecte-se ao seu Web Server via SSH (usando o ProxyJump configurado):

Bash
```
ssh webserver
```
Verifique o status do Nginx:

Bash
```
systemctl status nginx
```
Você deve ver Active: active (running).

### Verificando os Logs do Monitoramento
Ainda na sessão SSH do Web Server, visualize os logs do script de monitoramento:

Bash
```
sudo tail -f /var/log/monitoramento.log
```
Você deverá ver entradas como:

[AAAA-MM-DD HH:MM:SS] Site disponível (Status: 200).

# Teste do Sistema de Alerta do Discord
Para simular uma falha e verificar as notificações:

Pare o Nginx:

Bash
```
sudo systemctl stop nginx
```
Isso simula uma falha no servidor web.

Monitore os logs em tempo real e aguarde até que o script de monitoramento detecte a indisponibilidade (geralmente dentro de 1 minuto devido ao cron):

Bash
```
sudo tail -f /var/log/monitoramento.log
```
Você deverá ver uma mensagem de "ALERTA: Site indisponível!".

Verifique seu canal do Discord: Você deve receber uma notificação do webhook informando que o site está fora do ar:

<img width="548" height="105" alt="image" src="https://github.com/user-attachments/assets/c51bf9b9-9a6b-4b19-840e-da6e6462a0f7" />


Restaure o serviço Nginx:

Bash
```
sudo systemctl start nginx
```
Após mais um minuto, o log deverá voltar a mostrar "Site disponível" e as notificações de erro pararão.

## 🛠️ Tecnologias Utilizadas
AWS EC2: Máquinas virtuais para Bastion Host e Web Server.

AWS VPC: Configuração de rede isolada e segura.

AWS Internet Gateway (IGW): Permite acesso à internet para sub-redes públicas.

AWS NAT Gateway: Permite que instâncias em sub-redes privadas iniciem conexões de saída para a internet.

Nginx: Servidor web.

Bash Scripting: Para automação de tarefas e script de monitoramento.

Cron: Agendamento de execução do script de monitoramento.

Discord Webhooks: Integração para notificações de alerta.

SSH ProxyJump: Para acesso seguro a instâncias em sub-redes privadas.

