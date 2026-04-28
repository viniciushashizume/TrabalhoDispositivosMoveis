# Monitor de Saúde Mental - Projeto Dispositivos Móveis

Este é um aplicativo desenvolvido em Flutter com o objetivo de auxiliar no monitoramento da saúde mental. O aplicativo permite que o usuário faça um check-in diário (registrando humor, horas de sono, nível de estresse, etc.), mantenha um diário pessoal e visualize o histórico de seus registros.

## 👥 Integrantes da Equipe e Atividades Desenvolvidas

* **Vinicius Hashizume:**
  * Desenvolvimento da tela e lógica de **Login**.
  * Desenvolvimento da tela e lógica de **Check-in Diário**.
  * Desenvolvimento da tela de **Histórico**, com listagem separada por abas.
  * Implementação da barra de navegação inferior.

* **Gabriel Castello:**
  * Desenvolvimento da tela e lógica de **Cadastro de Usuário**.
  * Desenvolvimento da tela e lógica do **Diário**.
  * Desenvolvimento da tela de **Histórico**, com listagem separada por abas.
  * Desenvolvimento da tela de **Configurações**, incluindo alternância de tema claro/escuro.

## 📌 Particularidades do Projeto

### Funcionalidades Faltantes e Limitações
* **Persistência de Dados: Todos os dados salvos pelos repositórios (registro de checkin, diário e usuário) são salvos em uma lista, ou seja, ao reiniciar o aplicativo, os dados salvos são perdidos.
* **Na tela de configurações, o e-mail do usuário ainda aparece como um dado mockado.

### 🚀 Instalação e Execução

Para rodar este projeto localmente, é necessário ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado em sua máquina.

1. Clone ou baixe o diretório do projeto.
2. Pelo terminal, navegue até a pasta raiz do projeto (`projeto_dispositivos_moveis`).
3. Baixe as dependências do projeto executando o comando:
   ```bash
   flutter pub get
4. Rode o projeto com:
   ```bash
   flutter run
