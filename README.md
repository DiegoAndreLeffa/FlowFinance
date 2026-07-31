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

**5. [Feature/Regra de Negócio] Cores dinâmicas e/ou customizáveis para o Progresso das Metas**
*   **O que fazer:** Alterar a lógica visual da barra de metas com base no uso do orçamento.
*   **Detalhes (Caminho 1 - Fixo):** Implementar a seguinte regra condicional:
    *   Até 49%: Verde (Tranquilo)
    *   De 50% a 70%: Amarelo (Atenção)
    *   Acima de 70%: Vermelho (Perigo)
*   **Detalhes (Caminho 2 - Customizável - *Ideal*):** Adicionar no modal de criação/edição da meta um campo onde o **próprio usuário** define a partir de qual porcentagem a barra fica amarela ou vermelha.

**6. [Feature/UI] Criar Tela de Carregamento Inicial (Splash Screen)**
*   **O que fazer:** Melhorar a percepção de performance ao abrir o aplicativo.
*   **Detalhes:** Desenvolver uma tela de transição (Splash Screen) com a logo do app que fique visível enquanto o sistema carrega os dados do banco de dados em segundo plano. Isso evita que o usuário veja "telas piscando" ou informações em branco antes de o app estar pronto para uso.

## Como executar

```bash
flutter pub get
flutter run
```

## Observações

O projeto foi implementado com Flutter e usa persistência local para manter transações, categorias e saldo inicial entre execuções.
