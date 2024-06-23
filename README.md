# Deploy de Modelo de Machine Learning na AWS via Terraform

## Objetivo
O objetivo do projeto é demonstrar a capacidade de unir ferramentas de Data Science, Web Development, IaC e Cloud Computing para criar uma infraestrutura End-to-End completa e funcional.

O resultado final será uma Aplicação Web que gera previsões se um cliente realizará ou não uma próxima compra com base em 4 valores de compra inseridos.

## Descrição do Projeto

### 1. Infraestrutura
Este projeto buscou criar uma infraestrutura na AWS de forma automatizada utilizando Terraform para deploy de um modelo de Machine Learning.

Para isso foi criado um `Dockerfile` onde será instalado o terraform e configurado o AWS CLI.

Após isso o terraform criará a infraestrutura a partir do arquivo `main.tf` e gerará um endereço DNS por meio do `outputs.tf`.

Com o endereço DNS será possível acessar via HTTP o modelo de Machine Learning que estará hospedado numa instância AWS dentro da camada gratuita.

### 2. Modelo de Machine Learning
O modelo de Machine Learning utilizou o pacote `sklearn` para criar um simples modelo de classificação com 1000 observações, onde será feito o teste, treino e o predict junto a acurácia.

A partir disso ele arquivará os dados em um arquivo `.pkl` para uso da API.

### 3. API
Para ligar o Front End com o Back End foi desenvolvida uma API em `flask` para utilização do modelo treinado para previsão de forma acessível ao público.

Todas as features foram configuradas para o Front End `index.html` onde retornará **1** (o cliente fará outra compra) ou **0** (o cliente não fará outra compra).
