select a.aluno_id,
       a.nome
from aluno a
where not exists (
        select 1
        from inscricao i
        where i.aluno_id = a.aluno_id
      )
order by a.aluno_id;
