select i.inscricao_id,
       c.titulo as curso,
       i.valor
from inscricao i
join curso c on c.curso_id = i.curso_id
where i.status = 'PAGA'
  and i.data_pagamento >= date '2026-11-01'
  and i.data_pagamento <  date '2026-12-01'
  and i.valor > (
        select avg(i2.valor)
        from inscricao i2
        where i2.status = 'PAGA'
          and i2.data_pagamento >= date '2026-11-01'
          and i2.data_pagamento <  date '2026-12-01'
      )
order by i.inscricao_id;

