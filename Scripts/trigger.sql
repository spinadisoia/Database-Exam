SET search_path to 'prova3';
SET datestyle to 'DMY';

--- Trigger ---

-- Obbligatori
-- 1: Verifica che il vincolo che ogni scuola dovrebbe concentrarsi su tre specie e
--    ogni gruppo dovrebbe contenere 20 repliche

-- a) Non più di tre specie

CREATE FUNCTION nonTre() RETURNS TRIGGER AS
$$
	BEGIN
		IF (SELECT COUNT(*) FROM siOccupaDi WHERE scuola = NEW.scuola) >= 3
		THEN RAISE EXCEPTION 'La scuola % si sta già occupando di tre specie', NEW.scuola;
		ELSE RETURN NEW;
		END IF;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaSpecieScuola
BEFORE INSERT OR UPDATE ON siOccupaDi
FOR EACH ROW
EXECUTE PROCEDURE nonTre();

SELECT scuola, COUNT(specie)
FROM siOccupaDi
GROUP BY scuola
HAVING COUNT(specie) = 2;

INSERT INTO sioccupadi VALUES ('87227', 'Korary');
INSERT INTO sioccupadi VALUES ('87227', 'Vlanium');

SELECT * FROM sioccupadi; -- WHERE scuola = '87227';

-- Funziona!!!

-- b) Non più di venti repliche

CREATE FUNCTION nonVenti() RETURNS TRIGGER AS
$$
	BEGIN
		IF (SELECT COUNT(*) FROM Replica WHERE gruppo = NEW.gruppo) >= 20
		THEN RAISE EXCEPTION 'Nel gruppo % ci sono già più di 20 repliche', NEW.gruppo;
		ELSE RETURN NEW;
		END IF;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaReplicheGruppo
BEFORE INSERT OR UPDATE ON Replica
FOR EACH ROW
EXECUTE PROCEDURE nonVenti();


SELECT * FROM replica;
SELECT COUNT(*), gruppo FROM replica GROUP BY gruppo;

