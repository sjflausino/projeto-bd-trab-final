-- ==========================================================
-- CONSULTA 1: Listar todos os alunos com seus dados de contato
-- ==========================================================
-- SELECT u.usuario_id, u.nome, u.email, a.data_nascimento, a.telefone
-- FROM usuarios u
-- JOIN alunos a ON u.usuario_id = a.aluno_id;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_usuarios_usuario_id ON usuarios (usuario_id);
-- -> Melhora o JOIN da tabela 'usuarios' com 'alunos' usando 'usuario_id'.

CREATE INDEX IF NOT EXISTS idx_alunos_aluno_id ON alunos (aluno_id);
-- -> Melhora o JOIN da tabela 'alunos' com 'usuarios' usando 'aluno_id'.

-- ==========================================================
-- CONSULTA 2: Listar os cursos com o nome do professor
-- ==========================================================
-- SELECT c.curso_id, c.titulo, c.descricao, u.nome AS professor
-- FROM cursos c
-- JOIN professores p ON c.professor_id = p.professor_id
-- JOIN usuarios u ON p.professor_id = u.usuario_id;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_cursos_professor_id ON cursos (professor_id);
-- -> Otimiza o JOIN entre 'cursos' e 'professores'.

CREATE INDEX IF NOT EXISTS idx_professores_professor_id ON professores (professor_id);
-- -> Otimiza o JOIN entre 'professores' e 'usuarios'.

-- ==========================================================
-- CONSULTA 3: Ver o progresso de um aluno específico (Exemplo para 'Alice Souza')
-- ==========================================================
-- SELECT u.nome AS aluno, c.titulo AS curso, a.titulo AS aula, pr.assistido, pr.data_visualizacao
-- FROM progresso pr
-- JOIN aulas a ON pr.aula_id = a.aula_id
-- JOIN modulos m ON a.modulo_id = m.modulo_id
-- JOIN cursos c ON m.curso_id = c.curso_id
-- JOIN alunos al ON pr.aluno_id = al.aluno_id
-- JOIN usuarios u ON al.aluno_id = u.usuario_id
-- WHERE LOWER(u.nome) LIKE '%alice souza%';

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_usuarios_lower_nome ON usuarios (LOWER(nome));
-- -> Acelera a filtragem por nome de usuário (WHERE LOWER(u.nome) LIKE '%alice%').

CREATE INDEX IF NOT EXISTS idx_progresso_aula_id ON progresso (aula_id);
-- -> Otimiza o JOIN entre 'progresso' e 'aulas'.

CREATE INDEX IF NOT EXISTS idx_progresso_aluno_id ON progresso (aluno_id);
-- -> Otimiza o JOIN entre 'progresso' e 'alunos'.

CREATE INDEX IF NOT EXISTS idx_aulas_modulo_id ON aulas (modulo_id);
-- -> Otimiza o JOIN entre 'aulas' e 'modulos'.

CREATE INDEX IF NOT EXISTS idx_modulos_curso_id ON modulos (curso_id);
-- -> Otimiza o JOIN entre 'modulos' e 'cursos'.

-- ==========================================================
-- CONSULTA 4: Ver a média de avaliações por curso
-- ==========================================================
-- SELECT c.titulo, ROUND(AVG(av.nota), 2) AS media_nota, COUNT(av.avaliacao_id) AS total_avaliacoes
-- FROM cursos c
-- JOIN avaliacoes av ON c.curso_id = av.curso_id
-- GROUP BY c.titulo
-- ORDER BY media_nota DESC;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_avaliacoes_curso_id ON avaliacoes (curso_id);
-- -> Otimiza o JOIN entre 'cursos' e 'avaliacoes' e a agregação por 'curso_id'.

-- ==========================================================
-- CONSULTA 5: Alunos que concluíram cursos e receberam certificado
-- ==========================================================
-- SELECT u.nome AS aluno, c.titulo AS curso, cert.data_emissao, cert.codigo_validacao
-- FROM certificados cert
-- JOIN alunos a ON cert.aluno_id = a.aluno_id
-- JOIN usuarios u ON a.aluno_id = u.usuario_id
-- JOIN cursos c ON cert.curso_id = c.curso_id;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_certificados_aluno_id ON certificados (aluno_id);
-- -> Otimiza o JOIN entre 'certificados' e 'alunos'.

CREATE INDEX IF NOT EXISTS idx_certificados_curso_id ON certificados (curso_id);
-- -> Otimiza o JOIN entre 'certificados' e 'cursos'.

