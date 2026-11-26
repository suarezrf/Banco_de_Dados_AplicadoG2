select c.curso_id,
       c.titulo,
       count(i.inscricao_id)        as qtd_inscricoes_pagas,
       coalesce(sum(i.valor), 0.00) as receita
from curso c
left join inscricao i on i.curso_id = c.curso_id
where i.status = 'PAGA'
  and i.data_pagamento >= date '2026-11-01'
  and i.data_pagamento <  date '2026-12-01'
group by c.curso_id, c.titulo
order by receita desc, c.curso_id;
