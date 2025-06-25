CREATE OR REPLACE VIEW vw_certificados_concluidos AS
SELECT 
    c.aluno_id,
    u.nome AS aluno_nome,
    c.curso_id,
    cu.titulo AS curso_titulo,
    i.status AS status_inscricao,
    c.data_emissao,
    c.codigo_validacao,
    calcular_porcentagem_assistido(c.aluno_id, c.curso_id) AS porcentagem_assistida
FROM 
    certificados c
JOIN 
    inscricoes i ON c.aluno_id = i.aluno_id AND c.curso_id = i.curso_id
JOIN 
    usuarios u ON u.usuario_id = c.aluno_id
JOIN 
    cursos cu ON cu.curso_id = c.curso_id
WHERE 
    i.status = 'concluido';

CREATE OR REPLACE VIEW vw_media_cursos AS
SELECT 
    titulo AS curso, 
    media_de_nota_curso(curso_id) AS media 
FROM 
    cursos;

CREATE OR REPLACE VIEW vw_mensagens_nao_lidas_usuario AS
SELECT usuario_id,nome,func_mensagens_nao_lidas(usuario_id) AS total_nao_lidas
from usuarios;