-- ==========================================================
-- CONSULTA 6: Ver quem são os monitores de cada curso
-- ==========================================================
-- SELECT u.nome AS monitor, c.titulo AS curso, m.data_inicio, m.data_fim
-- FROM monitores m
-- JOIN alunos a ON m.aluno_id = a.aluno_id
-- JOIN usuarios u ON a.aluno_id = u.usuario_id
-- JOIN cursos c ON m.curso_id = c.curso_id;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_monitores_aluno_id ON monitores (aluno_id);
-- -> Otimiza o JOIN entre 'monitores' e 'alunos'.

CREATE INDEX IF NOT EXISTS idx_monitores_curso_id ON monitores (curso_id);
-- -> Otimiza o JOIN entre 'monitores' e 'cursos'.

-- ==========================================================
-- CONSULTA 7: Conversas entre dois usuários (Exemplo: Eduardo (5) e Fernanda (6))
-- ==========================================================
-- SELECT m.mensagem_id, remetente.nome AS de, destinatario.nome AS para, m.conteudo, m.data_envio, m.lida
-- FROM mensagens m
-- JOIN usuarios remetente ON m.remetente_id = remetente.usuario_id
-- JOIN usuarios destinatario ON m.destinatario_id = destinatario.usuario_id
-- WHERE (m.remetente_id = 5 AND m.destinatario_id = 6)
--    OR (m.remetente_id = 6 AND m.destinatario_id = 5)
-- ORDER BY m.data_envio;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_mensagens_remetente_id ON mensagens (remetente_id);
-- -> Otimiza a condição WHERE e o JOIN com o remetente.

CREATE INDEX IF NOT EXISTS idx_mensagens_destinatario_id ON mensagens (destinatario_id);
-- -> Otimiza a condição WHERE e o JOIN com o destinatário.

-- Um índice composto pode ser muito eficaz aqui para a cláusula WHERE complexa:
CREATE INDEX IF NOT EXISTS idx_mensagens_rem_dest_data ON mensagens (remetente_id, destinatario_id, data_envio);
-- -> Otimiza a busca bidirecional entre dois usuários e a ordenação por data.

-- ==========================================================
-- CONSULTA 8: Cursos mais populares
-- ==========================================================
-- SELECT c.titulo, COUNT(i.aluno_id) AS total_matriculados
-- FROM cursos c
-- JOIN inscricoes i ON c.curso_id = i.curso_id
-- GROUP BY c.curso_id, c.titulo
-- ORDER BY total_matriculados DESC;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_inscricoes_curso_id ON inscricoes (curso_id);
-- -> Otimiza o JOIN com 'cursos' e a agregação por 'curso_id'.

-- ==========================================================
-- CONSULTA 9: Relatório de certificados emitidos por mês
-- ==========================================================
-- SELECT TO_CHAR(cert.data_emissao, 'YYYY-MM') AS mes_emissao,
--       COUNT(cert.certificado_id) AS total_emitidos
-- FROM certificados cert
-- GROUP BY TO_CHAR(cert.data_emissao, 'YYYY-MM')
-- ORDER BY mes_emissao DESC;

-- Índices recomendados:
CREATE INDEX IF NOT EXISTS idx_certificados_data_emissao ON certificados (data_emissao);
-- -> Acelera o agrupamento e ordenação por data de emissão.

-- ==========================================================
-- CONSULTA 10: Alunos com mais cursos concluídos
-- ==========================================================
-- SELECT u.nome, COUNT(cert.certificado_id) AS cursos_concluidos
-- FROM certificados cert
-- JOIN alunos a ON cert.aluno_id = a.aluno_id
-- JOIN usuarios u ON a.aluno_id = u.usuario_id
-- GROUP BY u.usuario_id, u.nome
-- ORDER BY cursos_concluidos DESC
-- LIMIT 10;

-- Índices recomendados:
-- Já cobertos por idx_certificados_aluno_id (da Consulta 5) e índices existentes em 'alunos' e 'usuarios'.

-- ==========================================================
-- ÍNDICES ADICIONAIS PARA AS FUNÇÕES SQL E VIEWS
-- ==========================================================

-- Para a função 'check_nota(a_id integer, c_id integer)'
-- SELECT n := nota FROM avaliacoes WHERE aluno_id = a_id AND curso_id = c_id;
CREATE INDEX IF NOT EXISTS idx_avaliacoes_aluno_curso ON avaliacoes (aluno_id, curso_id);
-- -> Otimiza a busca direta por nota em 'avaliacoes' usando 'aluno_id' e 'curso_id'.

-- Para a função 'calcular_porcentagem_assistido(p_aluno_id INT, p_curso_id INT)'
-- SELECT COUNT(*) INTO aulas_assistidas FROM progresso p JOIN aulas a ... WHERE p.aluno_id = p_aluno_id AND m.curso_id = p_curso_id AND p.assistido IS TRUE;
CREATE INDEX IF NOT EXISTS idx_progresso_aluno_assistido_aula ON progresso (aluno_id, assistido, aula_id);
-- -> Otimiza a contagem de aulas assistidas pelo aluno, filtrando por 'aluno_id', 'assistido' e 'aula_id'.

