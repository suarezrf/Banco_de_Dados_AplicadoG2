drop index if exists idx_inscricao_data_status;

explain (analyze, buffers)
select inscricao_id, data_inscricao, valor
from inscricao
where status = 'PAGA'
  and data_inscricao = date '2025-06-15';

create index idx_inscricao_data_status
    on inscricao using btree (data_inscricao, status);

explain (analyze, buffers)
select inscricao_id, data_inscricao, valor
from inscricao
where status = 'PAGA'
  and data_inscricao = date '2025-06-15';

-- antes do indice foi seq scan, leu a tabela toda e descartou quase tudo no filtro.
-- depois passou a usar bitmap index scan no indice, leu bem menos blocos e o tempo caiu bastante.
-- coloquei data_inscricao na frente porque é bem mais seletiva que status (status so tem 3 valores
-- e paga é a maioria), e assim o indice tambem serve pra consulta so por data.


