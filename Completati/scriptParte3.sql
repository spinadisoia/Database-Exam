--------------------------------------------------------------------------
--------------------- PARTE 3: PROGETTAZIONE FISICA ----------------------
--------------------------------------------------------------------------

SET search_path to 'ortiScolasticiLarge';
SET datestyle TO 'DMY';

ANALYZE;

------------------ SEZIONE 1: Carico di lavoro ---------------------------

-- Operazione 1 (SELEZIONE): 'Determinare tutte le scuole del comune di Genova'

SELECT * FROM scuola WHERE comune = 'Genova';


--- Total query runtime con SEQ_SCAN: 125 msec (timings exclusive=inclusive= 5.498 ms)
--- Plan Rows 6784 = Actual Rows

--- Piano Scelto dal sistema: SEQ_SCAN
--- Seq Scan on ortiScolasticiLarge.scuola as scuola (cost=0..447 rows=6784 width=48) (actual=0.172..7.283 rows=6784 loops=1)
--- Filter: ((scuola.comune)::text = 'Genova'::text)
--- Rows Removed by Filter = 13216


-- Operazione 2 (SELEZIONE CON CONDIZIONE COMPLESSA): 'Determinare le rilevazioni comprese
--                                                     tra il 20/09/2021 e il 21/12/2021
--                                                     dove è stata registrata una temperatura
--                                                     maggiore di 17°C e un tasso di umidità
--                                                     maggiore del 75% '


SELECT * 
FROM rilevazione
WHERE dataOraRil BETWEEN '20-09-2021' AND '21-12-2021' AND temperatura > 17 AND umidità > 75

--- Total query runtime: 117 msec (timings exclusive=0.426 ms e inclusive= 0.508 ms)

--- Piano scelto dal sistema: Bitmap Heap Scan + Bitmap Index Scan

--- Bitmap Heap Scan on ortiScolasticiLarge.rilevazione as rilevazione (cost=10.75..410.81 rows=27 width=134) (actual=0.151..0.411 rows=32 loops=1)
--- Filter: ((rilevazione.temperatura > '17'::numeric) AND (rilevazione."umidità" > '75'::numeric))
--- Rows Removed by Filter: 222
--- Recheck Cond: ((rilevazione.dataoraril >= '2021-09-20 00:00:00'::timestamp without time zone) AND (rilevazione.dataoraril <= '2021-12-21 00:00:00'::timestamp without time zone))
--- Heap Blocks: exact=64

--- Bitmap Index Scan using rilevazione_pkey (cost=0..10.75 rows=246 width=0) (actual=0.075..0.075 rows=254 loops=1)
--- Index Cond: ((rilevazione.dataoraril >= '2021-09-20 00:00:00'::timestamp without time zone) AND (rilevazione.dataoraril <= '2021-12-21 00:00:00'::timestamp without time zone))



-- Operazione 3 (JOIN): 'Determinare tutte le repliche possedute da scuole del comune di Novara
--						 messe a dimora in date successive al 01/01/2023'


SELECT siOccupaDi.scuola, dataMessaADimora, numeroRep, gruppo, siOccupaDi.specie
FROM replica 
	JOIN specie ON replica.specie = nomeScientifico 
	JOIN sioccupadi ON nomeScientifico = siOccupaDi.specie
	JOIN scuola ON siOccupaDi.scuola = codiceMeccanografico
WHERE dataMessaADimora > '01-01-2023' AND comune = 'Novara'



--- Total query runtime: 79 msec (timings exclusive=0.176 ms e inclusive= 7.618 ms)

--- Il piano scelto dal sistema è una sequenza di HASH INNER JOIN, SEQ_SCAN, HASH e NESTED LOOP JOIN

--- 1) Hash Inner Join (cost=692.63..1163.28 rows=2 width=40) (actual=5.79..7.618 rows=822 loops=1)
--     Hash Cond: ((replica.specie)::text = (specie.nomescientifico)::text)

--- 2) -> Seq Scan on ortiScolasticiLarge.replica as replica (cost=0..469.01 rows=432 width=21) (actual=0.03..1.835 rows=437 loops=1)
---       Filter: (replica.datamessaadimora > '2023-01-01'::date)
---       Rows Removed by Filter: 19564

