# Monitor de Saúde Mental - Projeto Dispositivos Móveis

Este é um aplicativo desenvolvido em Flutter com o objetivo de auxiliar no monitoramento da saúde mental. O aplicativo permite que o usuário faça um check-in diário (registrando humor, horas de sono, nível de estresse, etc.), mantenha um diário pessoal e visualize o histórico de seus registros.

## 👥 Integrantes da Equipe e Atividades Desenvolvidas

* **Vinicius Hashizume:**
  * Desenvolvimento da tela e lógica de **Login**.
  * Desenvolvimento da tela e lógica de **Check-in Diário**.
  * Desenvolvimento da tela de **Histórico**, com listagem separada por abas.
  * Implementação da barra de navegação inferior.
  * Configuração do ambiente do supabase
  * Implementação do banco de dados e autenticação para **Usuários**
  * Implementação do banco de dados para registro dos **Check-ins**
* **Gabriel Castello:**
  * Desenvolvimento da tela e lógica de **Cadastro de Usuário**.
  * Desenvolvimento da tela e lógica do **Diário**.
  * Desenvolvimento da tela de **Histórico**, com listagem separada por abas.
  * Desenvolvimento da tela de **Configurações**, incluindo alternância de tema claro/escuro.
  * Correção de erros da entrega 1.
  * Implementação do banco de dados para registro das entradas de **Diários**

### 🚀 Instalação e Execução

Para rodar este projeto localmente, é necessário ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado em sua máquina e uma conta ativa no [Supabase](https://supabase.com/).

### 1. Configuração do Banco de Dados (Supabase)
Antes de rodar o aplicativo, você precisa vinculá-lo ao seu banco de dados:
1. Crie um projeto no painel do Supabase.
2. Em **Project Settings > API**, copie a sua `Project URL` e a sua `anon public API key`.
3. Habilite a Autenticação por Email e Senha em **Authentication > Providers**.
4. No arquivo principal do aplicativo (geralmente `lib/main.dart`), certifique-se de inicializar o Supabase com as suas credenciais:
   ```dart
   await Supabase.initialize(
     url: 'SUA_PROJECT_URL_AQUI',
     anonKey: 'SUA_ANON_KEY_AQUI',
   );

1. Clone ou baixe o diretório do projeto.
2. Pelo terminal, navegue até a pasta raiz do projeto (`projeto_dispositivos_moveis`).
3. Baixe as dependências do projeto executando o comando:
   ```bash
   flutter pub get
4. Rode o projeto com:
   ```bash
   flutter run
