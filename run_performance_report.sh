#!/bin/bash

# ===========================
# CONFIGURAÇÕES DO BANCO
# ===========================
DB_NAME="postgres"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
export PGPASSWORD="postgres"

QUERY_FILES=( query1.sql query2.sql query3.sql query4.sql query5.sql query6.sql query7.sql query8.sql query9.sql query10.sql )
LOG_FILE="relatorio_desempenho_consultas.txt"
declare -A TIMES_WITHOUT_INDEX
declare -A TIMES_WITH_INDEX

# ===========================
# EXECUÇÃO COM EXPLAIN
# ===========================
execute_sql_with_explain() {
    local sql_file=$1
    local result
    result=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -q -A -t -f <(echo "EXPLAIN (ANALYZE, BUFFERS, VERBOSE) $(cat "$sql_file")") 2>&1)
    echo "$result"
}

# ===========================
# EXECUTA 3X E CALCULA MÉDIA/STDDEV
# ===========================
executar_consulta_n_vezes() {
    local sql_file=$1
    local n=10
    local tempos=()

    for i in $(seq 1 $n); do
        EXPLAIN_OUTPUT=$(execute_sql_with_explain "${sql_file}")
        TEMPO=$(echo "${EXPLAIN_OUTPUT}" | grep "Execution Time:" | awk '{print $3}')
        tempos+=("${TEMPO}")
    done

    echo "${tempos[@]}" | awk '
    {
        n=NF;
        for(i=1;i<=n;i++) {
            sum+=$i;
            sumsq+=$i*$i;
        }
        mean=sum/n;
        stddev=sqrt((sumsq - sum*sum/n)/n);
        printf "%.3f %.3f\n", mean, stddev;
    }'
}