--- 3) -> Hash (cost=691.74..691.74 rows=71 width=43) (actual=5.608..5.608 rows=65 loops=1)
---       Buckets: 1024 Batches: 1 Memory Usage: 13 kB

--- 4)    -> Nested Loop Inner Join (cost=449.06..691.74 rows=71 width=43) (actual=3.213..5.565 rows=65 loops=1)

--- 5)       -> Hash Inner Join (cost=448.77..661 rows=71 width=28) (actual=3.155..4.941 rows=65 loops=1)
---             Hash Cond: (sioccupadi.scuola = scuola.codicemeccanografico)

--- 6)          -> Seq Scan on ortiScolasticiLarge.sioccupadi as sioccupadi (cost=0..174.01 rows=10001 width=28) (actual=0.008..0.952 rows=10001 loops=1)	

--- 7)          -> Hash (cost=447..447 rows=142 width=11) (actual=2.994..2.994 rows=142 loops=1)
---                Buckets: 1024 Batches: 1 Memory Usage: 14 kB

--- 8)             -> Seq Scan on ortiScolasticiLarge.scuola as scuola (cost=0..447 rows=142 width=11) (actual=0.008..2.902 rows=142 loops=1)
---                   Filter: ((scuola.comune)::text = 'Novara'::text)
---                   Rows Removed by Filter: 19858

--- 9)       -> Index Only Scan using specie_pkey on ortiScolasticiLarge.specie as specie (cost=0.29..0.42 rows=1 width=15) (actual=0.009..0.009 rows=1 loops=65)
---             Index Cond: (specie.nomescientifico = (sioccupadi.specie)::text)



-------------- SEZIONE 2: Elaborazione delle interrogazioni --------------

ANALYZE;


SELECT C.relname AS tabella, C.relpages AS numeroBlocchi, C.reltuples AS numeroTuple
FROM pg_namespace N JOIN pg_class C ON N.oid = C.relnamespace
WHERE  N.nspname = 'ortiScolasticiLarge' AND relname IN ('classe','finanziamento', 'gruppo','orto','persona','replica','responsabile','rilevazione','scuola','sensore','sioccupadi','specie');


---- Controllo presenza di eventuali indici già creati dal sistema ----

SELECT C.oid, relname, relam, relpages, relkind, indexrelid, indrelid, indnatts, indisunique, indisprimary, indisclustered, indkey
FROM (pg_namespace N JOIN pg_class C ON N.oid = C.relnamespace) JOIN pg_index ON C.oid = indexrelid
WHERE N.nspname = 'ortiScolasticiLarge';



----------------------------------------------------------
--- PRIMA OPERAZIONE ---
----------------------------------------------------------

-- Per ottimizzare la prima operazione, poiché la selezione contiene un solo fattore booleano
-- si può realizzare un indice clusterizzato ordinato sull'attributo che coinvolge il fattore (comune)

CREATE INDEX idx_ord_comune_scuola
ON scuola(comune);

CLUSTER scuola
USING idx_ord_comune_scuola;

--- Dopo la creazione dell'indice i risultati sono i seguenti:

ANALYZE;

SELECT * FROM scuola WHERE comune = 'Genova';

-- Total query runtime: 66 msec  (timings exclusive=1.376 ms e inclusive= 1.376 ms)

-- Piano INDEX SCAN con cammino d'accesso (idx_ord_comune_scuola, comune = 'Genova')

-- Index Scan using idx_ord_comune_scuola on ortiScolasticiLarge.scuola as scuola (cost=0.29..277.01 rows=6784 width=48) (actual=0.015..1.376 rows=6784 loops=1)
-- Index Cond: ((scuola.comune)::text = 'Genova'::text)



----------------------------------------------------------
--- SECONDA OPERAZIONE ---
----------------------------------------------------------

--- In questo caso sono possibili diverse alternative per rendere più efficiente il piano fisico
--- Si può ragionare sul fattore di selettività più alto:

SELECT * FROM rilevazione WHERE temperatura > 17; -- 3500 TUPLE RESTITUITE

SELECT * FROM rilevazione WHERE umidità > 75; -- 12541 TUPLE RESTITUITE

SELECT * FROM rilevazione WHERE dataOraRil BETWEEN '20-09-2021' AND '21-12-2021' -- 254 TUPLE RESTITUITE


