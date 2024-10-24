# Script de Implantação do GLPI Agent

## Descrição
Este script é utilizado para a implantação do GLPI Agent em máquinas Windows, permitindo a instalação automática do agente, bem como a desinstalação opcional dos agentes FusionInventory e OCS Inventory. O script baixa o instalador do GLPI Agent de um servidor especificado, instala o agente e realiza algumas configurações de instalação, de acordo com os parâmetros fornecidos.

## Requisitos
- Sistema operacional Windows.
- Privilégios de administrador para executar o script.
- `curl` instalado e disponível no PATH para baixar o instalador.

## Configurações do Script
- **VersaoSetup**: Define a versão do GLPI Agent a ser instalada. (Padrão: `1.7.3`)
- **ipServidor**: Define o IP do servidor onde o instalador do GLPI Agent está localizado. (Padrão: `127.0.0.1`)
- **LocalSetup**: URL onde o instalador do GLPI Agent está hospedado, baseado no IP do servidor e na versão do agente.
- **ArquiteturaSetup**: Detecta automaticamente a arquitetura do sistema (x86 ou x64).
- **OpcoesInstalacao**: Define as opções de instalação do GLPI Agent. (Padrão: `/quiet RUNNOW=1 SERVER=http://%ipServidor%/glpi/`)
- **DesinstalarFusionInventory**: Define se o agente FusionInventory deve ser desinstalado. (Padrão: `Sim`)
- **DesinstalarOcsAgent**: Define se o agente OCS Inventory deve ser desinstalado. (Padrão: `Não`)

## Como Utilizar
1. **Editar o Script**: Antes de executar o script, edite as variáveis conforme necessário, especialmente `ipServidor` e `VersaoSetup`.
2. **Executar como Administrador**: Certifique-se de executar o script com privilégios de administrador, pois algumas ações exigem permissões elevadas.
3. **Download e Instalação**: O script irá baixar automaticamente o instalador do GLPI Agent e iniciar a instalação.
4. **Desinstalação Opcional**: Se configurado, o script também desinstalará o FusionInventory Agent após a instalação do GLPI Agent.

## Mensagens do Script
- **Instalando GLPI Agent...**: Informa que a instalação do GLPI Agent está em andamento.
- **Instalação realizada com sucesso!**: Informa que a instalação foi concluída sem erros.
- **Falha na instalação com o código de erro X**: Informa que houve um erro durante a instalação, exibindo o código do erro.
- **Falha ao baixar o instalador do GLPI Agent**: Informa que o script não conseguiu baixar o instalador.
- **Desinstalando FusionInventory Agent...**: Informa que o FusionInventory Agent está sendo desinstalado, se configurado para tal.

## Observações
- Caso o script não seja executado como administrador, ele solicitará a elevação dos privilégios e será encerrado.
- O script utiliza a ferramenta `curl` para baixar o instalador do GLPI Agent. Certifique-se de que ela esteja instalada e acessível.
- Para ajustar as opções de instalação ou o comportamento do script, edite as variáveis no início do arquivo conforme necessário.

## Licença
Copyright (C) 2024 BY OrlanRocha

Este script é fornecido "como está", sem garantias de qualquer tipo, expressas ou implícitas, incluindo, mas não se limitando a, garantias de comercialização ou adequação a um propósito específico.

## Como Contribuir
Se desejar contribuir para este projeto, sinta-se à vontade para abrir uma issue ou enviar um pull request no repositório GitHub. Todas as contribuições são bem-vindas!

## Publicação no GitHub
Para publicar este projeto no GitHub, siga as etapas abaixo:

1. Crie um repositório no GitHub com um nome apropriado, como `glpi-agent-deployment`.
2. Clone o repositório para o seu ambiente local:
   ```sh
   git clone https://github.com/OrlanRocha/Batch-GPI-Agente-Install.git
   ```
3. Copie todos os arquivos do projeto para o diretório do repositório clonado.
4. Navegue até o diretório do repositório:
   ```sh
   cd Batch-GPI-Agente-Install
   ```
5. Adicione os arquivos ao repositório local:
   ```sh
   git add .
   ```
6. Faça o commit das alterações:
   ```sh
   git commit -m "Adicionando script de implantação do GLPI Agent"
   ```
7. Envie as alterações para o GitHub:
   ```sh
   git push origin main
   ```

Após essas etapas, o projeto estará disponível no seu repositório GitHub.