# ===========================
# CRIA CONSULTAS E ÍNDICES
# ===========================
create_sql_files() {
    echo "Criando arquivos SQL..."
    cat <<EOF > query1.sql
SELECT u.usuario_id, u.nome, u.email, a.data_nascimento, a.telefone FROM usuarios u JOIN alunos a ON u.usuario_id = a.aluno_id;
EOF
    cat <<EOF > query2.sql
SELECT c.curso_id, c.titulo, c.descricao, u.nome AS professor FROM cursos c JOIN professores p ON c.professor_id = p.professor_id JOIN usuarios u ON p.professor_id = u.usuario_id;
EOF
    cat <<EOF > query3.sql
SELECT u.nome AS aluno, c.titulo AS curso, a.titulo AS aula, pr.assistido, pr.data_visualizacao FROM progresso pr JOIN aulas a ON pr.aula_id = a.aula_id JOIN modulos m ON a.modulo_id = m.modulo_id JOIN cursos c ON m.curso_id = c.curso_id JOIN alunos al ON pr.aluno_id = al.aluno_id JOIN usuarios u ON al.aluno_id = u.usuario_id WHERE LOWER(u.nome) LIKE '%alice%';
EOF
    cat <<EOF > query4.sql
SELECT c.titulo, ROUND(AVG(av.nota), 2) AS media_nota, COUNT(av.avaliacao_id) AS total_avaliacoes FROM cursos c JOIN avaliacoes av ON c.curso_id = av.curso_id GROUP BY c.titulo ORDER BY media_nota DESC;
EOF
    cat <<EOF > query5.sql
SELECT u.nome AS aluno, c.titulo AS curso, cert.data_emissao, cert.codigo_validacao FROM certificados cert JOIN alunos a ON cert.aluno_id = a.aluno_id JOIN usuarios u ON a.aluno_id = u.usuario_id JOIN cursos c ON cert.curso_id = c.curso_id;
EOF
    cat <<EOF > query6.sql
SELECT u.nome AS monitor, c.titulo AS curso, m.data_inicio, m.data_fim FROM monitores m JOIN alunos a ON m.aluno_id = a.aluno_id JOIN usuarios u ON a.aluno_id = u.usuario_id JOIN cursos c ON m.curso_id = c.curso_id;
EOF
    cat <<EOF > query7.sql
SELECT m.mensagem_id, remetente.nome AS de, destinatario.nome AS para, m.conteudo, m.data_envio, m.lida FROM mensagens m JOIN usuarios remetente ON m.remetente_id = remetente.usuario_id JOIN usuarios destinatario ON m.destinatario_id = destinatario.usuario_id WHERE (m.remetente_id = 5 AND m.destinatario_id = 6) OR (m.remetente_id = 6 AND m.destinatario_id = 5) ORDER BY m.data_envio;
EOF
    cat <<EOF > query8.sql
SELECT c.titulo, COUNT(i.aluno_id) AS total_matriculados FROM cursos c JOIN inscricoes i ON c.curso_id = i.curso_id GROUP BY c.curso_id, c.titulo ORDER BY total_matriculados DESC;
EOF
    cat <<EOF > query9.sql
SELECT TO_CHAR(cert.data_emissao, 'YYYY-MM') AS mes_emissao, COUNT(cert.certificado_id) AS total_emitidos FROM certificados cert GROUP BY TO_CHAR(cert.data_emissao, 'YYYY-MM') ORDER BY mes_emissao DESC;
EOF
    cat <<EOF > query10.sql
SELECT u.nome, COUNT(cert.certificado_id) AS cursos_concluidos FROM certificados cert JOIN alunos a ON cert.aluno_id = a.aluno_id JOIN usuarios u ON a.aluno_id = u.usuario_id GROUP BY u.usuario_id, u.nome ORDER BY cursos_concluidos DESC LIMIT 10;
EOF
    cat <<EOF > create_indexes.sql
CREATE INDEX IF NOT EXISTS idx_usuarios_usuario_id ON usuarios (usuario_id);
CREATE INDEX IF NOT EXISTS idx_alunos_aluno_id ON alunos (aluno_id);
CREATE INDEX IF NOT EXISTS idx_cursos_professor_id ON cursos (professor_id);
CREATE INDEX IF NOT EXISTS idx_professores_professor_id ON professores (professor_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_lower_nome ON usuarios (LOWER(nome));
CREATE INDEX IF NOT EXISTS idx_progresso_aula_id ON progresso (aula_id);
CREATE INDEX IF NOT EXISTS idx_progresso_aluno_id ON progresso (aluno_id);
CREATE INDEX IF NOT EXISTS idx_aulas_modulo_id ON aulas (modulo_id);
CREATE INDEX IF NOT EXISTS idx_modulos_curso_id ON modulos (curso_id);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_curso_id ON avaliacoes (curso_id);
CREATE INDEX IF NOT EXISTS idx_certificados_aluno_id ON certificados (aluno_id);
CREATE INDEX IF NOT EXISTS idx_certificados_curso_id ON certificados (curso_id);
CREATE INDEX IF NOT EXISTS idx_monitores_aluno_id ON monitores (aluno_id);
CREATE INDEX IF NOT EXISTS idx_monitores_curso_id ON monitores (curso_id);
CREATE INDEX IF NOT EXISTS idx_mensagens_remetente_id ON mensagens (remetente_id);
CREATE INDEX IF NOT EXISTS idx_mensagens_destinatario_id ON mensagens (destinatario_id);
CREATE INDEX IF NOT EXISTS idx_inscricoes_curso_id ON inscricoes (curso_id);
CREATE INDEX IF NOT EXISTS idx_certificados_data_emissao ON certificados (data_emissao);
EOF
    cat <<EOF > drop_indexes.sql
DROP INDEX IF EXISTS idx_usuarios_usuario_id;
DROP INDEX IF EXISTS idx_alunos_aluno_id;
DROP INDEX IF EXISTS idx_cursos_professor_id;
DROP INDEX IF EXISTS idx_professores_professor_id;
DROP INDEX IF EXISTS idx_usuarios_lower_nome;
DROP INDEX IF EXISTS idx_progresso_aula_id;
DROP INDEX IF EXISTS idx_progresso_aluno_id;
DROP INDEX IF EXISTS idx_aulas_modulo_id;
DROP INDEX IF EXISTS idx_modulos_curso_id;
DROP INDEX IF EXISTS idx_avaliacoes_curso_id;
DROP INDEX IF EXISTS idx_certificados_aluno_id;
DROP INDEX IF EXISTS idx_certificados_curso_id;
DROP INDEX IF EXISTS idx_monitores_aluno_id;
DROP INDEX IF EXISTS idx_monitores_curso_id;
DROP INDEX IF EXISTS idx_mensagens_remetente_id;
DROP INDEX IF EXISTS idx_mensagens_destinatario_id;
DROP INDEX IF EXISTS idx_inscricoes_curso_id;
DROP INDEX IF EXISTS idx_certificados_data_emissao;
EOF
}

cleanup_sql_files() {
    rm -f query*.sql create_indexes.sql drop_indexes.sql
}

# ===========================
# EXECUÇÃO PRINCIPAL
# ===========================
run_comparison() {
    echo "Iniciando relatório..." > "$LOG_FILE"
    cleanup_sql_files
    create_sql_files

    echo -e "\n=== SEM ÍNDICES ===" >> "$LOG_FILE"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -q -f drop_indexes.sql > /dev/null

    for q in "${QUERY_FILES[@]}"; do
        echo -e "\n--- $q (sem índices) ---" >> "$LOG_FILE"
        read MEDIA DP <<< $(executar_consulta_n_vezes "$q")
        echo "Tempo médio: $MEDIA ms | Desvio: $DP ms" >> "$LOG_FILE"
        TIMES_WITHOUT_INDEX["$q"]="${MEDIA} ± ${DP}"
    done

    echo -e "\n=== COM ÍNDICES ===" >> "$LOG_FILE"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -q -f create_indexes.sql > /dev/null

    for q in "${QUERY_FILES[@]}"; do
        echo -e "\n--- $q (com índices) ---" >> "$LOG_FILE"
        read MEDIA DP <<< $(executar_consulta_n_vezes "$q")
        echo "Tempo médio: $MEDIA ms | Desvio: $DP ms" >> "$LOG_FILE"
        TIMES_WITH_INDEX["$q"]="${MEDIA} ± ${DP}"
    done

    echo -e "\n\n--- RESUMO FINAL ---" >> "$LOG_FILE"
    printf "%-15s | %-20s | %-20s\n" "Consulta" "Sem Índices (ms)" "Com Índices (ms)" >> "$LOG_FILE"
    echo "---------------------------------------------------------------------" >> "$LOG_FILE"
    for q in "${QUERY_FILES[@]}"; do
        printf "%-15s | %-20s | %-20s\n" "$q" "${TIMES_WITHOUT_INDEX[$q]}" "${TIMES_WITH_INDEX[$q]}" >> "$LOG_FILE"
    done

    echo -e "\nRelatório salvo em '$LOG_FILE'"
    cleanup_sql_files
}

# === EXECUTA ===
run_comparison
