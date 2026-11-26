set search_path to avaliacao_cursos, public;
select i.inscricao_id,
       a.nome   as aluno,
       c.titulo as curso,
       i.data_inscricao,
       i.valor
from inscricao i
join aluno a on a.aluno_id = i.aluno_id
join curso c on c.curso_id = i.curso_id
where i.status = 'PENDENTE'
  and i.data_inscricao between date '2026-11-01' and date '2026-12-01'
order by i.data_inscricao desc, i.inscricao_id asc;