INSERT INTO replica VALUES (101, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (102, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (103, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (104, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (105, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (106, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (107, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (108, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (109, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (110, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (111, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (112, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');
INSERT INTO replica VALUES (113, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');

INSERT INTO replica VALUES (114, 78, 'sole', CURRENT_DATE, '1OV', 26273, 'SmmPPN', 'Korary');


-- 2: Generazione di un messaggio (o inserimento di una informazione di warning in qualche tabella)
--	  quando viene rilevato un valore decrescente per un parametro di biomassa

-- !!!!!!!!!!!!!!! Ci siamo dimenticati la lunghezza delle foglie (spero teoricamente solo nello schema logico)

/*
CREATE FUNCTION biomassaDecrescente() RETURNS TRIGGER AS
$$
	DECLARE
		laReplica INTEGER;
		ilGruppo INTEGER;
		timestampRilevazione TIMESTAMP;
		pesoFrescoFoglie NUMERIC(4,2); 
		pesoSeccoFoglie NUMERIC(4,2); 
		larghezzaFoglie NUMERIC(4,2);
		lunghezzaFoglie NUMERIC(4,2);  
		altezzaPianta NUMERIC(4,2); 
		lunghezzaRadici NUMERIC(4,2); 
		parametriBiomassa CURSOR FOR 
								SELECT replica, gruppo, dataOraRil, pesoFrescoF, pesoSeccoF, larghezzaF, lunghezzaF, altezza, lunghezzaR
								FROM Rilevazione
								WHERE replica = NEW.replica AND gruppo = NEW.gruppo
								ORDER BY dataOraRil ASC;
	BEGIN
		OPEN parametriBiomassa;
		FETCH parametriBiomassa INTO laReplica,ilGruppo,timestampRilevazione,pesoFrescoFoglie,pesoSeccoFoglie,larghezzaFoglie,lunghezzaFoglie,altezzaPianta,lunghezzaRadici;
		WHILE FOUND AND timestampRilevazione > NEW.dataOraRil
		IF(SELECT dataOraRil FROM Rilevazione WHERE replica = NEW.replica AND gruppo = NEW.gruppo) > NEW.dataOraRil
		THEN
		END IF;
	END;
$$
LANGUAGE plpgsql;




CREATE OR REPLACE TRIGGER controlloBiomassa
AFTER INSERT OR UPDATE ON Rilevazione
FOR EACH ROW
EXECUTE PROCEDURE biomassaDecrescente();
*/

CREATE OR REPLACE FUNCTION biomassaDecrescente() RETURNS TRIGGER AS
$$
	DECLARE
		laReplica INTEGER;
		ilGruppo INTEGER;
		timestampRilevazione TIMESTAMP;
		pesoFrescoFoglie NUMERIC(4,2); 
		pesoSeccoFoglie NUMERIC(4,2); 
		larghezzaFoglie NUMERIC(4,2);
		lunghezzaFoglie NUMERIC(4,2);  
		altezzaPianta NUMERIC(4,2); 
		lunghezzaRadici NUMERIC(4,2);
		stringaValori VARCHAR(500) := '';
		controllo boolean := FALSE; 
	BEGIN
		SELECT replica,gruppo,dataOraRil,pesoFrescoF,pesoSeccoF,larghezzaF,lunghezzaF,altezza,lunghezzaR 
		INTO laReplica,ilGruppo,timestampRilevazione,pesoFrescoFoglie,pesoSeccoFoglie,larghezzaFoglie,lunghezzaFoglie, altezzaPianta,lunghezzaRadici
		FROM Rilevazione 
		WHERE 
		   /* replica = NEW.replica AND gruppo = NEW.gruppo AND */ 
		   replica = NEW.replica AND gruppo = NEW.gruppo AND
		   dataOraRil = (SELECT MAX(dataOraRil) FROM rilevazione WHERE replica = NEW.replica AND gruppo = NEW.gruppo AND dataOraRil < NEW.dataOraRil);
				
		stringaValori := stringaValori || 'Per la replica ' || laReplica || ' appartenente al gruppo ' || ilGruppo || ' sono stati trovati i seguenti valori decrescenti' || E'\n' || '[data rilevazione precedente: ' || timestampRilevazione || ' -> data rilevazione aggiunta/modificata: ' || NEW.dataOraRil || ']:'; 
		stringaValori := stringaValori || E'\n';
				
		IF (pesoFrescoFoglie > NEW.pesoFrescoF)
		THEN 
			stringaValori := stringaValori || '--- il peso fresco della chioma: ' || pesoFrescoFoglie || ' -> ' || NEW.pesoFrescoF || E'\n';
			controllo := TRUE;
		END IF;

		IF (pesoSeccoFoglie > NEW.pesoSeccoF)
		THEN 
			stringaValori := stringaValori || '--- il peso secco della chioma: ' || pesoSeccoFoglie || ' -> ' || NEW.pesoSeccoF || E'\n';
			controllo := TRUE;
		END IF;
		
		IF (larghezzaFoglie > NEW.larghezzaF)
		THEN 
			stringaValori := stringaValori || '--- la larghezza della chioma: ' || larghezzaFoglie || ' -> ' || NEW.larghezzaF || E'\n';
			controllo := TRUE;
		END IF;
		
		IF (lunghezzaFoglie > NEW.lunghezzaF)
		THEN 
			stringaValori := stringaValori || '--- la lunghezza della chioma: ' || lunghezzaFoglie || ' -> ' || NEW.lunghezzaF || E'\n';
			controllo := TRUE;
		END IF;
		
		IF (altezzaPianta > NEW.altezza)
		THEN 
			stringaValori := stringaValori || '--- l''altezza della pianta: ' || altezzaPianta || ' -> ' || NEW.altezza || E'\n';
			controllo := TRUE;
		END IF;
		
		IF (lunghezzaRadici > NEW.lunghezzaR)
		THEN 
			stringaValori := stringaValori || '--- la lunghezza delle radici: ' || lunghezzaRadici || ' -> ' || NEW.lunghezzaR || E'\n';
			controllo := TRUE;
		END IF;
		
		IF controllo
		THEN RAISE NOTICE '%', stringaValori;
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controlloBiomassa
BEFORE INSERT OR UPDATE ON Rilevazione
FOR EACH ROW
EXECUTE PROCEDURE biomassaDecrescente();


SELECT * FROM rilevazione;

INSERT INTO rilevazione VALUES (1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Arduino', 'suolo', 'suolo', 5.00, 2.00, 40.00, 6.00, 28.00, 4.00, 0.80, 40000, 50000, 30000, 6.00, 2.00, 9.00, 5.40, 7, 7, 31.00);


-- Facoltativi (dati dai vincoli che abbiamo scritto)
-- v4 (vedere se inutile)

/**********************************/


-- v5: Se l'attributo PULIZIA in ORTO è "True" allora l'orto ha solo GRUPPI di 
-- controllo per il biomonitoraggio, mentre se l'ambiente non è pulito allora 
-- può contenere solo GRUPPI per la fitobonifica o GRUPPI di stress per il 
-- biomonitoraggio.	

-- Sia nell'update dell'orto (per mantenere la consistenza)
-- Sia nell'inserimento e nell'aggiornamento di gruppi

CREATE FUNCTION puliziaOrto() RETURNS TRIGGER AS
$$
	BEGIN
		IF NEW.pulizia
		THEN
			IF EXISTS ( SELECT * FROM gruppo WHERE orto = NEW.nomeOrto AND gruppo.scuola = NEW.scuola AND tipoGruppo IN ('bio-stress', 'fitobonifica'))
			THEN RAISE EXCEPTION 'Un orto pulito non può avere gruppi dedicati al biomonitoraggio in condizioni di stress o alla fitobonifica';
			END IF;
		ELSE 
			IF EXISTS ( SELECT * FROM gruppo WHERE orto = NEW.nomeOrto AND gruppo.scuola = NEW.scuola AND tipoGruppo IN ('bio-controllo'))
			THEN RAISE EXCEPTION 'Un orto in un ambiente non pulito non può avere gruppi dedicati al biomonitoraggio con finalità di controllo';
			END IF;
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;




CREATE TRIGGER controllaPuliziaOrto
BEFORE UPDATE ON Orto
FOR EACH ROW
EXECUTE PROCEDURE puliziaOrto();


SELECT * FROM Orto JOIN Gruppo ON orto.nomeOrto = gruppo.orto AND orto.scuola = gruppo.scuola;

-- UPDATE Orto SET pulizia = FALSE WHERE nomeOrto = 'f3BdS' AND scuola = '96791     '


CREATE OR REPLACE FUNCTION puliziaGruppo() RETURNS TRIGGER AS
$$
	DECLARE
		puliziaO BOOLEAN;
	BEGIN
		SELECT pulizia INTO puliziaO FROM orto JOIN gruppo ON orto.nomeOrto = gruppo.orto AND orto.scuola = gruppo.scuola WHERE gruppo.codGruppo = NEW.codGruppo;
		IF puliziaO
		THEN
			IF NEW.tipoGruppo IN ('bio-stress', 'fitobonifica')
			THEN RAISE EXCEPTION 'Un gruppo dedicato al biomonitoraggio in condizioni di stress o alla fitobonifica non può trovarsi in un orto pulito';
			END IF;
		ELSE 
			IF NEW.tipoGruppo = 'bio-controllo'
			THEN RAISE EXCEPTION 'Un gruppo dedicato al biomonitoraggio con finalità di controllo non può trovarsi in un ambiente non pulito';
			END IF;
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaPuliziaGruppo
BEFORE INSERT OR UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE puliziaGruppo();


--INSERT INTO Gruppo VALUES(101, 'qeZL', '32139     ', 'bio-controllo', 90000);
--Giustamente dà eccezione: fare altri controlli...



--v6: L'attributo ciclo in SCUOLA deve essere coerente 
--    con l'attributo ordineTipo in CLASSE.

-- sia inserendo/modificando una classe, sia modificando una scuola

-- CERCARE UNA LISTA DI TIPI ABBASTANZA GRANDE PER LE SUPERIORI (MAGARI AGGIUNGERLA ANCHE COME VINCOLO CHECK)!!!!!!

CREATE FUNCTION cicloScuola() RETURNS TRIGGER AS
$$
	BEGIN
		IF NEW.ciclo = '1'
		THEN
			IF EXISTS ( SELECT * FROM classe WHERE classe.scuola = NEW.codiceMeccanografico AND ordineTipo NOT IN ('primaria', 'secondaria di primo grado'))
			THEN RAISE EXCEPTION 'Una scuola appartenente al primo ciclo di istruzione non può avere classi diverse da: ''primaria'' e ''secondaria di primo livello'' ';
			END IF;
		ELSE 
			IF NEW.ciclo = '2' AND EXISTS ( SELECT * FROM classe WHERE classe.scuola = NEW.codiceMeccanografico AND ordineTipo IN ('primaria', 'secondaria di primo grado'))
			THEN RAISE EXCEPTION 'Una scuola appartenente al secondo ciclo di istruzione non può avere classi che hanno i seguenti ordini: ''primaria'' e ''secondaria di primo livello'' ';
			END IF;
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaCicloScuola
BEFORE UPDATE ON Scuola
FOR EACH ROW
EXECUTE PROCEDURE cicloScuola();


-- Inserimento/modifica classe

CREATE FUNCTION ordineTipoClasse() RETURNS TRIGGER AS
$$
	DECLARE
		cicloScuola CHAR(1);

	BEGIN
		SELECT ciclo INTO cicloScuola FROM Scuola WHERE NEW.scuola = codiceMeccanografico;
		IF cicloScuola = '1'
		THEN
			IF NEW.ordineTipo NOT IN ('primaria', 'secondaria di primo grado')
			THEN RAISE EXCEPTION 'Una classe non ''primaria'' o ''secondaria di primo livello'' non può trovarsi in una scuola di primo ciclo';
			END IF;
		ELSE IF cicloScuola = '2' AND NEW.ordineTipo IN ('primaria', 'secondaria di primo grado')
			THEN RAISE EXCEPTION 'Una classe ''primaria'' o ''secondaria di primo livello'' non può trovarsi in una scuola di secondo ciclo';
			END IF;
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaOrdineTipoClasse
BEFORE INSERT OR UPDATE ON Classe
FOR EACH ROW
EXECUTE PROCEDURE ordineTipoClasse();


-- v8: Non possono essere dislocate repliche da scuole esterne in orti non disponibili 
--     alla collaborazione, ovvero orti in cui l'attributo DISPONIBILITA è "False".	

-- sia nella modifica dell'attributo in orto
-- sia nell'aggiunta/modifica del gruppo

CREATE FUNCTION disponibilitaOrto() RETURNS TRIGGER AS
$$
	DECLARE
		scuolaMetteADimora CHAR(10);
	BEGIN
		SELECT sioccupadi.scuola INTO scuolaMetteADimora 
		FROM replica 
			JOIN gruppo ON replica.gruppo = gruppo.codGruppo
			JOIN specie ON replica.specie = specie.nomeScientifico
			JOIN sioccupadi ON sioccupadi.specie = specie.nomeScientifico
		WHERE NEW.nomeOrto = gruppo.orto AND NEW.scuola = gruppo.scuola;
		
		IF NOT NEW.disponibilita AND scuolaMetteADimora != NEW.scuola
		THEN RAISE EXCEPTION 'Un orto che non dà/toglie la disponibilità a collaborare non può mantenere repliche di una scuola ''esterna'' ';
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER controllaDisponibilitaOrto
BEFORE UPDATE ON Orto
FOR EACH ROW
EXECUTE PROCEDURE disponibilitaOrto();

/*
SELECT gruppo.scuola, orto.nomeorto, disponibilita, sioccupadi.scuola, specie.nomescientifico
FROM replica 
	JOIN gruppo ON replica.gruppo = gruppo.codGruppo
	JOIN specie ON replica.specie = specie.nomeScientifico
	JOIN sioccupadi ON sioccupadi.specie = specie.nomeScientifico
	JOIN orto ON gruppo.orto = orto.nomeorto AND gruppo.scuola = orto.scuola;		
*/
 
-- UPDATE Orto SET disponibilita = FALSE WHERE nomeOrto = 'S0GNXJQOLvnI8RgoLT' AND scuola = '41030     ';

CREATE FUNCTION disponibilitaGruppo() RETURNS TRIGGER AS
$$
	DECLARE
		scuolaMetteADimora CHAR(10);
		disponibilitaO BOOLEAN;
	BEGIN
		SELECT sioccupadi.scuola, disponibilita INTO scuolaMetteADimora, disponibilitaO 
		FROM replica 
			JOIN gruppo ON replica.gruppo = gruppo.codGruppo
			JOIN specie ON replica.specie = specie.nomeScientifico
			JOIN sioccupadi ON sioccupadi.specie = specie.nomeScientifico
			JOIN orto ON gruppo.orto = orto.nomeorto AND gruppo.scuola = orto.scuola		
		WHERE orto.nomeOrto = NEW.orto AND orto.scuola = NEW.scuola;
		
		IF NOT NEW.disponibilita AND scuolaMetteADimora != NEW.scuola
		THEN RAISE EXCEPTION 'Un orto che non dà/toglie la disponibilità a collaborare non può mantenere repliche di una scuola ''esterna'' ';
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaDisponibilitaGruppo
BEFORE INSERT OR UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE disponibilitaGruppo();

--- VERIFICARE!!!!!
-------------------------------

-- v9: Se il gruppo della REPLICA è 'fitobonifica' allora è obbligatorio l'attributo 
--     cosaMonitoro in RILEVAZIONE. Se è 'bio-controllo' o 'bio-stress' allora 
--     non deve essere presente.	


-- sia update in gruppo sia ins/update in rilevazione
CREATE FUNCTION tipoGruppo() RETURNS TRIGGER AS
$$
	DECLARE
		monitorato VARCHAR(5);
	BEGIN
		SELECT cosaMonitoro INTO monitorato
		FROM rilevazione
			JOIN replica ON rilevazione.gruppo = replica.gruppo AND rilevazione.replica = replica.numeroRep
		WHERE NEW.codGruppo = replica.gruppo;
	
		IF NEW.tipoGruppo = 'fitobonifica' AND monitorato IS NULL
		THEN RAISE EXCEPTION 'Un gruppo di tipo fitobonifica non può avere rilevazioni nelle quali l''attributo cosaMonitoro è NULL';
		ELSE IF NEW.tipoGruppo IN ('bio-stress','bio-controllo') AND monitorato IS NOT NULL
			 THEN RAISE EXCEPTION 'Un gruppo di tipo biomonitoraggio non può avere rilevazioni nelle quali l''attributo cosaMonitoro è diverso da NULL';
			 END IF;
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaTipoGruppo
BEFORE UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE tipoGruppo();

--

CREATE FUNCTION tipoRilevazione() RETURNS TRIGGER AS
$$
	DECLARE
		tipo VARCHAR(20);
	BEGIN
		SELECT tipoGruppo INTO tipo
		FROM gruppo
			JOIN replica ON gruppo.codGruppo = replica.gruppo
		WHERE NEW.gruppo = replica.gruppo AND NEW.replica = replica.numeroRep;
	
		IF tipo = 'fitobonifica' AND NEW.cosaMonitoro IS NULL
		THEN RAISE EXCEPTION 'Un gruppo di tipo fitobonifica non può avere rilevazioni nelle quali l''attributo cosaMonitoro è NULL';
		ELSE IF tipo IN ('bio-stress','bio-controllo') AND NEW.cosaMonitoro IS NOT NULL
			 THEN RAISE EXCEPTION 'Un gruppo di tipo biomonitoraggio non può avere rilevazioni nelle quali l''attributo cosaMonitoro è diverso da NULL';
			 END IF;
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaTipoRilevazione
BEFORE INSERT OR UPDATE ON Rilevazione
FOR EACH ROW
EXECUTE PROCEDURE tipoRilevazione();

------ DA VERIFICARE!!!!

-- v13: A un gruppo di bio-stress deve corrisponderne 
--      uno solo di bio-controllo e viceversa	

-- Solo negli inserimenti e nelle modifiche a gruppo

CREATE FUNCTION corrispondenzaBio() RETURNS TRIGGER AS
$$
		
	BEGIN
		IF NEW.tipoGruppo = 'fitobonifica' AND NEW.codBio IS NOT NULL
		THEN RAISE EXCEPTION 'Un gruppo di tipo fitobonifica non può avere un codBio';
		END IF;


		IF EXISTS(SELECT * FROM Gruppo WHERE codBio = NEW.codBio AND tipoGruppo = NEW.tipoGruppo)
		THEN RAISE EXCEPTION 'Un gruppo di tipo biomonitoraggio non può più di un gruppo corrispondente del tipo opposto';
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaCorrispondenzaBio
BEFORE INSERT OR UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE corrispondenzaBio();

--- VERIFICARE !!!!!!!!!!!!!

-- v14: Una sola specie per gruppo

-- Solo l'aggiunta/modifica di replica ?

CREATE FUNCTION specieGruppo() RETURNS TRIGGER AS
$$
		
	BEGIN
		IF (SELECT COUNT(DISTINCT specie) FROM replica WHERE gruppo = NEW.gruppo) > 1
		THEN RAISE EXCEPTION 'Un gruppo deve essere costituito da repliche della stessa specie';
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaUnaSpecieUnGruppo
BEFORE INSERT OR UPDATE ON Replica
FOR EACH ROW
EXECUTE PROCEDURE specieGruppo();

--- Da verificare!!!

/*
-- v15: CLASSE METTE A DIMORA DEVE ESSERE DELLA SCUOLA CHE SI OCCUPA DI QUELLA SPECIE 

-- modifica/aggiunta Replica e modifica sioccupadi?

CREATE FUNCTION classeReplica() RETURNS TRIGGER AS
$$
		
	BEGIN
	
		SELECT siOccupaDi.scuola 
		FROM replica
			JOIN specie ON replica.specie = specie.nomeScientifico
			JOIN siOccupaDi ON specie.nomeScientifico = siOccupaDi.specie
		WHERE NEW.
		NEW.scuolaMessaADimora = siOccupaDi.scuola
		
		IF (SELECT COUNT(DISTINCT specie) FROM replica WHERE gruppo = NEW.gruppo) > 1
		THEN RAISE EXCEPTION 'Un gruppo deve essere costituito da repliche della stessa specie';
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaClasseReplica
BEFORE INSERT OR UPDATE ON Replica
FOR EACH ROW
EXECUTE PROCEDURE classeReplica();


SELECT * FROM replica
			JOIN specie ON replica.specie = specie.nomeScientifico
			JOIN siOccupaDi ON specie.nomeScientifico = siOccupaDi.specie
*/
----------------------------------------------------------------------------------------
/*
CREATE FUNCTION /* NOME () */ RETURNS TRIGGER AS
$$

$$
LANGUAGE plpgsql;




CREATE OR REPLACE TRIGGER /* NOME */
BEFORE /* AFTER  evento */
ON /* TABELLA */
/* FOR EACH ROW-STATEMENT */
/* WHEN CONDIZIONE */
EXECUTE /* FUNCTION-PROCEDURE NOME */

*/
