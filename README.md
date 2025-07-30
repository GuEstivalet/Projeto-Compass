# Projeto: Servidor Web Monitorado na AWS

## Resumo:
Este projeto detalha a configuração de um ambiente de servidor web com Nginx na Amazon Web Services (AWS) e a implementação de um sistema básico de monitoramento de disponibilidade, com notificações via Discord. Ele abrange a infraestrutura de rede, instalação de serviços e automação de monitoramento, consolidando habilidades essenciais em Linux, AWS e Bash Scripting.


## Objetivos de Aprendizagem
Infraestrutura AWS: Compreender e aplicar conceitos de VPC, Subnets, Internet Gateway (IGW), NAT gateway ,Route Tables e Security Groups.

Instâncias EC2: Provisionar, configurar e gerenciar máquinas virtuais na nuvem.

Servidor Web Nginx: Instalar e configurar o Nginx para servir conteúdo estático.

Bash Scripting: Desenvolver scripts para automação de tarefas e monitoramento.

Agendamento de Tarefas: Utilizar cron para automatizar a execução de scripts.

Notificações: Integrar alertas de monitoramento com serviços de comunicação como o Discord.

## Pré-requisitos para o Projeto:
- Fundamentos de Linux;
- Conceitos Básicos de Redes;
- Conceitos Fundamentais e conta AWS;
- Conta Discord par webhook;
- Bash Scripting.

## 💻 Etapas do Projeto
### 1. Configuração do Ambiente AWS
Nesta etapa, você construirá a base de rede para o seu servidor web.

Tarefas
Criar uma VPC na AWS com:

Duas sub-redes públicas (ex: subnet-public-1, subnet-public-2) para acesso externo.

Duas sub-redes privadas (ex: subnet-private-1, subnet-private-2) para backend/futuros serviços.

Um Internet Gateway (IGW) anexado à VPC.

Tabelas de rotas públicas com rota para 0.0.0.0/0 apontando para o IGW.

Tabela de rotas privadas

Ao fim, a topologia deve parecer-se com isso:
<img width="1300" height="396" alt="image" src="https://github.com/user-attachments/assets/bcec6692-a7dd-4fa8-ac05-85e43647ab47" />


Criar uma instância EC2 (Ubuntu/Debian) para Bastion-host:

Criar uma instância EC2 (Ubuntu/Debian) para hospedar Web Server:

