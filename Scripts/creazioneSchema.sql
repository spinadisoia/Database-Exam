CREATE SCHEMA prova3;
SET search_path TO prova3;
SET datestyle TO 'DMY';

CREATE TABLE Persona
	(CF CHAR(16) PRIMARY KEY,
	 nome VARCHAR(30) NOT NULL,
	 cognome VARCHAR(30) NOT NULL, 
	 email VARCHAR(40) NOT NULL,
	 ruolo VARCHAR(20) NOT NULL, 
	 telefono INTEGER
	);

CREATE TABLE Scuola
	(codiceMeccanografico CHAR(10) PRIMARY KEY,
	nomeScuola VARCHAR(30) NOT NULL,
	ciclo CHAR(1) NOT NULL CHECK (ciclo IN ('1', '2')),
	provincia CHAR(2) NOT NULL,
	comune VARCHAR(40) NOT NULL,
	referenteIniziativa CHAR(16) NOT NULL REFERENCES Persona(CF) ON UPDATE CASCADE ON DELETE RESTRICT
	);

CREATE TABLE Classe
	(nomeClasse VARCHAR(5),
	 scuola CHAR(10) REFERENCES Scuola ON UPDATE CASCADE ON DELETE RESTRICT,
	 ordineTipo VARCHAR(30) NOT NULL,
	 docenteRif CHAR(16) NOT NULL REFERENCES Persona ON UPDATE CASCADE ON DELETE RESTRICT,
	 PRIMARY KEY(scuola, nomeClasse)
	);

CREATE TABLE Specie
	(nomeScientifico VARCHAR(40) PRIMARY KEY,
	 nomeComune VARCHAR(20) NOT NULL,
	 esposizionePossibile VARCHAR(20) NOT NULL
	);
	

CREATE TABLE Orto
	(nomeOrto VARCHAR(20),
	 scuola CHAR(10) REFERENCES Scuola ON UPDATE CASCADE ON DELETE RESTRICT,
	 tipoOrto VARCHAR(14) NOT NULL CHECK (tipoOrto IN ('in vaso', 'in pieno campo')),
	 superficie NUMERIC(6,2) NOT NULL,
	 GPS VARCHAR(40) NOT NULL,
	 disponibilita BOOLEAN NOT NULL,
	 pulizia BOOLEAN NOT NULL,
	 --numeroSensori INTEGER NOT NULL CHECK (numeroSensori > 0),
	 PRIMARY KEY(nomeOrto, scuola)
	);
	

CREATE TABLE Sensore
	(codiceSerie VARCHAR(20) PRIMARY KEY,
	tipoSensore VARCHAR(20) NOT NULL,
	orto VARCHAR(20) NOT NULL,
	scuola VARCHAR(20)	NOT NULL ,
	FOREIGN KEY (orto, scuola) REFERENCES Orto (nomeOrto, scuola) ON UPDATE CASCADE ON DELETE RESTRICT
	);


CREATE TABLE Gruppo
	(codGruppo INTEGER PRIMARY KEY CHECK (codGruppo >0),
	 orto VARCHAR(20) NOT NULL,
	 scuola	CHAR(10) NOT NULL,
	 tipoGruppo VARCHAR(20) NOT NULL CHECK (tipoGruppo IN ('bio-stress', 'bio-controllo', 'fitobonifica')),
	 codBio INTEGER CHECK (codBio > 0 ),
	 FOREIGN KEY (orto, scuola) REFERENCES Orto (nomeOrto, scuola) ON UPDATE CASCADE ON DELETE RESTRICT,
	 CHECK ((codBio IS NOT NULL AND tipoGruppo IN ('bio-stress', 'bio-controllo')) OR (codBio IS NULL AND tipoGruppo = 'fitobonifica'))
	);

CREATE TABLE Replica
	(numeroRep	INTEGER CHECK (numeroRep >0),
	 gruppo	INTEGER REFERENCES Gruppo ON UPDATE CASCADE ON DELETE RESTRICT,
	 esposizioneSpecifica VARCHAR(20) NOT NULL,
	 dataMessaADimora DATE DEFAULT CURRENT_DATE NOT NULL,
	 classeMessaADimora	VARCHAR(5) NOT NULL ,
	 scuolaMessaADimora CHAR(10) NOT NULL,
	 sensore VARCHAR(20) NOT NULL REFERENCES Sensore ON UPDATE CASCADE ON DELETE RESTRICT,
	 specie VARCHAR(40) NOT NULL REFERENCES Specie ON UPDATE CASCADE ON DELETE RESTRICT,
	 PRIMARY KEY(numeroRep, gruppo),
	 UNIQUE(numeroRep, classeMessaADimora, scuolaMessaADimora),
	 FOREIGN KEY (classeMessaADimora, scuolaMessaADimora) REFERENCES Classe (nomeClasse, scuola) ON UPDATE CASCADE ON DELETE RESTRICT
	);


