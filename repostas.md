Parte B — Questões conceituais

questão b1

A
no read committed o select nao trava a linha, entao as duas sessoes leem 1 vaga antes de qualquer uma gravar,
as duas inserem a inscriçao e gravam vagas = 0. a segunda so sobrescreve a primeira e fica duas incrições pra
uma vaga. pra evitar a verificaçao e a baixa tem que ser na mesma operaçao com bloqueio da linah, tipo assim

sql
update curso
set vagas_disponiveis = vagas_disponiveis - 1
where curso_id = 5 and vagas_disponiveis > 0;

o update trava a linha e a segunda sessao espera. depois do commit da primeira a condiçao é testada de novo
com 0 e nao altera nada, entao nao tem vaga. outra forma seria um select ... for update antes de verificar.
a segunda tem que verificar depois de pegar o bloqueio, na mesma trasaçao que grava a inscriçao

B
o evento seria update of status na inscricao pq so ai o status muda, e assim nao dispara se mudar outra coluna
tipo o valor. o momento seria after e for each row, after pq a alteraçao ja foi feita e se der rollback o
historico some junto, e for each row pq cada inscriçao precisa do seu regsitro. o old e new servem pra so 
gravar se old.status for diferente de new.status, e pra preencher o historico com old.status em status_anterior 
e new.status em novo_status. o motivo nao ta no old nem no new entao vem da aplicaçao ou usa um padroa. ficaria mais ou menos assim

sql
create function fn_registrar_mudanca_status() returns trigger
language plpgsql as $$
begin
    insert into historico_status (inscricao_id, status_anterior, novo_status, motivo)
    values (new.inscricao_id, old.status, new.status,
            coalesce(nullif(current_setting('app.motivo_status', true), ''), 'Não informado'));
    return null;
end;
$$;
 
create trigger trg_inscricao_historico_status
after update of status on inscricao
for each row
when (old.status is distinct from new.status)
execute function fn_registrar_mudanca_status();

questão b2

A
eu faria uma coleçao separada, um documento por evento com referencia pra sessao. num array
o documento ia crescer sem limtie e passar dos 16 mb do mongo, e cada evento novo ia reescrever
um documento cada vez maior. com um indice em sessaoId e ocorridoEm decrescente a consulta dos 50 mais recentes pega direto ja ordenado sem ler tudo

js
db.eventos.createIndex({ sessaoId: 1, ocorridoEm: -1 })
db.eventos.find({ sessaoId: ObjectId("6745f1c2a1b2c3d4e5f60718") }).sort({ ocorridoEm: -1 }).limit(50)

B
um exemplo de documetno

js
{
  _id: ObjectId("6745f1d9a1b2c3d4e5f60a21"),
  eventoId: "b7e4c1f0-3d2a-4f8e-9c11-5a6b7c8d9e01",
  sessaoId: ObjectId("6745f1c2a1b2c3d4e5f60718"),
  tipo: "INSCRICAO_INICIADA",
  ocorridoEm: ISODate("2026-11-26T17:42:10.512Z"),
  origem: "instagram"
}

a associaçao é pelo sessaoId que guarda o _id da sessao, é por ele que a consulta filtra

questão b3

a agregaçao ficaria assim

js
db.eventos.aggregate([
  { $match: {
      tipo: "INSCRICAO_INICIADA",
      ocorridoEm: { $gte: ISODate("2026-11-26T03:00:00Z"),
                    $lt:  ISODate("2026-11-27T03:00:00Z") }
  } },
  { $group: { _id: "$origem", total: { $sum: 1 } } },
  { $sort: { total: -1 } }
])

o $match recebe todos os eventos e deixa so os inscricao_iniciada do dia (usei 26/11 no horario de
brasilia, por isso 03:00 utc), vem primeiro pra diminuir os dados e poder usar indice. o $group
recebe so os filtrados, agrupa por origem e soma 1 pra cada, saindo um documento por origem com
o total. o $sort recebe esses totais e ordena do maior pro meno

questão b4

A
a receita diaria vem do postgres (inscriçoes paga, valor e data_pagamento), em batch 1 vez por dia pq o painel
é diario e rodando de madrugada nao pesa no banco. tem que filtrar pela data_pagamento e nao pela data_inscricao. 
os inicios de inscriçao vem do fluxo de mensagens em streaming pq o atraso maximo é 5 min e batch diario nao atende

B
na bronze ficam as inscriçoes extraidas do postgres do jeito que vieram e as mensagens dos eventos do jeito que 
chegaram, inclusive duplicadas, pra poder reprocessar. na silver as inscriçoes ficam com tipos e datas validados 
e junto com o curso, e os eventos ficam com a origem padronizada e sem duplicados. na gold fica a receita por dia 
e curso so com as pagas, e o total de inicios por origem em janelas de 5 min. os duplicados saem da bronze pra silver 
usando o eventoId, o streaming descarta eventoId repetido e a gravaçao na silver usa ele como chave, entao o evento repetido nao conta duas vezs

C
um orquestrador tipo airflow roda o processo diario em etapas com dependencia, extrai pra bronze, transforma pra silver, 
gera a gold e confere se a receita bate com o postgres. so passa pra proxima se a anterior deu certo entao o painel nao le 
dado pela metade. tambem tenta de novo quando falha, guarda log e historico de cada execuçao, avisa quando da erro ou atrasa 
e deixa reprocessar um dia especifico sem duplicar. os paineis leem da gold, nao da bronze que tem duplicado nem direto 
dos bancos operacionias pra nao sobrecarregar

Parte C — Questões de múltipla escolha

c1 b
c2 d
c3 a
c4 c
c5 a
c6 d
c7 b
c8 c
c9 d
c10 b
c11 a
c12 c
c13 b
c14 c
c15 a
c16 d
c17 a
c18 d
c19 c
c20 b
