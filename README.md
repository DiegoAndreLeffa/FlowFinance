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

## O que ainda falta para concluir o que foi pedido

A seguir estão os itens que ainda precisam ser finalizados para fechar o MVP de forma mais completa:

- [ ] Criar gráficos e visualizações mais ricas para receitas, despesas e saldo
- [ ] Melhorar a entrada inteligente para reconhecer mais padrões de texto
- [ ] Adicionar opção de excluir/limpar todo o histórico com confirmação
- [ ] Criar uma tela de resumo mais completa com metas e insights simples
- [ ] Melhorar o fluxo de backup/importação com upload/download de arquivo real
- [ ] Adicionar testes automatizados para mais cenários de negócio
- [ ] Polir a interface e a experiência para uso diário


## Erros atuais


## Como executar

```bash
flutter pub get
flutter run
```

## Observações

O projeto foi implementado com Flutter e usa persistência local para manter transações, categorias e saldo inicial entre execuções.
