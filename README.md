# FlowFinance 💸

O **FlowFinance** é um aplicativo mobile de gerenciamento financeiro pessoal, com foco em simplicidade, velocidade e organização. Ele opera **100% offline-first** com armazenamento local, garantindo extrema velocidade e privacidade total dos seus dados.

O grande diferencial do aplicativo é a **Entrada Inteligente (Smart Input)**, que permite ao usuário registrar transações como se estivesse mandando uma mensagem de texto, eliminando a burocracia dos apps financeiros tradicionais.

---

## 🚀 Funcionalidades Concluídas (MVP)

O projeto possui uma base sólida e completamente funcional, incluindo:

- 🧠 **Smart Input (Entrada Inteligente):** O app interpreta textos naturais (ex: `15,50 padaria ontem` ou `+ 5000 salario`), aplica primeira letra maiúscula, limpa stopwords e deduz datas e categorias automaticamente.
- 📊 **Resumo & Insights:** Geração de gráficos interativos locais (Pizza para categorias e Barras para dias da semana) e cálculos automáticos de média diária e maiores gastos.
- 🏷️ **Categorias e Metas:** Criação de categorias personalizadas com paleta de cores, ícones e barra de progresso para **Limite de Gastos Mensais (Orçamento)**.
- 🔒 **Segurança Nativa:** Proteção do aplicativo com AppLock utilizando Biometria, FaceID ou PIN do sistema.
- 🔄 **Transações Recorrentes:** Suporte para salvar assinaturas e contas fixas (mensais, semanais ou diárias).
- 💾 **Backup Seguro:** Exportação e Restauração de todo o banco de dados via arquivo físico real (`.json`), permitindo salvar no Google Drive ou iCloud.
- 🌓 **UX/UI Premium:** Suporte total a **Dark Mode** e Light Mode, navegação em carrosséis responsivos e opções de ocultar saldo com um toque.

---

## 🛠️ Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Roteamento:** `go_router`
- **Armazenamento Local:** `shared_preferences` (JSON estruturado)
- **Gráficos:** `fl_chart`
- **Segurança:** `local_auth`
- **Arquivos & Compartilhamento:** `file_picker` & `share_plus`
- **Tipografia:** `google_fonts` (Poppins)

---

## 💻 Como executar o projeto

Para rodar o projeto em modo de desenvolvimento (Debug):
```bash
flutter clean
flutter pub get
flutter run
```

Para gerar o arquivo **APK de Produção** (Pronto para instalar no Android):
```bash
flutter build apk --release
```
*(O arquivo gerado estará na pasta `build\app\outputs\flutter-apk\app-release.apk`)*

---

## 🗺️ Roadmap Futuro (Fase 2)

As próximas implementações focam em expandir a inteligência local do app:

- [ ] Sincronização multi-dispositivo opcional (Cloud Sync).
- [ ] OCR de comprovantes (Leitura de notas fiscais pela câmera).
- [ ] Exportação avançada de relatórios em PDF/CSV para contadores.

---

> **Nota do Desenvolvedor:** Este projeto foi arquitetado com base nos princípios de Clean Architecture, focando na separação de responsabilidades (Presentation, Domain, Data) e foi projetado para não depender de APIs externas, garantindo que o app nunca fique "fora do ar".
