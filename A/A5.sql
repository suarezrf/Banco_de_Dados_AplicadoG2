select inscricao_id, status, data_pagamento
from inscricao
where inscricao_id = 1009;
select count(*) as qtd_historico
from historico_status
where inscricao_id = 1009;

begin;

with cancelada as (
    update inscricao
    set status = 'CANCELADA'
    where inscricao_id = 1009
      and status = 'PENDENTE'
    returning inscricao_id
)
insert into historico_status (inscricao_id, status_anterior, novo_status, motivo)
select inscricao_id, 'PENDENTE', 'CANCELADA', 'Solicitação do aluno'
from cancelada;
select inscricao_id, status, data_pagamento
from inscricao
where inscricao_id = 1009;
select count(*) as qtd_historico
from historico_status
where inscricao_id = 1009;

rollback;

select inscricao_id, status, data_pagamento
from inscricao
where inscricao_id = 1009;

select count(*) as qtd_historico
from historico_status
where inscricao_id = 1009;
