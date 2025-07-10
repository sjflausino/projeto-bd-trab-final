# Docker Compose - PostgreSQL

Este projeto usa o Docker Compose para iniciar um contêiner do PostgreSQL configurado com um banco de dados e scripts de inicialização automáticos. Inclui também scripts para popular o banco de dados com dados de teste e para analisar o desempenho de consultas.

## Pré-requisitos

Antes de executar o Docker Compose e os scripts auxiliares, verifique se você possui os seguintes pré-requisitos:

  * [Docker](https://www.docker.com/get-started) instalado.
  * [Docker Compose](https://docs.docker.com/compose/install/) instalado.
  * **Python 3** e `pip` instalados (para o script de população de dados).
  * **`psycopg2-binary`** e **`Faker`** instalados para o script `populate.py`. Você pode instalá-los via pip:
    ```bash
    pip install psycopg2-binary Faker
    ```

## Estrutura do Projeto

Este repositório contém os seguintes arquivos e diretórios:

```
.
├── docker-compose.yml                  # Arquivo de configuração principal do Docker Compose
├── init-db/                            # Contém scripts SQL para inicialização do banco de dados
│   ├── 1_CREATE_TABLES.sql             # Script para criação das tabelas do banco de dados
│   ├── 3_FUNCTION.sql                  # Script para funções do banco de dados
│   ├── 4_TRIGGERS.sql                  # Script para triggers do banco de dados
│   └── 5_VIEWS.sql                     # Script para views do banco de dados
├── insert_triggers/                    # Diretório com scripts SQL para testar triggers específicos
│   ├── 01_certificado_valido.sql       # Script para testar trigger de certificado válido
│   ├── 02_certificado_invalido.sql     # Script para testar trigger de certificado inválido
│   ├── 03_monitor_valido.sql           # Script para testar trigger de monitor válido
│   ├── 04_monitor_invalido.sql         # Script para testar trigger de monitor inválido
│   └── 05_concluir_inscricao.sql       # Script para testar trigger de conclusão de inscrição
├── populate.py                         # Script Python para popular o banco de dados com dados de teste
├── populate_erros.txt                  # Log de erros gerado pelo script populate.py
├── run_performance_report.sh           # Script para gerar relatório de desempenho de consultas
├── relatorio_desempenho_consultas.txt  # Relatório de desempenho gerado pelo script run_performance_report.sh
├── README.md                           # Este arquivo de documentação
├── INDICES.sql                         # Script para criação de índices (uso auxiliar)
├── SELECTS.sql                         # Script com seleções SQL (uso auxiliar)
├── TRUNCATE.sql                        # Script para truncar tabelas (uso auxiliar)
└── av.txt                              # Arquivo auxiliar ou de saída (uso auxiliar)
```

## Como Executar o Docker Compose

1.  **Clone o repositório** (caso ainda não tenha feito isso):

    ```bash
    git clone <URL_DO_REPOSITORIO>
    cd <PASTA_DO_REPOSITORIO>
    ```

2.  **Verifique a configuração do Docker Compose**:
    Certifique-se de que o arquivo `docker-compose.yml` esteja configurado corretamente conforme suas necessidades. A configuração padrão usa a imagem do PostgreSQL versão 14, com a criação do banco de dados `postgres` e usuário `postgres`.

3.  **Crie os volumes e inicie os serviços**:

    Execute o seguinte comando para inicializar os contêineres:

    ```bash
    docker compose up -d
    ```

    O Docker Compose irá:

      * Baixar a imagem do PostgreSQL (caso não esteja presente).
      * Criar e iniciar o contêiner do PostgreSQL.
      * Mapear a porta 5432 do contêiner para a porta 5432 do host.
      * Executar qualquer script presente no diretório `./init-db` (scripts de inicialização).

4.  **Acessando o PostgreSQL**:

    Após o contêiner ser iniciado, você pode acessar o banco de dados PostgreSQL com qualquer cliente SQL, usando as credenciais definidas:

      * **Host**: `localhost`
      * **Porta**: `5432`
      * **Usuário**: `postgres`
      * **Senha**: `postgres` (ou a senha definida no `docker-compose.yml`)
      * **Banco de dados**: `postgres`

    Por exemplo, se você estiver usando o `psql`, você pode acessar o banco de dados da seguinte forma:

    ```bash
    psql -h localhost -p 5432 -U postgres -d postgres
    ```

5.  **Parar os contêineres**:

    Para parar e remover os contêineres, execute o seguinte comando:

    ```bash
    docker compose down
    ```

6.  **Remover volumes** (opcional):

    Se você quiser remover também os volumes, o que apagará todos os dados, execute:

    ```bash
    docker compose down -v
    ```

## Personalização

  * **Scripts de Inicialização**: Coloque seus scripts SQL no diretório `./init-db/`. Eles serão executados automaticamente durante a inicialização do banco de dados.
  * **Configuração do PostgreSQL**: Você pode modificar o arquivo `docker-compose.yml` para ajustar as configurações, como senha do banco de dados, usuário ou versão do PostgreSQL.

## Executando Scripts Auxiliares

Após o contêiner do PostgreSQL estar em execução e o banco de dados inicializado, você pode usar os scripts auxiliares para popular o banco de dados com dados de teste e para analisar o desempenho de consultas.

### 1\. Populando o Banco de Dados (`populate.py`)

Este script Python preenche o seu banco de dados PostgreSQL com dados de teste gerados aleatoriamente. É essencial para simular um ambiente real e testar o desempenho das suas consultas.

Para executar o script de população:

```bash
python populate.py
```

  * **Observações**:
      * O script irá truncar (limpar) todas as tabelas existentes no banco de dados antes de inserir novos dados. Isso garante um estado limpo a cada execução.
      * Erros ou avisos durante a população de dados serão registrados no console e em um arquivo `populate_erros.txt`.
      * Você pode ajustar a quantidade de dados gerados editando as variáveis de configuração no início do arquivo `populate.py` (ex: `NUM_USUARIOS`, `NUM_CURSOS`, etc.).

### 2\. Gerando o Relatório de Desempenho (`run_performance_report.sh`)

Este script Bash automatiza a execução de um conjunto de consultas SQL, tanto com quanto sem índices, mede seus tempos de execução e gera um relatório detalhado. Ele é ideal para analisar o impacto da criação de índices no desempenho das suas consultas.

Para executar o script de relatório de desempenho:

```bash
chmod +x run_performance_report.sh
```
```bash
./run_performance_report.sh
```

  * **Observações**:
      * O script `run_performance_report.sh` irá criar e dropar índices automaticamente durante sua execução para realizar os testes de comparação.
      * Ele gerará um arquivo `relatorio_desempenho_consultas.txt` no diretório raiz do projeto com os resultados das medições, incluindo tempos médios, desvio padrão e planos de execução (`EXPLAIN ANALYZE`).
      * O script cria arquivos SQL temporários (`query*.sql`, `create_indexes.sql`, `drop_indexes.sql`) e os remove após a execução.
      * As consultas testadas estão embutidas no próprio script. Você pode modificá-las ou adicionar novas consultas editando a função `create_sql_files` no `run_performance_report.sh`.

## Problemas Comuns

1.  **Erro de permissão ao acessar o banco de dados**:

      * Verifique se as credenciais no `docker-compose.yml` estão corretas.
      * Verifique se o PostgreSQL está rodando na porta 5432 e se não há conflitos com outros serviços.

2.  **Erro ao conectar ao banco de dados**:

      * Certifique-se de que o contêiner está em execução com o comando `docker ps`.

3.  **`command not found: psql` ou `command not found: docker compose`**:

      * Certifique-se de que o Docker, Docker Compose e o cliente `psql` (geralmente parte do pacote `postgresql-client`) estão instalados e configurados corretamente no seu PATH.

4.  **Erros de importação no `populate.py`**:

      * Confirme se você instalou as bibliotecas Python necessárias: `pip install psycopg2-binary Faker`.