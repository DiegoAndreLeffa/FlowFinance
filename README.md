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

## Proxima Atualizações

## Implementando ainda

- [ ] Adicionar um botao de seleção no modal de recorrencias (entrada e saida de valores)
- [ ] Ampliar a palavras que o sistema reconhece para as categorias (ex: taxi, onibus uber -> todos entrão em tranporte)
- [ ] Ampliar a lista de categorias pre cadastradas
- [ ] Ampliar a lista de novas categorias que podem ser adicionadas, adicionar mais icones e cores para essas categoria tambem
- [ ] 

## Como executar

```bash
flutter pub get
flutter run
```

## Observações

O projeto foi implementado com Flutter e usa persistência local para manter transações, categorias e saldo inicial entre execuções.