-- La condizione più selettiva è ovviamente quella sulle date, quindi conviene fare un indice
-- ordinato (per permettere ricerche range) clusterizzato sull'attributo dataOraRil

CREATE INDEX idx_ord_dataOraRil_rilevazione
ON rilevazione(dataOraRil);

CLUSTER rilevazione
USING idx_ord_dataOraRil_rilevazione;


ANALYZE;

SELECT * 
FROM rilevazione
WHERE dataOraRil BETWEEN '20-09-2021' AND '21-12-2021' AND temperatura > 17 AND umidità > 75

--- Total query runtime: 68 msec (timings exclusive=0.106 ms e inclusive= 0.106 ms)

--- Piano scelto dal sistema: INDEX SCAN con cammino d'accesso (idx_ord_dataOraRil_rilevazione, dataOraRil BETWEEN '20-09-2021' AND '21-12-2021')
---							  e filtri temperatura > 17 e umidità > 75

--- Index Scan using idx_ord_dataoraril_rilevazione on ortiScolasticiLarge.rilevazione as rilevazione (cost=0.29..19.44 rows=27 width=134) (actual=0.031..0.258 rows=32 loops=1)
--- Filter: ((rilevazione.temperatura > '17'::numeric) AND (rilevazione."umidità" > '75'::numeric))
--- Index Cond: ((rilevazione.dataoraril >= '2021-09-20 00:00:00'::timestamp without time zone) AND (rilevazione.dataoraril <= '2021-12-21 00:00:00'::timestamp without time zone))
--- Rows Removed by Filter: 222


----------------------------------------------------------
--- TERZA OPERAZIONE ---
----------------------------------------------------------

-- In questo caso si decide di rendere più efficiente la selezione dal momento che
-- per il JOIN il sistema utilizza l'operatore HASH_JOIN

CREATE INDEX idx_ord_dataMessaADimora_replica
ON replica(dataMessaADimora);

CLUSTER replica
USING idx_ord_dataMessaADimora_replica;

ANALYZE;


SELECT siOccupaDi.scuola, dataMessaADimora, numeroRep, gruppo, siOccupaDi.specie
FROM replica 
	JOIN specie ON replica.specie = nomeScientifico 
	JOIN sioccupadi ON nomeScientifico = siOccupaDi.specie
	JOIN scuola ON siOccupaDi.scuola = codiceMeccanografico
WHERE dataMessaADimora > '01-01-2023' AND comune = 'Novara'

--- Total query runtime: 72 msec (timings exclusive=0.268 ms e inclusive= 3.675 ms)

--- Il piano scelto dal sistema è una sequenza di HASH INNER JOIN, HASH, SEQ SCAN, NESTED LOOP JOIN e INDEX SCAN

--- 1) Hash Inner Join (cost=257.69..282.89 rows=2 width=40) (actual=3.253..3.675 rows=822 loops=1)
---    Hash Cond: ((replica.specie)::text = (specie.nomescientifico)::text)

--- 2) -> Index Scan using idx_ord_datamessaadimora_replica on ortiScolasticiLarge.replica as replica (cost=0.29..23.85 rows=432 width=21) (actual=0.182..0.37 rows=437 loops=1)
---       Index Cond: (replica.datamessaadimora > '2023-01-01'::date)

--- 3) -> Hash (cost=256.51..256.51 rows=71 width=43) (actual=3.037..3.037 rows=65 loops=1)
---       Buckets: 1024 Batches: 1 Memory Usage: 13 kB

--- 4)    -> Nested Loop Inner Join (cost=13.83..256.51 rows=71 width=43) (actual=0.527..3 rows=65 loops=1)

--- 5)       -> Hash Inner Join (cost=13.55..225.77 rows=71 width=28) (actual=0.451..2.369 rows=65 loops=1)
---             Hash Cond: (sioccupadi.scuola = scuola.codicemeccanografico) 

--- 6)          -> Seq Scan on ortiScolasticiLarge.sioccupadi as sioccupadi (cost=0..174.01 rows=10001 width=28) (actual=0.056..0.909 rows=10001 loops=1)	

--- 7)          -> Hash (cost=11.77..11.77 rows=142 width=11) (actual=0.203..0.203 rows=142 loops=1)
---                Buckets: 1024 Batches: 1 Memory Usage: 14 kB