CREATE TABLE Responsabile
	(codiceResp INTEGER PRIMARY KEY CHECK (codiceResp >0),
	 persona CHAR(16) REFERENCES Persona ON UPDATE CASCADE ON DELETE RESTRICT, 
	 classe CHAR(5) ,
	 scuola CHAR(10) ,
	FOREIGN KEY (classe, scuola) REFERENCES Classe (nomeClasse, scuola) ON UPDATE CASCADE ON DELETE RESTRICT,
	CHECK ((persona IS NOT NULL AND classe IS NULL AND scuola IS NULL) OR (persona IS NULL AND classe IS NOT NULL AND scuola IS NOT NULL)) 
	);

CREATE TABLE Rilevazione
	(replica  INTEGER ,
	 gruppo INTEGER ,
	 dataOraRil TIMESTAMP,
	 dataOraIns TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	 modalitaAcquisizione VARCHAR(7) NOT NULL CHECK (modalitaAcquisizione IN ('app', 'Arduino')),
	 substrato VARCHAR(9) NOT NULL CHECK (substrato IN ('terriccio', 'suolo')),
	 cosaMonitoro VARCHAR(5) CHECK (cosaMonitoro IN ('suolo', 'aria')),
	 pesoFrescoF NUMERIC(4,2) NOT NULL, 
	 pesoSeccoF NUMERIC(4,2) NOT NULL, 
	 larghezzaF NUMERIC(4,2) NOT NULL,
	 lunghezzaF NUMERIC(4,2) NOT NULL,  
	 altezza NUMERIC(4,2) NOT NULL, 
	 lunghezzaR NUMERIC(4,2) NOT NULL, 
	 pesoFrescoR NUMERIC(4,2) NOT NULL, 
	 pesoSeccoR NUMERIC(4,2) NOT NULL, 
	 nFiori INTEGER NOT NULL CHECK (nFiori >= 0), 
	 nFrutti INTEGER NOT NULL CHECK (nFrutti >= 0), 
	 nFoglie INTEGER NOT NULL CHECK (nFoglie >= 0),
	 supPerc NUMERIC(5,2) NOT NULL CHECK (supPerc BETWEEN 0.00 AND 100.00), 
	 temperatura NUMERIC(4,2) NOT NULL, 
	 pH NUMERIC(4,2) NOT NULL CHECK (pH BETWEEN 0.00 AND 14.00), 
	 umidità NUMERIC(5,2) NOT NULL CHECK (supPerc BETWEEN 0.00 AND 100.00), 
	 responsabileRilevazione INTEGER NOT NULL , 
	 responsabileInserimento INTEGER,
	 PRIMARY KEY(dataOraRil, replica, gruppo),
	 FOREIGN KEY (gruppo, replica) REFERENCES Replica (gruppo, numeroRep) ON UPDATE CASCADE ON DELETE RESTRICT,
	 FOREIGN KEY (responsabileRilevazione) REFERENCES Responsabile (codiceResp) ON UPDATE CASCADE ON DELETE RESTRICT,
	 FOREIGN KEY (responsabileInserimento) REFERENCES Responsabile (codiceResp) ON UPDATE CASCADE ON DELETE RESTRICT,
	 CHECK (responsabileInserimento IS NULL || responsabileInserimento != responsabileRilevazione)
	);
	
	
CREATE TABLE Finanziamento
	(scuola CHAR(10) PRIMARY KEY REFERENCES Scuola ON UPDATE CASCADE ON DELETE RESTRICT,
	 referenteFin CHAR(16) NOT NULL,  
	 partecipanteFin CHAR(16) NOT NULL, 
	 tipoFin VARCHAR(20) NOT NULL,
	 FOREIGN KEY (referenteFin) REFERENCES Persona (CF) ON UPDATE CASCADE ON DELETE RESTRICT,
	 FOREIGN KEY (partecipanteFin) REFERENCES Persona (CF) ON UPDATE CASCADE ON DELETE RESTRICT
	);
	
CREATE TABLE Sioccupadi
	( scuola CHAR(10) REFERENCES Scuola ON UPDATE CASCADE ON DELETE RESTRICT,
	 specie VARCHAR(40) REFERENCES Specie ON UPDATE CASCADE ON DELETE RESTRICT, 
	 PRIMARY KEY(scuola, specie)
	);
	
