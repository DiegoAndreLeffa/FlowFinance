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
