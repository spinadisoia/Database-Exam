set search_path to 'prova3';
set datestyle to 'DMY';

SELECT * FROM gruppo;

CREATE OR REPLACE VIEW InfoBiomonitoraggio(numeroBiomonitoraggio, numeroGruppoStress, numeroPianteNelGruppoStress, specieGruppoStress, ortoGruppoStress, meseGruppoStress,
										  						  mediaAltezzaStress, mediaFioriStress, mediaFruttiStress, mediaTemperaturaStress, mediaUmiditaStress, mediaPHStress,
										   						  numeroGruppoControllo, numeroPianteNelGruppoControllo, specieGruppoControllo, ortoGruppoControllo, meseGruppoControllo,
										  						  mediaAltezzaControllo, mediaFioriControllo, mediaFruttiControllo, mediaTemperaturaControllo, mediaUmiditaControllo, mediaPHControllo										  
										  ) 
AS
SELECT G1.codBio, G1.codGruppo, COUNT(DISTINCT R1.numeroRep), R1.specie, G1.orto, EXTRACT (MONTH FROM Ril1.dataOraRil), AVG(Ril1.altezza) AS mAltezzaStress, AVG(Ril1.nFiori) AS mFioriStress, AVG(Ril1.nFrutti) AS mFruttiStress, AVG(Ril1.temperatura) AS mTemperaturaStress, AVG(Ril1.umidità) AS mediaUmiditàStress, AVG(Ril1.pH) AS mPHStress,
				  G2.codGruppo, COUNT(DISTINCT R2.numeroRep), R2.specie, G2.orto, EXTRACT (MONTH FROM Ril2.dataOraRil), AVG(Ril2.altezza) AS mAltezzaControllo, AVG(Ril2.nFiori) AS mFioriControllo, AVG(Ril2.nFrutti) AS mFruttiControllo, AVG(Ril2.temperatura) AS mTemperaturaControllo, AVG(Ril2.umidità) AS mediaUmiditàControllo, AVG(Ril2.pH) AS mPHControllo
FROM gruppo G1 
	JOIN gruppo G2 ON G1.codBio = G2.codBio
	JOIN replica R1 ON G1.codGruppo = R1.gruppo
	JOIN replica R2 ON G2.codGruppo = R2.gruppo
	JOIN rilevazione Ril1 ON R1.gruppo = Ril1.gruppo AND R1.numeroRep = Ril1.replica
	JOIN rilevazione Ril2 ON R2.gruppo = Ril2.gruppo AND R2.numeroRep = Ril2.replica
WHERE G1.codGruppo != G2.codGruppo AND G1.tipoGruppo = 'bio-stress'
GROUP BY G1.codBio, G1.codGruppo, R1.specie, G1.orto, G2.codGruppo, R2.specie, G2.orto,
		EXTRACT (MONTH FROM Ril1.dataOraRil), EXTRACT (MONTH FROM Ril2.dataOraRil)
--HAVING EXTRACT (MONTH FROM Ril1.dataOraRil) = EXTRACT (MONTH FROM Ril2.dataOraRil)
WITH CHECK OPTION;

SELECT * FROM infobiomonitoraggio;

