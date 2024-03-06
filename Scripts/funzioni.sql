--- Funzioni ---

SET search_path to 'prova3';
SET datestyle to 'DMY';

-- Funzione che realizza l'abbinamento tra gruppo di stress e gruppo di controllo nel caso
-- di operazioni di biomonitoraggio
CREATE OR REPLACE FUNCTION abbinaGruppi(IN ilGruppo INTEGER, OUT bioGruppo INTEGER)
AS
$$
	DECLARE 
		nomeOrto VARCHAR(20);
		scuolaOrto CHAR(10);
		tipo VARCHAR(20);
		codice INTEGER;
	
	BEGIN
		nomeOrto := (SELECT orto FROM gruppo WHERE codGruppo = ilGruppo);
		scuolaOrto := (SELECT scuola FROM gruppo WHERE codGruppo = ilGruppo);
		tipo := (SELECT tipoGruppo FROM gruppo WHERE codGruppo = ilGruppo);
		codice := (SELECT codBio FROM gruppo WHERE codGruppo = ilGruppo);
		
		RAISE NOTICE 'TROVATI: orto: %, ', nomeOrto;
		RAISE NOTICE 'scuola: %, ', scuolaOrto;
		RAISE NOTICE 'tipo: %, ', tipo;
		RAISE NOTICE 'codBio: %, ', codice;
		
		IF tipo = 'bio-stress'
			THEN bioGruppo := (SELECT codGruppo FROM gruppo WHERE tipoGruppo = 'bio-controllo' AND codBio = codice);
			ELSEIF tipo = 'bio-controllo'
				THEN bioGruppo := (SELECT codGruppo FROM gruppo WHERE tipoGruppo = 'bio-stress' AND codBio = codice);
			ELSE RAISE NOTICE 'ERRORE: solo i gruppi di tipo bio-stress o bio-controllo possono avere gruppi corrispondenti del tipo opposto';
		END IF;
	END;
$$
LANGUAGE plpgsql;


SELECT * FROM gruppo;
SELECT abbinaGruppi(11);

SELECT * FROM rilevazione WHERE replica = 91;

-- Funzione che corrisponde alla seguente query parametrica: data una replica con
-- finalità di fitobonifica e due date, determina i valori medi dei parametri rilevati
-- per tale replica nel periodo compreso tra le due date

CREATE OR REPLACE FUNCTION mediaValori(IN laReplica INTEGER, IN ilGruppo INTEGER, IN dataInizio TIMESTAMP, IN dataFine TIMESTAMP) 
RETURNS TABLE(numeroReplica INTEGER, numeroGruppo INTEGER, mediaPFFoglie NUMERIC(4,2), mediaPSFoglie NUMERIC(4,2), mediaLarghezzaFoglie NUMERIC(4,2), mediaAltezza NUMERIC(4,2), 
			  mediaLunghezzaRadici NUMERIC(4,2), mediaPFRadici NUMERIC(4,2), mediaPSRadici NUMERIC(4,2), mediaNumeroFiori NUMERIC(4,2),
			  mediaNumeroFrutti NUMERIC(4,2), mediaNumeroFoglie NUMERIC(4,2), mediaSupPerc NUMERIC(5,2), mediaTemperatura NUMERIC(4,2),
		      mediaPH NUMERIC(4,2), mediaUmidità NUMERIC(5,2)/* **** */)
AS
$$
	DECLARE 
		tipo VARCHAR(20) := (SELECT tipoGruppo FROM gruppo WHERE codGruppo = ilGruppo);
	
	BEGIN
		IF tipo = 'fitobonifica'
		THEN
			RETURN QUERY
				SELECT replica, gruppo, AVG(pesoFrescoF), AVG(pesoSeccoF), AVG(larghezzaF), AVG(altezza), AVG(lunghezzaR), AVG(pesoFrescoR), AVG(pesoSeccoR), AVG(nFiori), AVG(nFrutti), AVG(nFoglie), AVG(supPerc), AVG(temperatura), AVG(pH), AVG(umidità)
				FROM rilevazione
				WHERE laReplica = replica AND ilGruppo = gruppo AND dataOraRil BETWEEN dataInizio AND dataFine
				GROUP BY replica, gruppo;
		ELSE
			RAISE NOTICE 'ERRORE: il tipo deve essere fitobonifica';
		END IF;
	END;
$$
LANGUAGE plpgsql;


-- DROP FUNCTION mediavalori(integer,integer,timestamp without time zone,timestamp without time zone);

SELECT * FROM gruppo WHERE tipogruppo != 'fitobonifica';
SELECT * FROM rilevazione;

SELECT * FROM mediaValori(91, 91, '01-01-2000 08:00:00', '19-07-2023 08:00:00'); --TEST: Giustamente funziona perché fitobonifica
SELECT * FROM mediaValori(81, 90, '01-01-2000 08:00:00', '19-07-2023 08:00:00'); --TEST: Giustamente non funziona


/* CHISSA' PERCHE' CON GLI OUT NON FUNZIONA
CREATE OR REPLACE FUNCTION mediaVal(IN laReplica INTEGER, IN ilGruppo INTEGER, IN dataInizio TIMESTAMP, IN dataFine TIMESTAMP, 
									OUT numeroReplica INTEGER, OUT numeroGruppo INTEGER, OUT mediaPFFoglie NUMERIC(4,2), 
									OUT mediaPSFoglie NUMERIC(4,2), OUT mediaLarghezzaFoglie NUMERIC(4,2), OUT mediaAltezza NUMERIC(4,2),
			  						OUT mediaLunghezzaRadici NUMERIC(4,2), OUT mediaPFRadici NUMERIC(4,2), OUT mediaPSRadici NUMERIC(4,2), 
									OUT mediaNumeroFiori NUMERIC(4,2), OUT mediaNumeroFrutti NUMERIC(4,2), OUT mediaNumeroFoglie NUMERIC(4,2), 
									OUT mediaSupPerc NUMERIC(5,2), OUT mediaTemperatura NUMERIC(4,2), OUT mediaPH NUMERIC(4,2), OUT mediaUmidità NUMERIC(5,2))
AS
$$
	DECLARE 
		tipo VARCHAR(20) := (SELECT tipoGruppo FROM gruppo WHERE codGruppo = ilGruppo);
	
	BEGIN
		IF tipo = 'fitobonifica'
		THEN
				SELECT replica, gruppo, AVG(pesoFrescoF), AVG(pesoSeccoF), AVG(larghezzaF), AVG(altezza), AVG(lunghezzaR), AVG(pesoFrescoR), AVG(pesoSeccoR), AVG(nFiori), AVG(nFrutti), AVG(nFoglie), AVG(supPerc), AVG(temperatura), AVG(pH), AVG(umidità)
				FROM rilevazione
				WHERE laReplica = replica AND ilGruppo = gruppo AND dataOraRil BETWEEN dataInizio AND dataFine
				GROUP BY replica, gruppo;
		ELSE
			RAISE NOTICE 'ERRORE: il tipo deve essere fitobonifica';
		END IF;
	END;
$$
LANGUAGE plpgsql;

SELECT * FROM mediaVal(91, 91, '01-01-2000 08:00:00', '19-07-2023 08:00:00'); --TEST: Giustamente funziona perché fitobonifica
*/





