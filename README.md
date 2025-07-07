# Tánamesa

![Status do Projeto](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-BaaS-orange?logo=firebase)

Repositório do projeto Tánamesa, um aplicativo para combate ao desperdício de alimentos, desenvolvido no âmbito da disciplina de PROGRAMAÇÃO PARA DISPOSITIVOS MÓVEIS (DPADP0350) e Gestão de Novos Produtos e Marcas (CAD 1113) na Universidade Federal de Santa Maria (UFSM).

---

## Sobre o Projeto

O **Tánamesa** é um aplicativo mobile que tem como objetivo principal combater o desperdício de alimentos de forma inteligente e eficiente. A plataforma conecta doadores — como restaurantes, feiras e supermercados — com instituições sociais e ONGs que necessitam de alimentos para atender populações vulneráveis.

O projeto nasceu da observação de uma necessidade real da sociedade, aplicando tecnologia para criar uma solução de alto impacto social e sustentável.

---

##Funcionalidades Planejadas

Com base no teste de conceito realizado com potenciais usuários (doadores e ONGs), as seguintes funcionalidades foram definidas como essenciais:

* **Gestão de Perfis:** Cadastro e autenticação segura para Doadores e ONGs.
* **Cadastro de Doações:** Formulário detalhado para o doador especificar o tipo de alimento, quantidade, foto e data de validade.
* **Mapa e Geolocalização:** Visualização em tempo real das doações disponíveis em um mapa interativo.
* **Rotas Otimizadas:** Sugestão de rotas para as ONGs coletarem múltiplas doações de forma eficiente.
* **Comunicação Direta:** Um chat integrado para que doadores e ONGs possam combinar os detalhes da coleta.
* **Histórico e Relatórios:** Geração de relatórios de impacto para os doadores, mostrando a quantidade de alimentos doados e o alcance social.


---

##Tecnologias Utilizadas

Este projeto está sendo construído com as seguintes tecnologias:

* **Framework:** [Flutter](https://flutter.dev/) (Futuramente em Jetpack Compose)
* **Linguagem:** [Dart](https://dart.dev/) (Futuramente em Kotlin)
* **Backend & Banco de Dados (BaaS):** [Firebase](https://firebase.google.com/)
    * **Autenticação:** Firebase Authentication
    * **Banco de Dados NoSQL:** Cloud Firestore
    * **Armazenamento de Arquivos:** Firebase Storage (para fotos das doações)
---

## Como Executar o Projeto

Siga os passos abaixo para executar o projeto em seu ambiente local.

### Pré-requisitos

* Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
* Ter um editor de código como o [Android Studio](https://developer.android.com/studio).
* Um emulador Android/iOS ou um dispositivo físico conectado.

### Instalação

1.  Clone o repositório:
    ```sh
    git clone [URL_DO__REPOSITORIO]
    ```

2.  Navegue até a pasta do projeto:
    ```sh
    cd tanamesa
    ```

3.  Instale as dependências:
    ```sh
    flutter pub get
    ```
4.  **Importante:** Para conectar ao Firebase, certifique-se de que o arquivo `firebase_options.dart` está na pasta `lib/` e configurado corretamente para o seu projeto Firebase.

5.  Execute o aplicativo:
    ```sh
    flutter run
    ```

---
![142154318](https://github.com/user-attachments/assets/f20dfc26-0e20-470a-9b47-1b06bf067473)


## Autor
Fabricio Paula Rodrigues
E-mail Academico: fabricio.rodrigues@acad.ufsm.br 

![142154318](https://github.com/user-attachments/assets/f20dfc26-0e20-470a-9b47-1b06bf067473)


**Universidade Federal de Santa Maria (UFSM)** **Colégio Politecnico** **Sistemas Para Internet**