-- Para a função 'media_de_nota_curso(cursoid integer)'
-- SELECT ROUND(AVG(avaliacoes.nota),2) FROM avaliacoes INTO n WHERE curso_id = cursoid;
-- O índice 'idx_avaliacoes_curso_id' (já criado acima) é ideal para esta função.

-- Para a função 'func_inscrever_aluno(p_aluno_id INT, p_curso_id INT)'
-- SELECT TRUE INTO ja_inscrito FROM inscricoes WHERE aluno_id = p_aluno_id AND curso_id = p_curso_id;
-- A Primary Key (inscricao_id, aluno_id, curso_id) ou um índice composto em (aluno_id, curso_id) já otimiza esta verificação.
-- Se a PK não for composta por essas colunas, o índice abaixo seria útil:
CREATE INDEX IF NOT EXISTS idx_inscricoes_aluno_curso ON inscricoes (aluno_id, curso_id);
-- -> Otimiza a verificação rápida se um aluno já está inscrito em um curso.

-- Para a função 'func_mensagens_nao_lidas(p_usuario_id INT)'
-- SELECT COUNT(*) INTO total FROM mensagens WHERE destinatario_id = p_usuario_id AND lida = FALSE;
CREATE INDEX IF NOT EXISTS idx_mensagens_destinatario_lida ON mensagens (destinatario_id, lida);
-- -> Otimiza a contagem de mensagens não lidas para um destinatário específico.

-- ======================= OBS. ==============================
-- Para as Views (vw_certificados_concluidos, vw_media_cursos)
-- As views se beneficiarão dos índices criados nas tabelas subjacentes ('certificados', 'inscricoes', 'usuarios', 'cursos', 'avaliacoes')
-- e dos índices específicos para as funções que elas chamam.

-- ==========================================================
-- RELACIONAMENTO: CONSULTAS/FUNÇÕES x ÍNDICES
-- ==========================================================
/*
| Consulta/Função Beneficiada                                      | Nome do Índice                       |
|------------------------------------------------------------------|--------------------------------------|
| CONSULTA 1: Listar alunos                                        | idx_usuarios_usuario_id              |
| CONSULTA 1: Listar alunos                                        | idx_alunos_aluno_id                  |
| CONSULTA 2: Listar cursos com o nome do professor                | idx_cursos_professor_id              |
| CONSULTA 2: Listar cursos com o nome do professor                | idx_professores_professor_id         |
| CONSULTA 3: Ver o progresso de um aluno específico               | idx_usuarios_lower_nome              |
| CONSULTA 3: Ver o progresso de um aluno específico               | idx_progresso_aula_id                |
| CONSULTA 3: Ver o progresso de um aluno específico               | idx_progresso_aluno_id               |
| CONSULTA 3: Ver o progresso de um aluno específico               | idx_aulas_modulo_id                  |
| CONSULTA 3: Ver o progresso de um aluno específico               | idx_modulos_curso_id                 |
| CONSULTA 4: Ver a média de avaliações por curso                  | idx_avaliacoes_curso_id              |
| CONSULTA 5: Alunos que concluíram cursos e receberam certificado | idx_certificados_aluno_id            |
| CONSULTA 5: Alunos que concluíram cursos e receberam certificado | idx_certificados_curso_id            |
| CONSULTA 6: Ver quem são os monitores de cada curso              | idx_monitores_aluno_id               |
| CONSULTA 6: Ver quem são os monitores de cada curso              | idx_monitores_curso_id               |
| CONSULTA 7: Conversas entre dois usuários                        | idx_mensagens_remetente_id           |
| CONSULTA 7: Conversas entre dois usuários                        | idx_mensagens_destinatario_id        |
| CONSULTA 7: Conversas entre dois usuários                        | idx_mensagens_rem_dest_data          |
| CONSULTA 8: Cursos mais populares                                | idx_inscricoes_curso_id              |
| CONSULTA 9: Relatório de certificados emitidos por mês           | idx_certificados_data_emissao        |
| CONSULTA 10: Alunos com mais cursos concluídos                   | idx_certificados_aluno_id            |
| Função 'check_nota'                                              | idx_avaliacoes_aluno_curso           |
| Função 'calcular_porcentagem_assistido'                          | idx_progresso_aluno_assistido_aula   |
| Função 'func_inscrever_aluno'                                    | idx_inscricoes_aluno_curso           |
| Função 'func_media_de_nota_curso'                                | idx_avaliacoes_curso_id              |
| Função 'func_mensagens_nao_lidas'                                | idx_mensagens_destinatario_lida      |
*/
