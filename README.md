# SOS Cidade (Missão Resgate Urbano)

![Versão](https://img.shields.io/badge/versão-v1.0.1-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)

> Uma plataforma de zeladoria urbana inteligente que conecta os cidadãos à gestão pública, garantindo transparência, eficiência e inteligência de dados na resolução de problemas da cidade.

## Download

O APK (Android) mais recente do aplicativo, otimizado para dispositivos físicos, pode ser descarregado através da página de [Releases do GitHub](https://github.com/ohomemcodigos/ResgateUrbano/releases).

## Sobre o Projeto

O **SOS Cidade** é um aplicativo mobile focado na zeladoria urbana. Nasceu da necessidade de centralizar e agilizar o reporte de problemas de infraestrutura (buracos, falta de iluminação, problemas de saneamento) pelas ruas da cidade.

### Público-Alvo

O sistema possui uma arquitetura de controle de acessos (RBAC) com duas frentes:

1. **Cidadãos:** Que necessitam de uma ferramenta simples para reportar problemas, anexar evidências fotográficas e acompanhar a resolução com total transparência.
2. **Auditores / Gestores Públicos:** Que precisam de um painel gerencial robusto para alterar o status das ocorrências, analisar o tempo médio de resolução (SLA) e visualizar o ranking das áreas mais críticas da cidade.

## Funcionalidades Principais

### Painel do Cidadão
* **Reporte de Incidentes:** Abertura de chamados com título, descrição, categoria, prioridade e anexo fotográfico (Câmera/Galeria).
* **Autopreenchimento de Endereço:** Integração com a API do ViaCEP para preencher Rua e Bairro automaticamente.
* **Transparência e Contatos:** Visualização do status dos chamados públicos e exibição dinâmica de contatos de emergência (ex: Energisa, Cagepa, SEMOB) com base na categoria do problema.

### Painel do Auditor (Gerencial)
* **Controle de Status:** Atualização do ciclo de vida do chamado (Aberto ➔ Em Andamento ➔ Concluído).
* **Dashboard Avançado:** Gráficos interativos (Donut Chart) mostrando a distribuição de chamados por status.
* **Métricas de SLA:** Cálculo automático do Tempo Médio de Resolução por categoria de problema.
* **Ranking de Bairros:** Algoritmo que lista os bairros com maior incidência de problemas para direcionamento de recursos públicos.

## Tecnologias e Bibliotecas Utilizadas

O aplicativo foi desenvolvido utilizando **Flutter (Dart)** com a arquitetura Material Design 3.

### Gerenciamento e Arquitetura
* `provider` (^6.1.1): Gerenciamento de estado reativo e isolamento das regras de negócio.

### Persistência de Dados e Resiliência
* `sqflite` (^2.3.0) & `sqflite_common_ffi`: Banco de dados local padrão.
* **Inicialização Inteligente:** O sistema detecta a plataforma de execução via `dart:io`. Em dispositivos móveis físicos (Android/iOS), utiliza o motor SQLite nativo. 
* *Fallback em Memória:* Lógica customizada para suportar a emulação em navegadores (Web) sem gerar *crashes* por falta de permissões de disco.

### Integrações e Manipulação de Dados
* `http` (^1.2.0): Consumo de APIs RESTful (ViaCEP).
* `image_picker` (^1.1.2): Acesso nativo à câmera e galeria do dispositivo.
* `dart:convert`: Compressão e conversão de imagens para String (Base64) para armazenamento eficiente no banco de dados sem dependência de *paths* locais.

### UI e Visualização
* `fl_chart` (^0.68.0): Renderização nativa e fluida de gráficos estatísticos.
* `intl` (^0.19.0): Formatação precisa de datas e horas.

## Instalação e Execução

Estas instruções explicam como configurar o ambiente de desenvolvimento para executar o aplicativo.

### Pré-requisitos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0 ou superior)
* Android Studio ou VS Code com as extensões do Flutter

### Passos para execução

1. Clone este repositório:
   ```bash
   git clone https://github.com/ohomemcodigos/ResgateUrbano.git
   ```

2. Acesse a pasta do projeto:
   ```bash
   cd ResgateUrbano
   ```

3. Instale as dependências:
   ```bash
   flutter pub get
   ```

4. Execute o aplicativo (em um emulador ou dispositivo físico):
   ```bash
   flutter run
   ```
> **Nota:** Para compilar o APK de produção localmente, utilize o comando `flutter build apk --release`.

## Projeto Acadêmico
Este aplicativo foi construído para a disciplina de Mobile do curso de Ciência da Computação da [UNIPÊ](https://www.unipe.edu.br/).