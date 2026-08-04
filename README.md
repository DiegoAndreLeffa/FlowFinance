# FlowFinance

Aplicativo de controle financeiro pessoal com foco em simplicidade, entrada rápida de despesas/receitas e acompanhamento do saldo.

## Status atual

O projeto já possui uma base funcional do MVP com:

- Cadastro e listagem de transações
- Entrada inteligente de texto para criar despesas e receitas
- Cálculo de saldo atual considerando saldo inicial
- Gestão básica de categorias
- Tela inicial com resumo de gastos/recebimentos
- Edição e exclusão de transações
- Backup/importação em formato JSON
- Navegação entre home, categorias e configurações

### Bugs & Correções

### Melhorias de UX/UI (Experiência e Interface)

### Novas Funcionalidades (Features)

**[Feature/UX] Criar Tutorial de Primeiro Uso (Onboarding)**
*   **O que fazer:** Implementar uma sequência de telas (carrossel) ou dicas (tooltips) para guiar o usuário assim que ele se cadastra ou abre o app pela primeira vez.
*   **Objetivo:** Explicar o valor do app e ensinar as ações principais (ex: adicionar saldo, criar uma meta, registrar uma despesa) para que o usuário não fique perdido.

*   **Regras de Negócio e Comportamento Esperado:**
    1.  **Exibição Única:** O tutorial deve aparecer **apenas uma vez** por usuário.
    2.  **Opção de Pular:** Deve haver um botão "Pular Tutorial" bem visível para quem não quer ler.
    3.  **Botão de Ação Final:** Na última tela do tutorial, um botão de "Começar a usar" que direciona o usuário para a Tela Principal (ou para o modal de Saldo Inicial).

*   **🛠️ Orientação Técnica para o Desenvolvedor:**
    *   **Controle de Estado:** É necessário criar uma variável (flag) do tipo booleana, como `isFirstLogin` ou `hasSeenTutorial = true`.
    *   **Armazenamento:** Salvar essa flag no banco de dados atrelada ao perfil do usuário, OU no armazenamento local do celular do usuário (ex: `AsyncStorage` no React Native ou `SharedPreferences`), para garantir que a tela não volte a aparecer nos próximos logins.

*   **Sugestão de Conteúdo (Telas do Carrossel):**
    *   *Tela 1:* **Bem-vindo!** Comece definindo seu Saldo Inicial.
    *   *Tela 2:* **Controle Total:** Cadastre suas receitas e despesas nas categorias.
    *   *Tela 3:* **Defina Metas:** Crie limites de gastos (metas) para cada categoria e acompanhe as barras de progresso para não ficar no vermelho!

## Como executar

Para rodar o projeto em modo de desenvolvimento (Debug):
```bash
flutter pub get
flutter run
```

Para gerar o arquivo APK de Produção (Pronto para instalar no Android):
```bash
flutter build apk --release --no-tree-shake-icons
```

## Observações

O projeto foi implementado com Flutter e usa persistência local para manter transações, categorias e saldo inicial entre execuções.
