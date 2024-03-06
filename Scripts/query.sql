SET search_path TO prova3;
SET datestyle TO 'DMY';


--Query 1--
-- seleziono le scuole con finanziamento che non stanno tra quelle che hanno effettuato rilevazioni tra settembre e giugno--

SELECT scuola
FROM FINANZIAMENTO
WHERE scuola NOT IN (SELECT scuola
					 FROM GRUPPO JOIN RILEVAZIONE ON gruppo=codGruppo
					 WHERE dataOraRil BETWEEN '01-09-2022' AND '30-06-2023'
					);


--Query 2--
SELECT nomeScientifico, COUNT(comune)
	FROM SPECIE 
		JOIN SIOCCUPADI ON specie = nomeScientifico
		JOIN SCUOLA ON scuola = codiceMeccanografico
	GROUP BY nomeScientifico
	HAVING COUNT (DISTINCT comune) = (SELECT COUNT (DISTINCT comune)
								 		FROM SCUOLA);


-- Questa query ha dei problemi probabilmente il natural join
SELECT nomeScientifico, COUNT(comune)
	FROM SPECIE NATURAL JOIN SIOCCUPADI NATURAL JOIN SCUOLA
	GROUP BY nomeScientifico
	HAVING COUNT (DISTINCT comune) = (SELECT COUNT (DISTINCT comune)
								 		FROM SCUOLA);


--Query 3--

			
SELECT responsabileRilevazione, persona, classe, scuola
	FROM RESPONSABILE 
		JOIN RILEVAZIONE ON responsabileRilevazione = codiceResp
	WHERE responsabileRilevazione IN (SELECT responsabileRilevazione
									  FROM RILEVAZIONE
									  GROUP BY responsabileRilevazione
									  HAVING COUNT (*)>= ALL (SELECT COUNT(*) 
						   									  FROM RILEVAZIONE
						  									  GROUP BY responsabileRilevazione
															 )
									 );

-- Anche qui succedono cose strane di sotto		
				
SELECT responsabileRilevazione, persona, classe, scuola
	FROM RESPONSABILE NATURAL JOIN RILEVAZIONE
	WHERE responsabileRilevazione IN (SELECT responsabileRilevazione
								FROM RILEVAZIONE
								GROUP BY responsabileRilevazione
								HAVING COUNT (*)>= ALL ( SELECT COUNT(*) 
						   									FROM RILEVAZIONE
						  									GROUP BY responsabileRilevazione))