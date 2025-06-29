import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
import logging
import os

# --- Configuração do Logging ---
LOG_FILE = "populate_erros.txt"
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.ERROR, # Apenas mensagens de nível ERROR e acima serão salvas no arquivo
    format='%(asctime)s - %(levelname)s - %(message)s'
)
# Adicionar um handler para console para ver todos os logs (INFO e acima) em tempo real
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO) # Nível INFO para o console (ver mais mensagens)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logging.getLogger().addHandler(console_handler)

# --- Configurações do Banco de Dados ---
DB_HOST = "localhost"
DB_NAME = "postgres"  # Substitua pelo nome do seu banco de dados
DB_USER = "postgres"  # Substitua pelo seu nome de usuário do PostgreSQL
DB_PASSWORD = "postgres" # Substitua pela sua senha do PostgreSQL
DB_PORT = "5432"

# --- Configurações de Geração de Dados ---
NUM_USUARIOS = 10000
NUM_CATEGORIAS = 10
NUM_CURSOS = 200
NUM_MODULOS_POR_CURSO = 5
NUM_AULAS_POR_MODULO = 4
NUM_INSCRICOES_POR_ALUNO = 3 # Multiplicador para inscrições
NUM_AVALIACOES_POR_INSCRICAO = 1 # Multiplicador para avaliações
NUM_FORUNS_POR_CURSO = 1 # Multiplicador para fóruns
NUM_POSTAGENS_POR_FORUM = 5 # Multiplicador para postagens
NUM_COMENTARIOS_POR_POSTAGEM = 2 # Multiplicador para comentários
NUM_MENSAGENS_POR_USUARIO = 5 # AUMENTADO PARA GERAR MAIS MENSAGENS GERAIS
NUM_CERTIFICADOS_ALVO = 150 # Número total de certificados a serem gerados, agora como alvo
NUM_MONITORES = 50 # Número total de monitores a serem gerados
NUM_MENSAGENS_ESPECIFICAS_CONVERSA = 50 # NOVA: Número de mensagens entre os IDs 5 e 6
NUM_CURSOS_ALICE_SE_INSCREVE = 3 # Quantos cursos Alice vai se inscrever
PERCENTUAL_AULAS_ALICE_ASSISTE = 1.0 # Alice agora assiste 100% das aulas nos cursos que ela se inscreve

# Inicializa o Faker
fake = Faker('pt_BR')

def get_db_connection():
    """Estabelece e retorna uma conexão com o banco de dados."""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=DB_PORT
        )
        logging.info("Conexão com o banco de dados estabelecida com sucesso.")
        return conn
    except Exception as e:
        logging.critical(f"Erro ao conectar ao banco de dados: {e}")
        return None