--- 8)             -> Index Scan using idx_ord_comune_scuola on ortiScolasticiLarge.scuola as scuola (cost=0.29..11.77 rows=142 width=11) (actual=0.081..0.162 rows=142 loops=1)
---                   Index Cond: ((scuola.comune)::text = 'Novara'::text)

--- 9)       -> Index Only Scan using specie_pkey on ortiScolasticiLarge.specie as specie (cost=0.29..0.42 rows=1 width=15) (actual=0.008..0.009 rows=1 loops=65)
---             Index Cond: (specie.nomescientifico = (sioccupadi.specie)::text)


------------------ SEZIONE 3: Controllo dell'accesso ---------------------

-- Creazione dei ruoli

CREATE ROLE GestoreProgetto;
CREATE ROLE ReferenteScuola;
CREATE ROLE Insegnante;
CREATE ROLE Studente;

-- Creazione della gerarchia

GRANT Studente TO Insegnante;
GRANT Insegnante TO ReferenteScuola;
GRANT ReferenteScuola TO GestoreProgetto;


-- Privilegi GestoreProgetto
GRANT ALL PRIVILEGES ON SCHEMA "ortiScolasticiLarge" TO GestoreProgetto WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "ortiScolasticiLarge" TO GestoreProgetto WITH GRANT OPTION;

-- Privilegi Studente
GRANT SELECT ON TABLE Specie TO Studente;
GRANT SELECT ON TABLE Orto TO Studente;
GRANT SELECT ON TABLE Sensore TO Studente;
GRANT SELECT ON TABLE Gruppo TO Studente;
GRANT SELECT ON TABLE Replica TO Studente;
GRANT SELECT ON TABLE Rilevazione TO Studente;

-- Privilegi Insegnante

GRANT SELECT ON TABLE Specie TO Insegnante WITH GRANT OPTION;
GRANT SELECT ON TABLE Orto TO Insegnante WITH GRANT OPTION;
GRANT SELECT ON TABLE Sensore TO Insegnante WITH GRANT OPTION;
GRANT SELECT ON TABLE Gruppo TO Insegnante WITH GRANT OPTION;
GRANT SELECT ON TABLE Replica TO Insegnante WITH GRANT OPTION;
GRANT INSERT ON TABLE Replica TO Insegnante;
GRANT SELECT ON TABLE Rilevazione TO Insegnante WITH GRANT OPTION;
GRANT INSERT ON TABLE Rilevazione TO Insegnante;
GRANT SELECT ON TABLE SiOccupaDi TO Insegnante;


-- Privilegi ReferenteScuola

GRANT SELECT, INSERT ON TABLE Classe TO ReferenteScuola;
GRANT INSERT ON TABLE Orto TO ReferenteScuola;
GRANT INSERT ON TABLE Sensore TO ReferenteScuola;
GRANT INSERT ON TABLE Gruppo TO ReferenteScuola;
GRANT INSERT ON TABLE Replica TO ReferenteScuola WITH GRANT OPTION;
GRANT SELECT ON TABLE Responsabile TO ReferenteScuola;
GRANT INSERT ON TABLE Rilevazione TO ReferenteScuola WITH GRANT OPTION;
GRANT SELECT ON TABLE SiOccupaDi TO ReferenteScuola WITH GRANT OPTION;
GRANT INSERT ON TABLE SiOccupaDi TO ReferenteScuola;

-- Assegnazione ruoli a 5 utenti

CREATE USER alice PASSWORD 'alice';
CREATE USER bob PASSWORD 'bob';
CREATE USER charlie PASSWORD 'charlie';
CREATE USER dave PASSWORD 'dave';
CREATE USER eve PASSWORD 'eve';

GRANT USAGE ON SCHEMA "ortiScolasticiLarge" TO alice WITH GRANT OPTION;
GRANT USAGE ON SCHEMA "ortiScolasticiLarge" TO bob WITH GRANT OPTION;
GRANT USAGE ON SCHEMA "ortiScolasticiLarge" TO charlie;
GRANT USAGE ON SCHEMA "ortiScolasticiLarge" TO dave;
GRANT USAGE ON SCHEMA "ortiScolasticiLarge" TO eve;

GRANT GestoreProgetto TO alice;
GRANT ReferenteScuola TO bob;
GRANT Insegnante TO charlie;
GRANT Insegnante TO dave;
GRANT Studente TO eve;

