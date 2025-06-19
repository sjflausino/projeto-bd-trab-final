# Docker Compose - PostgreSQL

Este projeto usa o Docker Compose para iniciar um contêiner do PostgreSQL configurado com um banco de dados e scripts de inicialização automáticos. Siga as etapas abaixo para rodar o contêiner localmente.

## Pré-requisitos

Antes de executar o Docker Compose, verifique se você possui os seguintes pré-requisitos:

- [Docker](https://www.docker.com/get-started) instalado
- [Docker Compose](https://docs.docker.com/compose/install/) instalado

## Estrutura do Projeto

Este repositório contém os seguintes arquivos e diretórios:

```
.
├── docker-compose.yml      # Arquivo de configuração do Docker Compose
├── init-db/                # Diretório com scripts SQL para inicialização do banco
│   └── init.sql            # Exemplo de script de inicialização (opcional)
└── README.md               # Este arquivo
```

## Como Executar o Docker Compose

1. **Clone o repositório** (caso ainda não tenha feito isso):

    ```bash
    git clone <URL_DO_REPOSITORIO>
    cd <PASTA_DO_REPOSITORIO>
    ```

2. **Verifique a configuração do Docker Compose**:
   Certifique-se de que o arquivo `docker-compose.yml` esteja configurado corretamente conforme suas necessidades. A configuração padrão usa a imagem do PostgreSQL versão 14, com a criação do banco de dados `postgres` e usuário `postgres`.

3. **Crie os volumes e inicie os serviços**:
   
    Execute o seguinte comando para inicializar os contêineres:

    ```bash
    docker compose up -d
    ```

    O Docker Compose irá:
    - Baixar a imagem do PostgreSQL (caso não esteja presente)
    - Criar e iniciar o contêiner do PostgreSQL
    - Mapear a porta 5432 do contêiner para a porta 5432 do host
    - Executar qualquer script presente no diretório `./init-db` (scripts de inicialização)

4. **Acessando o PostgreSQL**:
   
    Após o contêiner ser iniciado, você pode acessar o banco de dados PostgreSQL com qualquer cliente SQL, usando as credenciais definidas:

    - **Host**: `localhost`
    - **Porta**: `5432`
    - **Usuário**: `postgres`
    - **Senha**: `postgres` (ou a senha definida no `docker-compose.yml`)
    - **Banco de dados**: `postgres`

    Por exemplo, se você estiver usando o `psql`, você pode acessar o banco de dados da seguinte forma:

    ```bash
    psql -h localhost -p 5432 -U postgres -d postgres
    ```

5. **Parar os contêineres**:

    Para parar e remover os contêineres, execute o seguinte comando:

    ```bash
    docker compose down
    ```

6. **Remover volumes** (opcional):

    Se você quiser remover também os volumes, o que apagará todos os dados, execute:

    ```bash
    docker compose down -v
    ```

## Personalização

- **Scripts de Inicialização**: Coloque seus scripts SQL no diretório `./init-db/`. Eles serão executados automaticamente durante a inicialização do banco de dados.
  
- **Configuração do PostgreSQL**: Você pode modificar o arquivo `docker-compose.yml` para ajustar as configurações, como senha do banco de dados, usuário ou versão do PostgreSQL.

## Problemas Comuns

1. **Erro de permissão ao acessar o banco de dados**:
    - Verifique se as credenciais no `docker-compose.yml` estão corretas.
    - Verifique se o PostgreSQL está rodando na porta 5432 e se não há conflitos com outros serviços.

2. **Erro ao conectar ao banco de dados**:
    - Certifique-se de que o contêiner está em execução com o comando `docker ps`.