def truncate_tables(cursor, conn):
    """Truncates all tables in the correct order to avoid foreign key violations."""
    logging.info("Iniciando truncagem das tabelas...")
    # A ordem importa devido às restrições de chave estrangeira
    tables_to_truncate = [
        "mensagens", "comentarios", "postagens", "foruns",
        "certificados", "avaliacoes", "progresso", "inscricoes",
        "aulas", "modulos", "cursos", "categorias",
        "alunos", "professores", "administradores", "monitores", "usuarios"
    ]
    for table in tables_to_truncate:
        try:
            # RESTART IDENTITY para reiniciar sequências de IDs (ex: SERIAL)
            # CASCADE para apagar dependências de FK (CUIDADO! Isso apaga dados relacionados)
            cursor.execute(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE;")
            conn.commit() # Commit a cada truncate para efeito imediato
            logging.info(f"Tabela '{table}' truncada com sucesso.")
        except Exception as e:
            conn.rollback() # Rollback da tentativa de truncagem atual
            logging.critical(f"Erro FATAL ao truncar a tabela '{table}': {e}. Interrompendo.")
            raise # Re-lança a exceção para interromper o main se o truncate falhar
    logging.info("Todas as tabelas foram truncadas.")

def populate_usuarios(cursor, num_users=NUM_USUARIOS):
    """Popula a tabela usuarios."""
    logging.info("Populando usuarios...")
    usuarios_ids = {'aluno': [], 'professor': [], 'administrador': []}
    for _ in range(num_users):
        nome = fake.name()
        email = fake.unique.email()
        senha = fake.sha256(raw_output=False) # Senha hash simulada
        tipo = random.choice(['aluno', 'professor', 'administrador'])
        data_cadastro = fake.date_between(start_date='-2y', end_date='today')

        try:
            cursor.execute(
                "INSERT INTO usuarios (nome, email, senha, tipo, data_cadastro) VALUES (%s, %s, %s, %s, %s) RETURNING usuario_id;",
                (nome, email, senha, tipo, data_cadastro)
            )
            user_id = cursor.fetchone()[0]
            usuarios_ids[tipo].append(user_id)
        except Exception as e:
            logging.error(f"Erro ao inserir usuário '{nome}' ({email}): {e}")
            fake.unique.clear() # Limpa o cache de unique para tentar evitar mais erros de email
            continue
    logging.info(f"Inseridos {len(usuarios_ids['aluno']) + len(usuarios_ids['professor']) + len(usuarios_ids['administrador'])} usuários.")
    return usuarios_ids

def populate_alunos(cursor, aluno_ids):
    """Popula a tabela alunos."""
    logging.info("Populando alunos...")
    for aluno_id in aluno_ids:
        data_nascimento = fake.date_of_birth(minimum_age=18, maximum_age=60)
        telefone = fake.phone_number()
        try:
            cursor.execute(
                "INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES (%s, %s, %s);",
                (aluno_id, data_nascimento, telefone)
            )
        except Exception as e:
            logging.error(f"Erro ao inserir aluno {aluno_id}: {e}")
    logging.info(f"Inseridos {len(aluno_ids)} alunos.")

def populate_professores(cursor, professor_ids):
    """Popula a tabela professores."""
    logging.info("Populando professores...")
    for professor_id in professor_ids:
        curriculo = fake.text(max_nb_chars=500)
        especialidade = fake.job()
        try:
            cursor.execute(
                "INSERT INTO professores (professor_id, curriculo, especialidade) VALUES (%s, %s, %s);",
                (professor_id, curriculo, especialidade)
            )
        except Exception as e:
            logging.error(f"Erro ao inserir professor {professor_id}: {e}")
    logging.info(f"Inseridos {len(professor_ids)} professores.")

def populate_administradores(cursor, administrador_ids):
    """Popula a tabela administradores."""
    logging.info("Populando administradores...")
    for admin_id in administrador_ids:
        cargo = fake.job()
        nivel_acesso = random.randint(1, 5)
        try:
            cursor.execute(
                "INSERT INTO administradores (administrador_id, cargo, nivel_acesso) VALUES (%s, %s, %s);",
                (admin_id, cargo, nivel_acesso)
            )
        except Exception as e:
            logging.error(f"Erro ao inserir administrador {admin_id}: {e}")
    logging.info(f"Inseridos {len(administrador_ids)} administradores.")

def populate_categorias(cursor, num_categorias=NUM_CATEGORIAS):
    """Popula a tabela categorias."""
    logging.info("Populando categorias...")
    categoria_ids = []
    for _ in range(num_categorias):
        nome = fake.unique.word().capitalize() + " " + fake.word().capitalize()
        descricao = fake.sentence()
        try:
            cursor.execute(
                "INSERT INTO categorias (nome, descricao) VALUES (%s, %s) RETURNING categoria_id;",
                (nome, descricao)
            )
            categoria_ids.append(cursor.fetchone()[0])
        except Exception as e:
            logging.error(f"Erro ao inserir categoria '{nome}': {e}")
            fake.unique.clear() # Limpa o cache de unique para tentar novamente com outro nome
            continue
    logging.info(f"Inseridas {len(categoria_ids)} categorias.")
    return categoria_ids

def populate_cursos(cursor, categoria_ids, professor_ids, num_cursos=NUM_CURSOS):
    """Popula a tabela cursos."""
    logging.info("Populando cursos...")
    curso_ids = []
    # Garante que temos IDs válidos para FKs
    if not categoria_ids:
        logging.warning("Não há categorias disponíveis para criar cursos.")
        return []
    if not professor_ids:
        logging.warning("Não há professores disponíveis para criar cursos.")
        return []

    for _ in range(num_cursos):
        titulo = fake.catch_phrase().capitalize() + " de " + fake.word().capitalize()
        descricao = fake.paragraph(nb_sentences=3)
        categoria_id = random.choice(categoria_ids)
        professor_id = random.choice(professor_ids)
        data_criacao = fake.date_between(start_date='-1y', end_date='today')
        ativo = random.choice([True, False])

        try:
            cursor.execute(
                "INSERT INTO cursos (titulo, descricao, categoria_id, professor_id, data_criacao, ativo) VALUES (%s, %s, %s, %s, %s, %s) RETURNING curso_id;",
                (titulo, descricao, categoria_id, professor_id, data_criacao, ativo)
            )
            curso_ids.append(cursor.fetchone()[0])
        except Exception as e:
            logging.error(f"Erro ao inserir curso '{titulo}': {e}")
            continue
    logging.info(f"Inseridos {len(curso_ids)} cursos.")
    return curso_ids

def populate_modulos(cursor, curso_ids, num_modulos_per_curso=NUM_MODULOS_POR_CURSO):
    """Popula a tabela modulos."""
    logging.info("Populando modulos...")
    modulo_ids = []
    if not curso_ids:
        logging.warning("Não há cursos disponíveis para criar módulos.")
        return []
    for curso_id in curso_ids:
        for i in range(1, num_modulos_per_curso + 1):
            titulo = f"Módulo {i}: {fake.bs().capitalize()}"
            ordem = i
            try:
                cursor.execute(
                    "INSERT INTO modulos (curso_id, titulo, ordem) VALUES (%s, %s, %s) RETURNING modulo_id;",
                    (curso_id, titulo, ordem)
                )
                modulo_ids.append(cursor.fetchone()[0])
            except Exception as e:
                logging.error(f"Erro ao inserir módulo '{titulo}' para curso {curso_id}: {e}")
    logging.info(f"Inseridos {len(modulo_ids)} módulos.")
    return modulo_ids

def populate_aulas(cursor, modulo_ids, num_aulas_per_modulo=NUM_AULAS_POR_MODULO):
    """Popula a tabela aulas."""
    logging.info("Populando aulas...")
    aula_ids = []
    # Mapear aula_id para curso_id para facilitar o progresso
    aula_to_curso_map = {}
    if not modulo_ids:
        logging.warning("Não há módulos disponíveis para criar aulas.")
        return [], {}
    
    # Buscar curso_id para cada modulo_id
    modulo_to_curso_map = {}
    if modulo_ids: # Adicionado para garantir que modulo_ids não está vazio antes da query
        try:
            # Precisa buscar os curso_id dos módulos para mapear corretamente aulas a cursos
            cursor.execute(f"SELECT modulo_id, curso_id FROM modulos WHERE modulo_id IN ({','.join(map(str, modulo_ids))});")
            for mod_id, cur_id in cursor.fetchall():
                modulo_to_curso_map[mod_id] = cur_id
        except Exception as e:
            logging.error(f"Erro ao buscar curso_id para módulos (em populate_aulas): {e}")

    for modulo_id in modulo_ids:
        for i in range(1, num_aulas_per_modulo + 1):
            titulo = f"Aula {i}: {fake.catch_phrase()}"
            descricao = fake.sentence()
            video_url = fake.url() + "/video"
            ordem = i
            try:
                cursor.execute(
                    "INSERT INTO aulas (modulo_id, titulo, descricao, video_url, ordem) VALUES (%s, %s, %s, %s, %s) RETURNING aula_id;",
                    (modulo_id, titulo, descricao, video_url, ordem)
                )
                aula_id = cursor.fetchone()[0]
                aula_ids.append(aula_id)
                # Associar a aula ao seu curso através do módulo
                if modulo_id in modulo_to_curso_map:
                    aula_to_curso_map[aula_id] = modulo_to_curso_map[modulo_id]
            except Exception as e:
                logging.error(f"Erro ao inserir aula '{titulo}' para módulo {modulo_id}: {e}")
    logging.info(f"Inseridas {len(aula_ids)} aulas.")
    return aula_ids, aula_to_curso_map

def populate_inscricoes(cursor, aluno_ids, curso_ids, num_inscricoes_total):
    """Popula a tabela inscricoes."""
    logging.info("Populando inscricoes...")
    inserted_count = 0
    if not aluno_ids or not curso_ids:
        logging.warning("Não há alunos ou cursos disponíveis para criar inscrições.")
        return

    inscricoes_to_insert = []
    # Tenta criar um número de inscrições baseado na média desejada por aluno
    for aluno_id in random.sample(aluno_ids, min(len(aluno_ids), num_inscricoes_total)): # Limita a iteração a um subconjunto de alunos
        num_cursos_for_aluno = random.randint(1, NUM_INSCRICOES_POR_ALUNO * 2) # Varia um pouco o número de cursos por aluno
        selected_cursos = random.sample(curso_ids, min(num_cursos_for_aluno, len(curso_ids)))
        for curso_id in selected_cursos:
            status = random.choice(['em andamento', 'concluido', 'cancelado'])
            data_inscricao = fake.date_between(start_date='-1y', end_date='today')
            inscricoes_to_insert.append((aluno_id, curso_id, status, data_inscricao))

    # Usar um set para garantir pares únicos de (aluno_id, curso_id)
    unique_inscricoes = list(set(inscricoes_to_insert))
    random.shuffle(unique_inscricoes) # Embaralha para pegar um subconjunto se necessário

    for aluno_id, curso_id, status, data_inscricao in unique_inscricoes[:num_inscricoes_total]:
        try:
            cursor.execute(
                "INSERT INTO inscricoes (aluno_id, curso_id, status, data_inscricao) VALUES (%s, %s, %s, %s);",
                (aluno_id, curso_id, status, data_inscricao)
            )
            inserted_count += 1
        except psycopg2.errors.UniqueViolation:
            logging.debug(f"Inscrição duplicada para aluno {aluno_id}, curso {curso_id}. Ignorando.")
            pass # Já existe uma inscrição para este aluno e curso, ignorar
        except Exception as e:
            logging.error(f"Erro ao inserir inscrição para aluno {aluno_id}, curso {curso_id}: {e}")
    logging.info(f"Inseridas {inserted_count} inscrições.")


def populate_progresso(cursor, aluno_ids, aula_to_curso_map):
    """
    Popula a tabela progresso, garantindo que um número razoável de alunos
    assista a TODAS as aulas de ALGUNS de seus cursos inscritos,
    para que certificados possam ser gerados.
    """
    logging.info("Populando progresso...")
    inserted_count = 0
    progresso_data_to_insert = []

    # 1. Obter todas as inscrições válidas
    inscricoes_validas = []
    try:
        cursor.execute("SELECT aluno_id, curso_id FROM inscricoes WHERE status IN ('em andamento', 'concluido');")
        inscricoes_validas = cursor.fetchall()
    except Exception as e:
        logging.error(f"Erro ao buscar inscrições para progresso: {e}")
        return

    if not inscricoes_validas:
        logging.warning("Não há inscrições válidas para gerar progresso. Pulando.")
        return
    
    # 2. Definir quantos % de alunos terão progresso completo em pelo menos um curso
    percentual_alunos_com_progresso_completo = 0.3 # 30% dos alunos tentarão completar cursos
    num_alunos_com_progresso_completo = max(1, int(len(aluno_ids) * percentual_alunos_com_progresso_completo))
    
    alunos_para_completar_cursos = random.sample(aluno_ids, num_alunos_com_progresso_completo)

    # Mapear aulas por curso para acesso rápido
    aulas_por_curso = {}
    for aula_id, curso_id in aula_to_curso_map.items():
        aulas_por_curso.setdefault(curso_id, []).append(aula_id)

    # 3. Iterar sobre as inscrições e gerar progresso
    for aluno_id, curso_id in inscricoes_validas:
        if curso_id not in aulas_por_curso:
            continue # Curso sem aulas, ignora

        aulas_do_curso = aulas_por_curso[curso_id]
        
        if aluno_id in alunos_para_completar_cursos and random.random() < 0.7: # 70% de chance de completar para esses alunos
            # Marcar TODAS as aulas deste curso como assistidas
            aulas_a_marcar = aulas_do_curso
            logging.debug(f"Aluno {aluno_id} (completo) no curso {curso_id} terá {len(aulas_a_marcar)} aulas marcadas.")
        else:
            # Marcar um percentual aleatório das aulas (parcial)
            percentual_assistido = random.uniform(0.1, 0.7) # Entre 10% e 70%
            num_aulas_a_marcar = int(len(aulas_do_curso) * percentual_assistido)
            aulas_a_marcar = random.sample(aulas_do_curso, min(num_aulas_a_marcar, len(aulas_do_curso)))
            logging.debug(f"Aluno {aluno_id} (parcial) no curso {curso_id} terá {len(aulas_a_marcar)} aulas marcadas.")

        for aula_id in aulas_a_marcar:
            data_visualizacao = fake.date_between(start_date='-6m', end_date='today')
            progresso_data_to_insert.append((aula_id, aluno_id, True, data_visualizacao))

    # Inserir dados de progresso de forma eficiente
    unique_progresso_data = list(set(progresso_data_to_insert))
    random.shuffle(unique_progresso_data) # Opcional: para randomizar a ordem de inserção

    for aula_id, aluno_id, assistido, data_visualizacao in unique_progresso_data:
        try:
            cursor.execute(
                "INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao) VALUES (%s, %s, %s, %s);",
                (aula_id, aluno_id, assistido, data_visualizacao)
            )
            inserted_count += 1
        except psycopg2.errors.UniqueViolation:
            logging.debug(f"Progresso duplicado para aula {aula_id}, aluno {aluno_id}. Ignorando.")
            pass
        except Exception as e:
            logging.error(f"Erro ao inserir progresso para aula {aula_id}, aluno {aluno_id}: {e}")
    logging.info(f"Inseridos {inserted_count} registros de progresso.")


def populate_certificados(cursor, num_certificados_alvo):
    """
    Popula a tabela certificados.
    Tenta pegar pares aluno-curso que, APOS A POPULACAO DE PROGRESSO E AVALIACOES,
    devem satisfazer os requisitos do trigger.
    """
    logging.info("Populando certificados...")
    inserted_count = 0
    
    # 1. Obter todos os pares aluno_id, curso_id de inscrições 'concluido' ou 'em andamento'
    # Vamos focar apenas nos que têm chance de sucesso real.
    candidatos_a_certificado = []
    try:
        # Pega inscrições com status 'concluido' ou 'em andamento'
        cursor.execute("SELECT aluno_id, curso_id FROM inscricoes WHERE status IN ('concluido', 'em andamento');")
        inscricoes_existentes = cursor.fetchall()
        logging.info(f"Encontradas {len(inscricoes_existentes)} inscrições existentes para verificar certificados.")
    except Exception as e:
        logging.error(f"Erro ao buscar inscrições para candidatos a certificado: {e}")
        return

    if not inscricoes_existentes:
        logging.warning("Não há inscrições existentes para tentar gerar certificados. Pulando.")
        return
        
    # Para cada inscrição, verificar se o aluno tem todas as aulas assistidas e nota suficiente
    # Isso é um "simulador" do trigger para evitar erros desnecessários.
    for aluno_id, curso_id in inscricoes_existentes:
        # Verifica progresso completo (simulando a lógica do trigger check_certificado)
        # Primeiro, quantas aulas existem no curso?
        cursor.execute("""
            SELECT COUNT(a.aula_id)
            FROM aulas a
            JOIN modulos m ON a.modulo_id = m.modulo_id
            WHERE m.curso_id = %s;
        """, (curso_id,))
        total_aulas_curso = cursor.fetchone()[0]

        if total_aulas_curso == 0:
            continue # Não há aulas no curso, não pode ter certificado.

        # Quantas aulas o aluno assistiu neste curso?
        cursor.execute("""
            SELECT COUNT(p.aula_id)
            FROM progresso p
            JOIN aulas a ON p.aula_id = a.aula_id
            JOIN modulos m ON a.modulo_id = m.modulo_id
            WHERE p.aluno_id = %s AND m.curso_id = %s AND p.assistido = TRUE;
        """, (aluno_id, curso_id))
        aulas_assistidas_aluno = cursor.fetchone()[0]

        if aulas_assistidas_aluno != total_aulas_curso:
            logging.debug(f"Aluno {aluno_id} curso {curso_id}: Não assistiu todas as aulas ({aulas_assistidas_aluno}/{total_aulas_curso}).")
            continue # Não assistiu todas as aulas

        # Verifica nota (simulando a lógica do trigger check_certificado)
        cursor.execute("""
            SELECT nota FROM avaliacoes WHERE aluno_id = %s AND curso_id = %s;
        """, (aluno_id, curso_id))
        resultado_nota = cursor.fetchone()
        
        if resultado_nota is None or resultado_nota[0] < 3: # Nota deve ser >= 3
            logging.debug(f"Aluno {aluno_id} curso {curso_id}: Nota insuficiente ou inexistente ({resultado_nota}).")
            continue # Nota insuficiente ou não avaliado

        # Se passou por todas as verificações, adiciona aos candidatos
        candidatos_a_certificado.append((aluno_id, curso_id))

    logging.info(f"Encontrados {len(candidatos_a_certificado)} pares aluno-curso que *provavelmente* passarão no trigger de certificado.")

    if not candidatos_a_certificado:
        logging.warning("Não há candidatos válidos a certificado após a filtragem. Pulando população de certificados.")
        return

    # Tenta gerar certificados a partir desses pares, limitado ao total desejado
    random.shuffle(candidatos_a_certificado) # Embaralha para pegar aleatoriamente
    for aluno_id, curso_id in candidatos_a_certificado[:num_certificados_alvo]:
        data_emissao = fake.date_between(start_date='-1y', end_date='today')
        codigo_validacao = fake.unique.uuid4()
        try:
            cursor.execute(
                "INSERT INTO certificados (aluno_id, curso_id, data_emissao, codigo_validacao) VALUES (%s, %s, %s, %s);",
                (aluno_id, curso_id, data_emissao, codigo_validacao)
            )
            inserted_count += 1
            logging.debug(f"Certificado inserido para aluno {aluno_id}, curso {curso_id}.")
        except psycopg2.errors.UniqueViolation:
            logging.warning(f"Certificado duplicado para aluno {aluno_id}, curso {curso_id}. Ignorando.")
            pass
        except Exception as e:
            # Este erro ainda pode ocorrer se houver uma condição de corrida ou outro trigger
            logging.error(f"Erro ao inserir certificado para aluno {aluno_id}, curso {curso_id}: {e}")
    logging.info(f"Inseridos {inserted_count} certificados.")

def populate_avaliacoes(cursor, num_avaliacoes_total):
    """Popula a tabela avaliacoes, priorizando notas altas para alunos que se esperam ter certificado."""
    logging.info("Populando avaliacoes...")
    inserted_count = 0
    
    try:
        cursor.execute("SELECT aluno_id, curso_id FROM inscricoes;")
        existing_enrollments = cursor.fetchall()
        logging.info(f"Encontradas {len(existing_enrollments)} inscrições existentes para avaliações.")
    except Exception as e:
        logging.error(f"Erro ao buscar inscrições existentes para avaliações: {e}")
        existing_enrollments = []

    if not existing_enrollments:
        logging.warning("Não há inscrições existentes para criar avaliações. Pulando população de avaliações.")
        return

    # Seleciona aleatoriamente entre as inscrições existentes
    random.shuffle(existing_enrollments)
    selected_avaliacoes_pairs = existing_enrollments[:num_avaliacoes_total]

    for aluno_id, curso_id in selected_avaliacoes_pairs:
        # Para aumentar a chance de certificado, dar nota alta (3 a 5)
        nota = random.randint(3, 5) 
        comentario = fake.sentence() if random.random() > 0.3 else None # Nem toda avaliação tem comentário
        data_avaliacao = fake.date_between(start_date='-6m', end_date='today')
        try:
            cursor.execute(
                "INSERT INTO avaliacoes (aluno_id, curso_id, nota, comentario, data_avaliacao) VALUES (%s, %s, %s, %s, %s);",
                (aluno_id, curso_id, nota, comentario, data_avaliacao)
            )
            inserted_count += 1
        except psycopg2.errors.UniqueViolation:
            logging.debug(f"Avaliação duplicada para aluno {aluno_id}, curso {curso_id}. Ignorando.")
            pass
        except Exception as e:
            logging.error(f"Erro ao inserir avaliação para aluno {aluno_id}, curso {curso_id}: {e}")
    logging.info(f"Inseridas {inserted_count} avaliações.")

def populate_foruns(cursor, curso_ids, num_foruns_total):
    """Popula a tabela foruns."""
    logging.info("Populando foruns...")
    forum_ids = []
    if not curso_ids:
        logging.warning("Não há cursos disponíveis para criar fóruns.")
        return []

    # Garante que cada curso tenha pelo menos um fórum, e adiciona mais aleatoriamente
    cursos_with_forum = set()
    for curso_id in curso_ids:
        # A chance é NUM_FORUNS_POR_CURSO. Se for 1, cada curso terá 1 fórum garantido.
        if random.random() < NUM_FORUNS_POR_CURSO:
            titulo = fake.sentence(nb_words=5).replace('.', '') + " - Fórum"
            data_criacao = fake.date_between(start_date='-1y', end_date='today')
            try:
                cursor.execute(
                    "INSERT INTO foruns (curso_id, titulo, data_criacao) VALUES (%s, %s, %s) RETURNING forum_id;",
                    (curso_id, titulo, data_criacao)
                )
                forum_ids.append(cursor.fetchone()[0])
                cursos_with_forum.add(curso_id)
            except Exception as e:
                logging.error(f"Erro ao inserir fórum para curso {curso_id} ('{titulo}'): {e}")

    # Adiciona fóruns extras até o total desejado, se ainda não atingido
    while len(forum_ids) < num_foruns_total:
        curso_id = random.choice(curso_ids)
        titulo = fake.sentence(nb_words=5).replace('.', '') + " - Fórum"
        data_criacao = fake.date_between(start_date='-1y', end_date='today')
        try:
            cursor.execute(
                "INSERT INTO foruns (curso_id, titulo, data_criacao) VALUES (%s, %s, %s) RETURNING forum_id;",
                (curso_id, titulo, data_criacao)
            )
            forum_ids.append(cursor.fetchone()[0])
        except Exception as e:
            logging.error(f"Erro ao inserir fórum (extra) para curso {curso_id} ('{titulo}'): {e}")
            break # Evita loop infinito se houver problemas de inserção

    logging.info(f"Inseridos {len(forum_ids)} fóruns.")
    return forum_ids

def populate_postagens(cursor, forum_ids, usuario_ids, num_postagens_total):
    """Popula a tabela postagens."""
    logging.info("Populando postagens...")
    postagem_ids = []
    all_user_ids = usuario_ids['aluno'] + usuario_ids['professor'] + usuario_ids['administrador']

    if not forum_ids or not all_user_ids:
        logging.warning("Não há fóruns ou usuários para criar postagens.")
        return []

    for _ in range(num_postagens_total):
        forum_id = random.choice(forum_ids)
        usuario_id = random.choice(all_user_ids)
        conteudo = fake.paragraph(nb_sentences=random.randint(3, 7))
        data_postagem = fake.date_time_between(start_date='-6m', end_date='now')

        try:
            cursor.execute(
                "INSERT INTO postagens (forum_id, usuario_id, conteudo, data_postagem) VALUES (%s, %s, %s, %s) RETURNING postagem_id;",
                (forum_id, usuario_id, conteudo, data_postagem)
            )
            postagem_ids.append(cursor.fetchone()[0])
        except Exception as e:
            logging.error(f"Erro ao inserir postagem para fórum {forum_id}, usuário {usuario_id}: {e}")
    logging.info(f"Inseridas {len(postagem_ids)} postagens.")
    return postagem_ids

def populate_comentarios(cursor, postagem_ids, usuario_ids, num_comentarios_total):
    """Popula a tabela comentarios."""
    logging.info("Populando comentarios...")
    inserted_count = 0
    all_user_ids = usuario_ids['aluno'] + usuario_ids['professor'] + usuario_ids['administrador']

    if not postagem_ids or not all_user_ids:
        logging.warning("Não há postagens ou usuários para criar comentários.")
        return

    for _ in range(num_comentarios_total):
        postagem_id = random.choice(postagem_ids)
        usuario_id = random.choice(all_user_ids)
        conteudo = fake.sentence()
        data_comentario = fake.date_time_between(start_date='-3m', end_date='now')

        try:
            cursor.execute(
                "INSERT INTO comentarios (postagem_id, usuario_id, conteudo, data_comentario) VALUES (%s, %s, %s, %s);",
                (postagem_id, usuario_id, conteudo, data_comentario)
            )
            inserted_count += 1
        except psycopg2.errors.UniqueViolation:
            logging.debug(f"Comentário duplicado para postagem {postagem_id}, usuário {usuario_id}. Ignorando.")
            pass
        except Exception as e:
            logging.error(f"Erro ao inserir comentário para postagem {postagem_id}, usuário {usuario_id}: {e}")
    logging.info(f"Inseridos {inserted_count} comentários.")

def populate_monitores(cursor, num_monitores_total):
    """
    Popula a tabela monitores.
    Tenta buscar pares aluno-curso que já possuem certificado para aumentar a chance de sucesso.
    """
    logging.info("Populando monitores...")
    inserted_count = 0

    # Tenta buscar pares aluno-curso que já possuem certificado
    try:
        cursor.execute("SELECT aluno_id, curso_id FROM certificados;")
        certified_pairs = cursor.fetchall()
        logging.info(f"Encontrados {len(certified_pairs)} pares aluno-curso com certificado para monitores.")
    except Exception as e:
        logging.error(f"Erro ao buscar certificados existentes para monitores: {e}")
        certified_pairs = [] # Fallback

    if not certified_pairs:
        logging.warning("Não há certificados existentes para criar monitores. Pulando população de monitores.")
        return

    # Seleciona aleatoriamente entre os pares que já possuem certificado
    selected_monitors_pairs = random.sample(certified_pairs, min(num_monitores_total, len(certified_pairs)))

    for aluno_id, curso_id in selected_monitors_pairs:
        data_inicio = fake.date_between(start_date='-1y', end_date='-3m')
        data_fim = fake.date_between(start_date=data_inicio, end_date='today') if random.random() > 0.5 else None
        try:
            cursor.execute(
                "INSERT INTO monitores (aluno_id, curso_id, data_inicio, data_fim) VALUES (%s, %s, %s, %s);",
                (aluno_id, curso_id, data_inicio, data_fim)
            )
            inserted_count += 1
        except psycopg2.errors.UniqueViolation:
            logging.warning(f"Monitor duplicado para aluno {aluno_id}, curso {curso_id}. Ignorando.")
            pass
        except Exception as e:
            logging.error(f"Erro ao inserir monitor para aluno {aluno_id}, curso {curso_id}: {e}")
    logging.info(f"Inseridos {inserted_count} monitores.")

def populate_mensagens(cursor, usuario_ids, num_mensagens_total):
    """Popula a tabela mensagens com mensagens gerais."""
    logging.info("Populando mensagens gerais...")
    inserted_count = 0
    all_user_ids = usuario_ids['aluno'] + usuario_ids['professor'] + usuario_ids['administrador']
    if len(all_user_ids) < 2:
        logging.warning("Não há usuários suficientes para criar mensagens gerais.")
        return

    for i in range(num_mensagens_total):
        remetente_id = random.choice(all_user_ids)
        possible_destinatarios = [uid for uid in all_user_ids if uid != remetente_id]
        if not possible_destinatarios:
            logging.warning(f"Mensagem geral {i+1}: Não há outro usuário disponível para enviar mensagem de {remetente_id}. Pulando.")
            continue

        destinatario_id = random.choice(possible_destinatarios)
        conteudo = fake.sentence()
        data_envio = fake.date_time_between(start_date='-6m', end_date='now')
        lida = random.choice([True, False])

        try:
            cursor.execute(
                "INSERT INTO mensagens (remetente_id, destinatario_id, conteudo, data_envio, lida) VALUES (%s, %s, %s, %s, %s);",
                (remetente_id, destinatario_id, conteudo, data_envio, lida)
            )
            inserted_count += 1
        except psycopg2.errors.UniqueViolation:
            logging.debug(f"Mensagem geral {i+1} duplicada para remetente {remetente_id}, destinatário {destinatario_id}. Ignorando.")
            pass
        except Exception as e:
            logging.error(f"Mensagem geral {i+1}: Erro ao inserir mensagem de {remetente_id} para {destinatario_id}: {e}")
    logging.info(f"Inseridas {inserted_count} mensagens gerais.")

def populate_mensagens_especificas_conversa(cursor, usuario_id1, usuario_id2, num_mensagens=NUM_MENSAGENS_ESPECIFICAS_CONVERSA):
    """Popula a tabela mensagens com uma conversa específica entre dois usuários."""
    logging.info(f"Populando {num_mensagens} mensagens específicas entre usuários {usuario_id1} e {usuario_id2}...")
    inserted_count = 0
    
    # Define uma data de início para a conversa e adiciona um pequeno delta para cada mensagem
    start_time = datetime.now() - timedelta(days=7) # Inicia há 7 dias
    
    for i in range(num_mensagens):
        # Alterna remetente e destinatário
        if i % 2 == 0:
            remetente = usuario_id1
            destinatario = usuario_id2
        else:
            remetente = usuario_id2
            destinatario = usuario_id1
        
        conteudo = fake.text(max_nb_chars=50) # Mensagem mais curta para chat
        data_envio = start_time + timedelta(minutes=i*random.randint(1, 5)) # Incrementa a data para simular fluxo de conversa
        lida = random.choice([True, False])

        try:
            cursor.execute(
                "INSERT INTO mensagens (remetente_id, destinatario_id, conteudo, data_envio, lida) VALUES (%s, %s, %s, %s, %s);",
                (remetente, destinatario, conteudo, data_envio, lida)
            )
            inserted_count += 1
        except Exception as e:
            logging.error(f"Erro ao inserir mensagem específica {i+1} de {remetente} para {destinatario}: {e}")
    logging.info(f"Inseridas {inserted_count} mensagens específicas entre usuários {usuario_id1} e {usuario_id2}.")

def add_specific_user_and_progress(cursor, curso_ids, aula_to_curso_map):
    """
    Adiciona a usuária Alice Souza e garante que ela tenha progresso em alguns cursos.
    Retorna o ID de usuário de Alice.
    """
    logging.info("Adicionando a usuária Alice Souza com progresso em cursos...")
    alice_id = None

    # 1. Inserir Alice Souza na tabela usuarios
    try:
        cursor.execute(
            "INSERT INTO usuarios (nome, email, senha, tipo, data_cadastro) VALUES (%s, %s, %s, %s, %s) RETURNING usuario_id;",
            ("Alice Souza", "alice.souza@example.com", fake.sha256(), "aluno", datetime.now().date())
        )
        alice_id = cursor.fetchone()[0]
        logging.info(f"Usuária Alice Souza (ID: {alice_id}) inserida em 'usuarios'.")
    except psycopg2.errors.UniqueViolation:
        logging.warning("Email 'alice.souza@example.com' já existe. Tentando buscar o ID de Alice.")
        try:
            cursor.execute("SELECT usuario_id FROM usuarios WHERE email = %s;", ("alice.souza@example.com",))
            alice_id = cursor.fetchone()[0]
            logging.info(f"Usuária Alice Souza já existe (ID: {alice_id}).")
        except Exception as e:
            logging.error(f"Erro ao buscar ID de Alice Souza existente: {e}")
            return None
    except Exception as e:
        logging.error(f"Erro ao inserir Alice Souza em 'usuarios': {e}")
        return None

    if not alice_id:
        return None

    # 2. Inserir Alice na tabela alunos
    try:
        cursor.execute(
            "INSERT INTO alunos (aluno_id, data_nascimento, telefone) VALUES (%s, %s, %s);",
            (alice_id, fake.date_of_birth(minimum_age=20, maximum_age=40), fake.phone_number())
        )
        logging.info(f"Alice Souza (ID: {alice_id}) inserida em 'alunos'.")
    except psycopg2.errors.UniqueViolation:
        logging.warning(f"Alice Souza (ID: {alice_id}) já existe em 'alunos'.")
    except Exception as e:
        logging.error(f"Erro ao inserir Alice Souza em 'alunos': {e}")
        return None

    # 3. Inscrever Alice em alguns cursos
    if not curso_ids:
        logging.warning("Não há cursos disponíveis para inscrever Alice.")
        return alice_id

    num_cursos_alice = min(NUM_CURSOS_ALICE_SE_INSCREVE, len(curso_ids))
    cursos_para_alice = random.sample(curso_ids, num_cursos_alice)
    
    alice_enrolled_courses = []
    for curso_id in cursos_para_alice:
        try:
            cursor.execute(
                "INSERT INTO inscricoes (aluno_id, curso_id, status, data_inscricao) VALUES (%s, %s, %s, %s);",
                (alice_id, curso_id, 'em andamento', datetime.now().date())
            )
            alice_enrolled_courses.append(curso_id)
            logging.info(f"Alice (ID: {alice_id}) inscrita no curso {curso_id}.")
        except psycopg2.errors.UniqueViolation:
            logging.warning(f"Alice (ID: {alice_id}) já está inscrita no curso {curso_id}. Ignorando.")
            alice_enrolled_courses.append(curso_id) # Considera como inscrita para o progresso
        except Exception as e:
            logging.error(f"Erro ao inscrever Alice no curso {curso_id}: {e}")
            
    if not alice_enrolled_courses:
        logging.warning("Alice não foi inscrita em nenhum curso. Não será possível adicionar progresso.")
        return alice_id

    # 4. Adicionar progresso para Alice nos cursos inscritos
    for curso_id in alice_enrolled_courses:
        # Buscar todas as aulas para este curso
        aulas_do_curso = [aula_id for aula_id, c_id in aula_to_curso_map.items() if c_id == curso_id]
        
        if not aulas_do_curso:
            logging.warning(f"Nenhuma aula encontrada para o curso {curso_id} de Alice. Pulando progresso para este curso.")
            continue

        # Alice assiste 100% das aulas nos cursos que ela se inscreve
        aulas_assistidas_alice = aulas_do_curso

        for aula_id in aulas_assistidas_alice:
            try:
                cursor.execute(
                    "INSERT INTO progresso (aula_id, aluno_id, assistido, data_visualizacao) VALUES (%s, %s, %s, %s);",
                    (aula_id, alice_id, True, fake.date_time_between(start_date='-3m', end_date='now'))
                )
                logging.info(f"Progresso adicionado para Alice (Aula {aula_id}, Curso {curso_id}).")
            except psycopg2.errors.UniqueViolation:
                logging.debug(f"Progresso duplicado para Alice (Aula {aula_id}). Ignorando.")
            except Exception as e:
                logging.error(f"Erro ao adicionar progresso para Alice (Aula {aula_id}): {e}")
    
    logging.info("População de Alice Souza e seu progresso concluída.")
    return alice_id


def main():
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()

            # Chamar truncate_tables no início para garantir um ambiente limpo
            truncate_tables(cursor, conn)

            # 1. Popula usuarios
            usuarios_ids = populate_usuarios(cursor, num_users=NUM_USUARIOS)
            conn.commit()
            aluno_ids = usuarios_ids['aluno']
            professor_ids = usuarios_ids['professor']
            administrador_ids = usuarios_ids['administrador']

            # 2. Popula alunos, professores, administradores
            populate_alunos(cursor, aluno_ids)
            populate_professores(cursor, professor_ids)
            populate_administradores(cursor, administrador_ids)
            conn.commit()

            # 3. Popula categorias
            categoria_ids = populate_categorias(cursor, num_categorias=NUM_CATEGORIAS)
            conn.commit()

            # 4. Popula cursos
            curso_ids = populate_cursos(cursor, categoria_ids, professor_ids, num_cursos=NUM_CURSOS)
            conn.commit()

            # 5. Popula modulos
            modulo_ids = populate_modulos(cursor, curso_ids, num_modulos_per_curso=NUM_MODULOS_POR_CURSO)
            conn.commit()

            # 6. Popula aulas (agora retorna aula_to_curso_map)
            aula_ids, aula_to_curso_map = populate_aulas(cursor, modulo_ids, num_aulas_per_modulo=NUM_AULAS_POR_MODULO)
            conn.commit()

            # 7. Popula inscricoes
            num_total_inscricoes = len(aluno_ids) * NUM_INSCRICOES_POR_ALUNO
            populate_inscricoes(cursor, aluno_ids, curso_ids, num_inscricoes_total=num_total_inscricoes)
            conn.commit()
            
            # 8. Adiciona Alice Souza e seu progresso (ANTES dos certificados e avaliações gerais)
            # Isso garante que ela possa ser considerada para certificados/avaliações se o sistema for inteligente
            alice_id = add_specific_user_and_progress(cursor, curso_ids, aula_to_curso_map)
            if alice_id:
                # Adiciona o ID de Alice à lista de alunos para que ela possa ser considerada em outras populações
                aluno_ids.append(alice_id)
                # Adiciona o ID de Alice à lista de usuários gerais para mensagens, etc.
                usuarios_ids['aluno'].append(alice_id) 
            conn.commit()

            # 9. Popula progresso (agora passa aula_to_curso_map)
            # Nao eh mais 'num_total_progresso' pois a logica eh mais granular.
            populate_progresso(cursor, aluno_ids, aula_to_curso_map)
            conn.commit()
            
            # 10. Popula avaliacoes (ANTES DOS CERTIFICADOS)
            num_total_avaliacoes = num_total_inscricoes * NUM_AVALIACOES_POR_INSCRICAO
            populate_avaliacoes(cursor, num_avaliacoes_total=num_total_avaliacoes)
            conn.commit()

            # 11. Popula certificados (agora tenta buscar inscrições com progresso e nota)
            populate_certificados(cursor, num_certificados_alvo=NUM_CERTIFICADOS_ALVO)
            conn.commit()

            # 12. Popula foruns
            num_total_foruns = len(curso_ids) * NUM_FORUNS_POR_CURSO
            forum_ids = populate_foruns(cursor, curso_ids, num_total_foruns)
            conn.commit()

            # 13. Popula postagens
            num_total_postagens = len(forum_ids) * NUM_POSTAGENS_POR_FORUM
            postagem_ids = populate_postagens(cursor, forum_ids, usuarios_ids, num_total_postagens)
            conn.commit()

            # 14. Popula comentarios
            num_total_comentarios = len(postagem_ids) * NUM_COMENTARIOS_POR_POSTAGEM
            populate_comentarios(cursor, postagem_ids, usuarios_ids, num_total_comentarios)
            conn.commit()

            # 15. Popula monitores (agora tenta buscar certificados existentes)
            populate_monitores(cursor, num_monitores_total=NUM_MONITORES)
            conn.commit()

            # 16. Popula mensagens GERAIS
            num_total_mensagens = len(aluno_ids) * NUM_MENSAGENS_POR_USUARIO
            populate_mensagens(cursor, usuarios_ids, num_total_mensagens)
            conn.commit()

            # 17. Popula mensagens ESPECÍFICAS entre usuários 5 e 6
            # É importante garantir que os usuários 5 e 6 existam.
            # No seu script, os IDs são gerados sequencialmente, então os primeiros usuários terão IDs baixos.
            # Se você deseja garantir que 5 e 6 são alunos, professores ou admins,
            # pode ajustar a lógica de populate_usuarios ou a escolha dos IDs aqui.
            # O ideal é usar IDs conhecidos, não fixos 5 e 6, mas vamos manter por enquanto.
            if len(usuarios_ids['aluno'] + usuarios_ids['professor'] + usuarios_ids['administrador']) >= 6:
                 # Tentativa de pegar os IDs 5 e 6 se existirem
                 user_id_5 = None
                 user_id_6 = None
                 all_available_users = sorted(usuarios_ids['aluno'] + usuarios_ids['professor'] + usuarios_ids['administrador'])
                 if len(all_available_users) >= 6:
                     user_id_5 = all_available_users[4] # ID na 5a posição (índice 4)
                     user_id_6 = all_available_users[5] # ID na 6a posição (índice 5)
                 
                 # Fallback: Se não encontrou os IDs 5 e 6 exatos ou se faltam usuários,
                 # pegue dois usuários aleatórios válidos para a conversa
                 if user_id_5 is None or user_id_6 is None:
                    logging.warning("IDs 5 e 6 não encontrados ou insuficientes para mensagens específicas. Selecionando usuários aleatórios para a conversa.")
                    if len(all_available_users) >= 2:
                        user_id_5, user_id_6 = random.sample(all_available_users, 2)
                    else:
                        logging.warning("Não há usuários suficientes para popular mensagens específicas. Pulando.")
                        user_id_5 = None # Define como None para não tentar popular
                        
                 if user_id_5 is not None:
                     populate_mensagens_especificas_conversa(cursor, user_id_5, user_id_6, num_mensagens=NUM_MENSAGENS_ESPECIFICAS_CONVERSA)
                     conn.commit()
                 
            else:
                 logging.warning("Não há usuários suficientes (mínimo 6) para popular mensagens específicas entre IDs 5 e 6. Pulando.")


            logging.info("Dados inseridos com sucesso em todas as tabelas!")

        except Exception as e:
            conn.rollback()
            logging.critical(f"Ocorreu um erro FATAL durante a população do banco de dados. Transação desfeita: {e}")
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
            if conn:
                conn.close()
            logging.info("Conexão com o banco de dados fechada.")
    else:
        logging.critical("Não foi possível estabelecer conexão com o banco de dados. Encerrando script.")

if __name__ == "__main__":
    main()