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

**3. [Melhoria/UI] Ajuste da paleta de cores do Modo Escuro (Dark Mode)**
*   **O que fazer:** Trocar a cor de fundo (background) do modo escuro.
*   **Detalhes:** Atualmente, o modo escuro pode estar cansativo ou com contraste ruim. Criar uma *branch/versão* de teste alterando o fundo de preto puro (ou a cor atual) para um **cinza escuro** (exemplo: `#121212` ou `#1E1E1E`, que é o padrão de conforto visual do Material Design).

**4. [Melhoria/Design] Refinamento das Notificações**
*   **O que fazer:** Retomar e detalhar o ticket anterior de notificações. 
*   **Detalhes:**
    *   É notificação *Push* (que chega com o app fechado) ou *In-app* (alertas dentro do app)

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
