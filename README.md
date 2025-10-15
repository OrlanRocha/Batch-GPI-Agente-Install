# Script de Implantacao do GLPI Agent

## Descricao
Este script realiza a implantacao automatizada do GLPI Agent em sistemas Windows. Ele detecta a arquitetura da maquina, baixa o instalador apropriado via `curl`, executa a instalacao silenciosa e, se configurado, remove agentes antigos como o FusionInventory Agent e o OCS Inventory Agent.

## Requisitos

- Windows com acesso a internet ou ao servidor local de instalacao.
- Privilegios de administrador.
- `curl` instalado e disponivel no PATH do sistema.
- `wmic` disponivel para desinstalacao de agentes existentes (presente ate o Windows 10).

## Variaveis Configuraveis

| Variavel                     | Funcao                                                                  |
|-----------------------------|-------------------------------------------------------------------------|
| `VersaoSetup`              | Define a versao do GLPI Agent a ser instalada.                         |
| `ipServidor`               | IP do servidor onde esta hospedado o instalador.                       |
| `LocalSetup`               | URL base do instalador, gerada com base no IP e na versao.              |
| `OpcoesInstalacao`         | Parametros adicionais passados ao `msiexec` para instalacao silenciosa. Utiliza automaticamente o IP informado para `ipServidor`.|
| `DesinstalarFusionInventory` | Se `Sim`, desinstala o FusionInventory Agent antes da instalacao.     |
| `DesinstalarOcsAgent`      | Se `Sim`, desinstala o OCS Inventory Agent antes da instalacao.         |

## Como Usar

1. **Edite o script**, ajustando as variaveis `ipServidor` e `VersaoSetup` conforme necessario.
2. **Execute como administrador** — o script verifica automaticamente e interrompe se nao tiver privilegios.
3. **Aguarde o processo de download e instalacao**.
4. **Verifique as mensagens de status** para confirmar o sucesso da instalacao ou falhas. Em caso de erro, o script retorna um codigo de saida diferente de `0`, permitindo acoes corretivas em ferramentas de automacao.

## Mensagens do Script

- **Este script deve ser executado como administrador.**
- **Baixando agente GLPI...**
- **Falha ao baixar o instalador do GLPI Agent**
- **Desinstalando FusionInventory Agent...**
- **Desinstalando OCS Inventory Agent...**
- **Instalando GLPI Agent...**
- **Falha na instalacao com o codigo de erro X**
- **Instalacao realizada com sucesso!**

## Observacoes

- O script utiliza `curl` para download — certifique-se de que esteja funcional.
- Para instalacoes em massa, e possivel executar este script remotamente com ferramentas como PsExec.
- Compativel com arquiteturas `x86` e `x64`.

## Licenca

Copyright (C) 2024  
Autor: **Orlan Rocha**

Distribuido sob os termos da GNU General Public License v2 ou superior.

## Como Contribuir

Sinta-se a vontade para abrir uma issue ou enviar um pull request no GitHub.

## Publicacao no GitHub

1. Crie um repositorio chamado `glpi-agent-deployment`.
2. Clone o repositorio:
```sh
git clone https://github.com/OrlanRocha/Batch-GPI-Agente-Install.git
```
3. Copie os arquivos do projeto para o repositorio clonado.
4. Navegue ate o repositorio:
```sh
cd Batch-GPI-Agente-Install
```
5. Adicione os arquivos:
```sh
git add .
```
6. Faça o commit:
```sh
git commit -m "Adicionando script de implantacao do GLPI Agent"
```
7. Envie ao GitHub:
```sh
git push origin main
```

