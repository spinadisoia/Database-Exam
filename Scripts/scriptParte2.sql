-------------------------------------------------------------------------
---------------- SEZIONE 1: Creazione dello schema logico ---------------
-------------------------------------------------------------------------

CREATE SCHEMA "ortiScolastici";
SET search_path TO "ortiScolastici";
SET datestyle TO 'MDY';

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
	 UNIQUE (persona),
	 UNIQUE(classe, scuola),
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
	 CHECK ((responsabileInserimento IS NULL) OR (responsabileInserimento IS NOT NULL AND responsabileInserimento != responsabileRilevazione))
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

------------------------------------------------------------------------------------
--------------------- SEZIONE 2: Popolamento della base di dati --------------------
------------------------------------------------------------------------------------

INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RJRJLB01A99Q418W','Jolanda','Julieze','Brend.Carlos@aol.be','Manager Telemarketin',808875);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HPFQMF68C64X136S','Karin','Stockton','Nick.Massingill4@kpn.nl','Operator Milling Mac',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PYBMTX58T29K331F','Anna','Barnett','LWaldo1@gmail.de','Technologist Exercis',631858);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PWADBE79S64P153O','Mike','Laudanski','D.Leonarda@dolfijn.cn','Operator Furnace',373157);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ITLYNJ30H64A677J','Tommy','Hamilton','Rick.Lamere4@gawab.us','Call Center Nurse RN',983763);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XXOVQF09H92W867I','Mathias','Daniel','Bas.King@dolfijn.no','Technician Soil Cons',501724);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MHBDJZ20A54E342D','Mads','Glanswol','J.Vostreys4@gawab.co.uk','Contributions Coordi',382855);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YEDNFY75D05I878Y','Sally','Watson','Pablo.Mariojnisk@libero.be','Repairer Art Objects',221526);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CTKYLN81L14L920N','Camilla','DeWilde','PeterHaynes4@myspace.ca','Bilingual Secretary',20027);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TWAEXK10B65V343L','Cath','Zapetis','GGuyer3@telfort.dk','Physician Anesthesio',372351);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BPESFM87C80J906U','Nienke','Carlos','FreddyPress@hotmail.it','Retail Banking Head',206916);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MHNAUI93P55G907N','Peter','Pierce','MartinMillis3@mobileme.no','Sports Trainer',911955);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MPPTLK14T98E930T','Edwin','Millikin','Bianca.Sirabella@web.es','Operator Electronic ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZPCVQL60T42E093V','Leontien','Zimmerman','PMcnally5@gawab.us','Sales Engineer Elect',478834);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MKCILE63S38O259R','Jaap','Wooten','Brent.Scheffold@msn.ca','Title Examiner',44319);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SYEABQ62H91J867T','Steven','Vanderoever','Lucas.Lezniak@mymail.net','Prosthetics/Orthotic',226831);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RCQWDF90C38Z130F','Tobias','Gerschkow','JeanJohnson3@weboffice.net','Branch Store Manager',704684);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QGXZQG46H46U046B','Vincent','van Goes','HankGieske@freeweb.co.uk','Radiology Head',408805);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OZTCAY77E56P837E','Duncan','Koss','PMeterson@msn.cc','Cable Splicer',239086);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DUGDON96E35M468M','Thelma','Conley','JakeGeoppo@kpn.cc','Research Mechanic',274354);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HWHJYD78A05J206R','Taylor','Ahlgren','BrentWilson@mobileme.us','Groundskeeper',143445);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CIGMSR12C52J687Z','Peg','Petterson','TonArcher@hotmail.net','Government Affairs D',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VFDSXW86A70U927A','Jean','Ray','Fred.Wakefield2@myspace.net','Surgical Appliances ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GSFQSG55M27P103S','Leo','Wilson','JohanAngarano@freeweb.cc','Analyst Operations R',689831);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SNHFDG01E34I738W','Coby','Thaler','Bas.Stevens@excite.co.uk','Manager Trade Associ',159926);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EZVLIM14E72K858M','Joop','Daley','Nick.Watson2@live.nl','Horticultural Specia',765766);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('USGPZK04P22P361H','Kayleigh','Wesolowski','PLinton3@myspace.cc','Mine Foreman',2566);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UNTDAS08E05B938A','Pete','Paddock','Ciska.Reames@hotmail.dk','Self Service Laundry',269750);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PQQICG99L62T966M','Nicholas','Daniel','Frans.Morton@aol.cn','Educational Speciali',941498);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VEKMMM46E13K721J','Sem','Deans','RichardZia3@telfort.nl','Help Desk Supervisor',370308);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RHQJQA48H59N963E','Toon','Richter','R.van Dijk@kpn.no','Nursing Shift Superv',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LLSIOT00A46Y603P','Piotr','Katsekes','K.Herrin3@msn.dk','Supervisor Drafting',131389);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TYTKZS94M44N601N','Sara','Freed','L.Byrnes@mail.es','General Manager Farm',794078);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VUCVZA00D23E710F','Henk','Krutkov','OttoKoss5@mobileme.de','Generic Engineer Mat',388451);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ADSUZW22M83H172G','Sofia','Koch','Paul.Gunter5@hotmail.gov','Hotel Food Counter W',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZJJRHE06D54X996R','Nick','Morton','E.Foreman2@myspace.nl','Assistant Porcelain ',918882);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HGNNHB87R47G587G','Tony','Clark','T.Langham@live.cn','Nanny',829606);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SVERND99H27D626H','Peter','Chapman','Nadine.Gerschkow@hotmail.cn','Clerk Health Unit',659203);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LLXCBI03E94F888H','Izzy','Brown','Hans.Chwatal2@excite.net','Director Management ',535210);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CWROAP61R21G894A','Pauline','Hancock','L.Anderson@mymail.cn','Maintenance Worker C',98964);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SXOOVE82H14M227W','Jaap','Trainor','SjorsThaler@freeweb.fr','Helper Kitchen',816533);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IBPIIS16E50O122J','Jeffery','Ionescu','Johan.Pyland2@mymail.us','Supervisor Advertisi',649067);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QYKZIA13S35G923M','Theodore','Otto','Stein.Hollman@kpn.no','Classification Analy',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IFZZVR08H34J375A','Bess','Nahay','Bas.Angarano@mymail.org','Protective Signal Mo',796104);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GDIZKF33D33Z212R','Agnieszka','Mulders','Martin.Schubert3@lycos.be','Veterinarian',835080);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TXEKTR60B74R399C','Scott','Anthony','I.Long4@yahoo.be','Numerical Control Pr',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GVRFRO88B93Q110L','Dirk','Boyer','HMoreau@telefonica.cc','Interpreter',415166);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PDGYDI95H19C008T','Lauren','Ladaille','J.Evans2@yahoo.no','Securities Analyst',930445);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VIXGNY79C99K162Q','Nathan','Johnson','Carla.Korkovski2@web.dk','Warehouse Director',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('POFAUL73R21M686T','Ainhoa','Davis','T.Zimmerman@live.dk','Regional Sales Manag',783567);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YDXFER68B90N677R','Marie','Gonzalez','Royvan Dijk@kpn.nl','Hydrographer',982085);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VAKUUK52R13Y681L','Luis','Huston','HAnderson3@web.net','Attendant Nursery Sc',816982);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UXQJHN86L68Y652B','Gerrit','Antonucci','Peter.Sakurai@gmail.org','Mental Health Manage',570937);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KLBKCR23R16G578G','Sarah','Chapman','Gretsj.Novratni4@libero.ca','Supervisor Governmen',862384);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EUSXAI31R82F500W','Sammy','Moon','VictorDeBerg@mymail.de','Administrative Secre',356500);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BMGAWK81C56O667L','Pauline','Wolpert','Will.Weaver@yahoo.net','Medical Optometrist',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NYUTPY28S42L041F','Francisco','Bitmacs','ADonatelli@lycos.co.uk','Scheduler Production',772252);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CDLQUM55D23A481N','Lewis','Green','AnnWaldo@msn.de','Soil Conservation Te',515622);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GNQIPV41C92S688V','Jacob','Schmidt','Jack.Sanders@live.fr','Technician Camera',647525);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JLHVLT35A01P919J','Olivia','Zapetis','E.Scheffold@aol.us','Auditor Top',763696);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BMITZK18S13T141H','Victor','Ditmanen','VictoriaCohen@myspace.gov','Representative Help ',460398);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QLXRXG54A48T133B','Lukas','Donatelli','BrendGriffioen@weboffice.be','Doorkeeper',740016);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RTZRWN20M34F635Q','Christian','Kuehn','Dan.Petterson5@hotmail.us','Electromedical Servi',471257);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UDHAKN85P14Z664D','Cristina','Cramer','Frank.Allison@mobileme.es','Director Financial A',711675);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MGOLCJ58R62J571P','Sara','Bergdahl','S.Byrnes@mymail.cc','Aircraft Pilot Jet',395333);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FPPJNP78E81M319E','Ivan','Daley','S.Glanswol@mobileme.us','Medical Home Care Ai',297434);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ADKDPC44S10T588T','Gerrit','Herring','G.Newman1@weboffice.it','Quality Assurance Ma',653700);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RXZXTA02L66T325Q','Nathan','Bruno','ICramer@freeweb.cc','Supervisor Accounts ',933038);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RAMPOM62R38E174X','Eleanor','Mitchell','JohanKnight@yahoo.net','Lawyer Patent',175868);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DVGXMF54R52V200B','Shermie','Brady','HByrnes3@hotmail.ca','Community Health Nur',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PCIHOZ76P49W836F','Netty','Whitehurst','Trees.Haynes5@libero.net','Computer Programmer',433153);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DBMQPW89T10B807U','Luka','Moreau','HansHarder2@telfort.net','Electric Tool Repair',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZIWHNM51P40R797R','Isak','Hardoon','B.Petterson@excite.de','Librarian',183606);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SKVWPI00H48H828A','Hiram','Goodman','J.King@telefonica.org','Director Food Servic',38268);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JEKHSI66P11M866Y','Mick','Pengilly','IForeman@lycos.net','Surgical Nurse',290648);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GCOOFM21A70V473C','Steph','Brisco','K.Comeau5@kpn.us','Mechanic Farm Equipm',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PZHARD93B71X659S','Victor','Stewart','MNaff1@dolfijn.ca','Radiologist Therapeu',930680);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KYLNSL68L65I193K','Madison','Lezniak','YKeller@libero.org','Helper Construction',579164);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('POWHYT21H69E521J','Leon','Emerson','VictoriaSharp5@myspace.it','Physical Metallurgis',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JIADQX52C68I147C','Stephanie','Goodnight','Maddy.Anderson@aol.net','Surgeon Neuro',645224);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AOBIZC87M39V879F','Iris','Brennan','Mattijs.Sharp4@mail.org','Technician Film Labo',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FITAWM79S90C738T','Sophie','Ecchevarri','Bill.Love5@mail.org','Information Technolo',168773);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QLBFSW34R89Y771O','Sylvia','Poole','Mattijs.Guethlein1@web.no','Temporary Agency Cle',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('USWSPF17A97E059N','Samuel','Lee','Hank.Wolpert@kpn.nl','Hematologist',105818);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HDPRTE47T00B859N','Duncan','Julieze','YDurso@telefonica.us','Exercise Physiologis',141502);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UMBQGR64L36R352M','Dave','Cappello','KChwatal1@live.ca','Aircraft Mechanic Fo',567747);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MTGJPQ57E19K817Q','Babette','Brylle','George.van Dijk4@telfort.cc','Hemodialysis Technic',217664);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EIFCFQ06R99Y853B','Susan','Miller','D.Guethlein@hotmail.com','Administrative Servi',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GTSBWT13S08W565R','Cameron','Huston','LynnKuehn1@freeweb.org','Security Systems Con',295594);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KPXSSA26E91N468W','Alice','Ditmanen','DavidLannigham2@myspace.de','Education Admissions',193631);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YFAMBM87D51W928X','Maaike','Cain','LucyLeonarda@telefonica.us','Wire Drawer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JVQIXY69H07Y804S','Tara','Roche','P.Ray@hotmail.com','Computer LAN/WAN Adm',260307);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BXGYPU51T06R957G','Henry','Schubert','Will.Little@web.org','Taxi Driver',217155);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UMJVNN73C87W482I','Maggie','Schubert','GeorgeVan Dinter@telefonica.cn','Manager Internal Aud',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MFZPSP07S59U629L','Edward','Seibel','FransScheffold@gawab.com','Service Manager Auto',571917);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OBDJWF30M46I298U','Agnieszka','Mariojnisk','RFreeman5@lycos.us','Order Clerk',254530);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MHZHSU51R26D705V','Ron','Robinson','TDeBuck@freeweb.de','EMT',905270);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MFGTSG52P48C818U','Mike','Clarke','EmmaGoodnight@mail.com','IT Computer Programm',84644);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YBBCHG66B88Z526R','Sanne','Guethlein','M.Malone@weboffice.be','Cargo Services Super',919768);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FBHHWG02C17G263A','Andrea','Scheffold','LDaley@mobileme.no','Optical Lens Inserte',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VPYDDV73E99G739N','Susan','Koch','PabloMariojnisk5@live.gov','Radiation Therapist',599793);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KOCRYQ53S04Q003E','Alice','Framus','A.Julieze3@hotmail.gov','Engraving Press Oper',245005);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CIMYYV14H98P964O','Paul','Lawton','MandyNaff@mail.co.uk','Repairer Aircraft Bo',83853);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ACKBPT54H46Z283F','Lia','Buchholz','Kim.Jenssen@mobileme.cn','Veterinary Assistant',646434);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LWKBUM61B32Y646T','Netty','Wong','Brent.Forsberg1@gawab.be','Medical Top Support/',643651);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BNJEJX14B66R915T','Leon','Suszantor','KylieBarnett1@freeweb.com','Crane Operator Trave',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EJJTUQ24E47W140M','Sherm','McCormick','T.Brown5@hotmail.com','Clerk Accounting',492230);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TUOBVZ62D63U612T','Esther','Raines','TreesIonescu2@gawab.us','Helper Carpenter',927899);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PPOCMF71L60F617O','Rick','Daniel','H.Van Dinter@myspace.no','Manager Customer Ser',626194);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VKRVHR71R56U730E','Delphine','Toreau','P.Hoyt3@gawab.com','News Librarian',135113);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PNLNMX26B97Z627V','Fons','Lee','Hans.Miller4@lycos.gov','Attendant Checkroom',362528);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WLNDXV91T54V205W','Luke','Langham','YWakefield5@live.no','Embalmer Assistant',417370);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VDZHBU12T54R195K','Charlotte','Gieske','S.Chwatal1@live.ca','Environmental Engine',628297);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PVFSGI29B24V602R','Frederik','Weaver','George.Thaler1@dolfijn.com','Analyst Economic',320907);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HAMUOD62L71Q827H','David','Prior','BrentPrior@lycos.dk','Life Underwriter',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RIVXEF86T49E439S','Jose','Kepler','Peter.Anthony5@mymail.be','Computer Lead System',946983);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DDBZKQ04P86X396V','Rachel','Love','Jim.van Dijk@mymail.fr','Research Analyst',381759);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YKPIFV46B88B691F','Cees','Julieze','G.Brumley2@mail.no','Manufacturing Top Of',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JYXWLG02L32H427R','Ashley','Bruno','Bianca.Williams5@libero.us','Associate Professor',967512);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BEODZY95R95J641G','Isabel','Roche','Hank.Griffith@mail.ca','Quality Control Top ',766011);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SAWAPA27E40B270N','Ted','Guyer','Fred.Daughtery4@weboffice.cn','EDI Administrator',583223);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TBICNR11E53H203J','Amy','Mejia','Brent.Caouette@telefonica.gov','Supervisor Facilitie',129060);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UYAFJH59B69Z431Q','Mathilde','Stevens','NigelMaribarski@gawab.cc','Writer Specification',55665);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HZKKFI53P78T698H','Syd','Morton','Fred.Zia@dolfijn.es','Secretary Legal',597856);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JOASUU28E49J051A','Helen','Braconi','TTurk@live.no','President',336857);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HXGKPE26B99R705N','Lizzy','Antonucci','Peter.Pearlman@dolfijn.co.uk','Third Highest Paid E',429530);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IROBBR31L05A124H','Koos','Crocetti','RogierCooper4@kpn.de','Upholsterer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GNBDSL44M73D059M','Nathan','Leonarda','TonImhoff3@excite.net','Executive Chef (Hote',23035);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LOOVTD68P73G143R','Julia','Van Toorenbeek','Mattijs.Framus@web.de','Horse Exerciser',223770);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QOORAY32T53A040Y','Liza','Zapetis','BrentRoyal3@mobileme.co.uk','Copy Machine Technic',582429);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CQPCSJ68D54G047O','Filip','Forsberg','YPetrzelka@freeweb.dk','Materials Scheduler',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OGECZF66T21M669T','Scotty','Mitchell','Mattijs.Zapetis4@gawab.ca','Home Therapy Teacher',368616);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VJRBUI50M48G059K','Piet','Mcgrew','WilliamStewart@mobileme.us','Scientist Animal',209280);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IUMCLY91P27K170W','Martina','Hulshof','BrentRay@hotmail.org','Actuary (Enrolled)',164431);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NXCTUB28M29E937K','Agnieszka','Moon','E.Vostreys@web.be','Associate Professor',629066);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZXCDIA24R64T772U','Eleanor','Brown','Ton.Stevenson@hotmail.cc','Installer Muffler',443905);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XQOTPQ07R92H554Y','Mick','Lejarette','Ronald.Francis5@dolfijn.dk','Supervisor Market In',50747);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WSRDMZ04E83N318C','Sally','Novratni','George.Ladaille1@hotmail.de','Elementary School Te',160683);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RODVWM75P88W450D','Charlie','Sharp','EStevens@gmail.nl','Clerk Stock Transfer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QHBVBY64L39P313M','Emil','Ratliff','Bill.Slater3@excite.be','Superintendent Const',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CTOHLH05L93K955O','Stephen','Cantere','BrentDean@msn.cc','Hand Packager',976507);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FVLCMM15C62A418H','Kimmy','Wilson','P.Linton@aol.it','Extractor',525910);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IFNMQK81T24B695R','Joshua','Jessen','V.DeBerg3@gawab.it','Manager EDP Audit',690316);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NZQFPM79S43V809D','Delphine','Seibel','GWilliamson3@freeweb.de','Insurance Claims Pro',104202);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NNKIWK73A30P895R','Zofia','Caffray','BrendToreau@telefonica.ca','Medical Pulmonary Te',611668);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XMWBFK20L88O920E','Javier','Waddell','LRichter@telefonica.co.uk','Supervisor HRIS',650844);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GQJVMS17B24L320V','Elizabeth','Hamilton','BNovratni@aol.es','Manufacturing Servic',638634);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XKDKUO85B04T226A','Nico','Petrzelka','TonCramer5@mobileme.us','Supervisor Accountin',197673);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JKOIAE22L24S697Z','Liza','Grote','Rick.King5@mail.org','Analyst Wage & Salar',508820);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GRSHKW87L60W551Y','Maria','Nadalin','Franky.Johnson@mymail.gov','Technician CAM',573936);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GVMAUG06D47W524K','Ed','Hulshof','ISchlee3@msn.no','Pump Installer',39710);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DHAGYK45C85U562G','Jaap','Knight','MandyBernstein@live.gov','Traffic Director',606470);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KPULLJ02M39P937U','Lu','Storrs','Jake.Reyes@excite.no','Operator Nuclear Rea',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BLRPTA64R13L152F','Ainhoa','Petrzelka','J.Stevenson@weboffice.be','Top Industrial Plant',877029);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TNHPNA50R92H187B','Amber','Williams','MickMairy3@libero.no','Travel Manager',423614);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JAWVKE65A99R548Y','Sam','Deans','Richard.Helbush@msn.com','Supervisor Painting',701268);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZORWID85L20V471J','Cian','Laudanski','RichardPoissant@gawab.it','Operator Chemical',384107);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('APXDXN64H69A449N','Lia','Zia','Paul.Caffray2@myspace.co.uk','Repairer Of Finished',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AYILRS72B86I655P','Gillian','Young','R.Shapiro5@dolfijn.no','Soil Conservationist',190273);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DYYQER24D08M437U','Sam','Ward	','YEmerson5@yahoo.cc','Management Configura',640868);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FPLMTB62T20F816P','Thelma','Paddock','L.van het Hof5@excite.cc','Supervisor Computer ',323402);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CYJYIM29B30X556M','Daniel','Krutkov','LynnZimmerman@web.fr','Physical Therapy Hea',863731);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CKZAOU12B48X018E','Jeanette','Imhoff','LynnZapetis@live.ca','Analyst Stress',844771);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MITLLA44M69M750J','Zofia','Koss','Nick.Frega@live.ca','Repairer Medical Equ',953871);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LYMOCC88T55A243Z','Pawel','Hoyt','Will.Moore@kpn.it','Advertising Producti',925005);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WSXBEE79L61V595D','Benjy','Daughtery','PaulineMillis2@telfort.org','Laboratory Superviso',586565);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CGNHRW57L53O893V','Rick','Stockton','S.Mcgrew@telfort.no','Emergency Medical Te',81343);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JXDJFW35H02R860D','Carlos','Dean','JohnAhlgren@telfort.no','Analyst Website Traf',389417);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IUYNHS97E17L161S','Steph','Slocum','C.Jackson@freeweb.net','Expediter',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PUDPHC53P12I059Z','Fabian','Vanderoever','GStorrs@gawab.co.uk','Legal Stenographer',522482);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UAKMXP75E05S955Z','Elzbieta','McCrary','Vincent.Cross@freeweb.co.uk','Aircraft Pilot Jet',964599);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ACNZRQ87A31Z077M','Sammy','Symms','Hank.Perilloux3@live.nl','Manager Assistant Re',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FNCVFP55M81V438U','Leonie','Brown','TDeBerg@excite.gov','Materials Management',5337);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CYBHAR27E08W983I','Tinus','Muench','J.Bryant@hotmail.be','Supervisor Human Res',424804);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YXZYJA79R48M554X','Erin','Brady','JimHollman@mymail.us','Facilities & Buildin',833914);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XNUBVM13A66M723U','Iris','Gunter','ERobertson@lycos.it','Pharmacist',225359);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OWBBAV40P59V792O','Rachael','Watson','Y.Warner1@mobileme.cc','Teacher Adult Educat',410633);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UQHIJJ60S20T115V','Babet','Dean','TonIonescu@telfort.fr','Design Package Manag',339533);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CLBEYY68L69H531O','Harold','Naff','TWaldo@hotmail.fr','Medical Head Nurse',882097);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NZNPSX57D22I283C','Sanne','Laudanski','ESchlee3@excite.dk','Morgue Attendant',536797);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SBUKUN08M80O827Z','Rogier','Riegel','BrentFranklin@myspace.es','Property Disposal Of',573803);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HIDAYF54L44X548C','Rachael','Moreau','PeterOstanik@freeweb.org','Supervisor Nursing S',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TYNTGN43E36A507A','Cees','Ahlgren','HankAnderson2@libero.ca','Manager Bowling Alle',614631);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CDAJOL65E39K017E','Iris','Van Toorenbeek','Will.Imhoff2@freeweb.ca','Neonatologist',630653);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WFXRCN17A35D927K','Sofia','Beckbau','G.Crocetti1@telefonica.gov','Insurance Policy Cha',197215);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EOSDOH22B19A094N','Bram','Deleo','Jack.Schlee@gmail.cc','Quality Control Admi',649123);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OCYVRS58E04A751C','Cian','Muench','Brent.Mejia5@msn.gov','President & Chief Op',424685);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CPWRIZ51T59X772P','Bas','Hoyt','Johan.Watson@aol.us','Avionics & Radar Tec',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LNUEDP89E51D297Q','Mariska','Heyn','L.Wood@gawab.dk','ERP Programmer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NKLIUD53B05L379U','Jessica','Green','DDeBuck1@kpn.org','Manager Real Estate ',667725);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HLZKEG93H55L035E','Filip','Crocetti','R.King4@live.org','Hotel Waiter/Waitres',522464);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HZPVXE62M96Z855V','Wilma','Arden','R.Markovi5@gmail.org','Water Treatment Oper',676867);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YBYGNE75E00Q823Z','Peg','Clarke','A.Meterson1@yahoo.fr','Technician CAM',597144);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LBXWSI91A11T130Z','Miriam','Scheffold','NickDeleo2@weboffice.be','Repairer Pneumatic T',117647);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BGZWDY66C52S629P','Jan','Mairy','IYoung@gmail.no','Drafter Design CAD/C',851014);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JUGZVI59S77B765Q','Piet','Slemp','H.Igolavski4@hotmail.cn','Contract Administrat',6600);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NGTGCD89A47K654X','Leontien','DeWilde','I.Plantz5@excite.de','Teller Receiving',519033);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HEOUSO33S87U856K','Jolanda','Anderson','J.McDaniel@excite.ca','Organ Transplant Coo',288112);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YWQTZI62D97N680Q','Rasmus','Stevens','WillAldritch@libero.cn','Scientist Optical-La',183451);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CXZUNT65R03N452G','Martina','Rauch','P.Hardoon5@live.cn','Cleaner Photo Mask',544698);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JSUJCT96P30Y582J','Juan','Anderson','A.Pekaban2@telfort.ca','Core Drill Operator',543650);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NHDDTK99E07Q766V','Bob','Rauch','WillOrcutt2@dolfijn.us','Building & Facilitie',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EBMXRG57P16Q638Z','Jace','Ostanik','Mandy.Richter@kpn.gov','Waxes Porcelain',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BFBYMO16B63H821B','Elzbieta','Uprovski','Y.White@weboffice.us','Personnel Scheduler',126231);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EHYNMB03T43A732L','Bo','Gibson','Mattijs.Matthew4@yahoo.es','Medical Transcriber',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MMKCTW43B28U615R','Iris','Gaskins','RCarlos3@libero.ca','Telephone Operator C',104342);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BMONSP36S30A680E','Ada','Davis','Brend.Markovi@mobileme.no','Economic Analyst Sen',563996);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ACYPTX60E31R882J','Sjon','Gaskins','NickJones@msn.es','Sales Automobile Acc',439743);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WLFSXW03R42H980R','Babet','Brendjens','FrankHarder1@mail.com','Technician Electrica',520179);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FUNQCH89L54F556K','Daniela','Goodman','Brent.Zia@hotmail.be','Set Decorator',124694);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('THHNLS19A48I153H','Martina','Howe','Nick.Mitchell3@kpn.org','Manager Leasing',535347);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JYWEAS89A26C143Q','Tinus','Ijukop','Frans.Kidd@telfort.nl','Retail Sales Home Fu',807642);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NKQBYK21M51I423G','Agnieszka','Little','K.Huston1@web.fr','Restaurant Manager (',123196);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MDHHOG98A60F753A','Cian','Waldo','TreesBrisco@yahoo.cn','Design Package Manag',499733);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MLRIVQ80P37S393A','Toon','Jackson','Jack.Rauch5@hotmail.org','Writer Specification',869002);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YYQKIF33T51U379R','Raul','Pearlman','Otto.Koss@hotmail.ca','Sales Order Manager',478554);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OTPSEH23T11L743U','Sophia','Foreman','Hans.Cappello@msn.no','Fretted Instrument M',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IOTBCP32A08K606N','Jean','Pierce','D.Mariojnisk4@live.org','Registrar College Or',490373);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AQZORZ37L84L257E','Jose','Miller','GeorgeAnderson3@gawab.com','Real Estate Clerk',602523);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CEYUHP32L12Y330Q','Rick','Kellock','YOtto2@excite.us','Construction Equipme',965876);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QTABQE07T06M721O','Sammy','Williamson','CJohnson@gmail.fr','Minister',609927);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GXMREP35B86Y244Y','Megan','Blount','HansLamere@mymail.cn','Director Pastoral Se',455864);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OBKOAB29R19F091W','Ross','Bryant','FreddyOstanik@lycos.dk','Instrument Maker Fre',892682);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JWWMCW78H23V901D','Leontien','Nobles','PabloPolti@gawab.nl','Sand Molder',112694);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NLGIXU77A58L634L','Iris','Cohen','RogerHummel@telefonica.it','Superintendent Water',77419);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KXNRDN52H33J400D','Bram','Lawton','Fons.Langham4@kpn.net','Top Investor Relatio',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TMXCKT42M84Q353Q','Jordy','Brennan','TonBruno@lycos.nl','Medical Laboratory M',70621);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VFQLSU13R27Y942J','Frederik','Brendjens','GLaudanski@mail.ca','Recruiter Clerk',85890);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XCVFCK66P89F129X','Piotr','Wilson','Will.Wong2@msn.cn','Rehabilitation Clerk',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RPOBNI01L81G697Z','Hannah','Fernandez','TreesRiegel@libero.gov','Maternal-Fetal Medic',227213);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YNTJJE93T68G652C','Teddy','Korkovski','Richard.Nahay@mymail.co.uk','Repair Order Clerk',87818);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PUYJVB91M30T389E','Tomas','Troher','Jake.van Doorn@yahoo.it','Executive Secretary',531148);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NCEVZP09A26S081A','Alba','White','LMairy@weboffice.es','Instrument Mechanic',507942);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VROZBZ73E53P468T','Carlos','Nelson','Frans.Hamilton@yahoo.dk','Surgical Technician',849503);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DAQQOI13M52V300E','Ricky','Brown','Will.Angarano@dolfijn.it','Programming Director',555641);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DLTLKB62T74N098X','Thelma','Moreau','Johan.Overton1@gmail.fr','Generic Clerical Sup',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EZSHLY75M90R324B','Sofia','Nithman','BrentSlocum@yahoo.co.uk','Manager Business Adm',44672);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NXEPXD09R23A220L','Teun','Forsberg','WillTudisco@telefonica.it','Banking Wire Transfe',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SVKBDI94E93E276M','Gert','Knight','Bas.Watson@dolfijn.nl','Construction Enginee',797111);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EIVMFN59L24N916U','Leon','Millikin','TonMcCormick@gawab.org','Reporter',340931);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ESLLIL87P70J591J','Harry','Bloom','Pauline.Guyer2@live.fr','Banking Branch Manag',780722);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NRMTQN41P80Z267V','Chloe','van Dijk','RogerReyes3@live.de','Operator Milling/Pla',745164);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HUVKCZ92B53U833P','Lincoln','Huffsmitt','Petra.Roger5@gawab.com','Materials Supervisor',135552);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZDNCSX56S75Y818Q','Ashley','Friedman','Mandy.Zapetis@mymail.dk','Supervisor Farm Work',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SKQMAK14H52H621I','Sjanie','Cooper','SigridGerschkow5@hotmail.no','Electroencephalograp',857288);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CMYKDG42H86L270D','Jonas','Mejia','FransSeibel5@gawab.us','IT Systems Analysis ',173302);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UITSRF91M86O366D','Liam','Barnett','Rogier.Malone@myspace.no','Repossessor',870194);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ENLXYN86R38Y532Q','Bess','Johnson','MikeBright@excite.es','Manager Legal',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JFMCHC91D85P340G','Marcin','Byrnes','V.Bitmacs@lycos.com','Home Care Aide Super',15406);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WKXWLX43H37M651M','Sally','Storrs','V.Crocetti3@freeweb.it','Clerk Brokerage',784768);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PGWDLB97H50T374A','Jessica','Lee','Bas.Allison@hotmail.no','Utility Worker Manuf',750183);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AQWFPJ89H47S875X','Alexis','Wesolowski','GVostreys1@kpn.it','Labor Relations Top ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VICSAJ35E16Y959J','Olivia','Dittrich','BenLeonarda@weboffice.com','Repairer Line',986287);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KFIWDU79E92K134F','Christopher','Queen','Jack.Robertson@yahoo.com','Medical Social Resea',356730);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HWPGWT25A95Z805O','Christian','Foreman','DMuench5@yahoo.de','Security Supervisor',328818);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PWTFEF04L29J384R','Lucy','Naff','Lindsy.Bernstein3@hotmail.cc','Drafter Design',230961);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZDDLOP88R08N807S','Alvaro','van Dijk','Richard.Brady@lycos.es','Software Programmer',624402);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DKDEKV61D57B428J','Kaylee','Bernstein','Richard.Seibel@gawab.cc','IT Supervisor Qualit',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WUFBIQ64M29A460N','Sjon','Marra','LucyKrutkov4@msn.ca','Quality Control Test',264350);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IWIGEM09R43I654A','Anthony','Anthony','WilliamLong@web.cn','Ion Implant Machine ',713437);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GHQRJE18R68N809T','Catharine','Knight','IsoldeBlount4@aol.nl','Investor Relations C',25474);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UFXUJN78B76F691A','Camille','DelRosso','Sven.Gua Lima@gawab.gov','Molding Machine Oper',937460);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YCECBW17R12G832L','Helen','Mejia','R.Liddle@excite.ca','Help Desk Supervisor',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WVTFBB36B43M790X','Katie','Meterson','Sven.Novratni@yahoo.dk','Food Sales Clerk',742036);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YLSWNC63L54F418U','Tim','Stannard','Frank.Foreman@web.ca','Aide Housekeeping',862463);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UARNAG74P81A834J','Tom','Julieze','Mick.Blacher1@yahoo.it','Photographer Lithogr',436323);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ULSFGE01A49Z210W','Anthony','Novratni','PaulRobertson@weboffice.nl','Dishwasher',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VYCDDM43B18S501M','Lucille','Comeau','BrentFrega@libero.es','Operator Sewage Plan',420564);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YPOFKK83S18J113H','Sjaak','Ostanik','W.Koss@kpn.net','Teacher College/Univ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KRKRCA16P51Y937O','Stephen','Cramer','Frank.Spensley@myspace.es','Clerk Reinsurance',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OGKPTM08P21X629A','Maja','McCrary','SvenKoss1@excite.fr','Maintenance Engineer',774361);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZRHNRC05A56D101R','Adam','Huston','FrankHardoon5@lycos.org','Manager Computer App',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PRYKQY48B09W460E','Helma','Schmidt','REmerson@msn.nl','Hardware Design Mana',52271);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DHEFDH48D53Q301O','Mathilde','Sharp','EricZapetis4@yahoo.gov','Theoretical Statisti',757009);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GGIVOH26B61T847T','Ulla','Petterson','KimPetterson5@freeweb.ca','Consumer Services Co',727247);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KISNYN15T66Q376Q','Lauren','Daughtery','BillAntonucci@web.nl','Central Supply Assis',687164);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ICHSND43R02M473R','Sue','Williams','Mandy.Cross@libero.no','Supervisor Merchandi',607283);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QGHJXD80H94D064E','Ida','Voigt','WBrylle@dolfijn.co.uk','Check Processing Sup',491505);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZUAOSJ65H91A655J','Oliver','Wooten','RickWong4@lycos.be','Chemical Operator',253192);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HIGDEC13D26X751E','Robert','Caouette','KDaughtery@msn.no','Data Security Analys',398692);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YWNDPP38B72L676B','Sem','Riegel','LynnArnold5@aol.gov','Dressmaker',414695);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IKMWDQ55L85M140K','Phil','Vostreys','VincentFramus4@telefonica.it','Investigator Credit',280098);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FRFVCO10H67J243B','Cristian','Pierce','Bianca.Plantz@yahoo.fr','Accounts Payable & R',310657);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JOZZQL12M51U688Z','Georgina','Walker','R.Symms2@lycos.com','Spray Paint Helper',119975);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MGDWNG14P29Q880J','Delphine','Arnold','FonsGuethlein@libero.gov','Ship Master',6739);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KFEEER65R10J729X','Ciska','Heyn','Mike.Glanswol@weboffice.nl','Top IT Officer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TZVBUF90M31K132C','Erik','Mitchell','Hans.Keller4@gmail.gov','Supervisor Chemical ',224159);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LUPPEE41E02W251Z','Amy','Wakefield','Maartenvan der Laar@web.com','Municipal Bonds Unde',34873);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IYSBWE63T37F670E','Gerrit','Mcgrew','Jack.Hulshof2@hotmail.co.uk','Printed Circuit Desi',679407);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZNMNHT51E09E334Q','Maja','Phillips','LJulieze@mobileme.net','Lathe Engine Setup O',621014);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MOFPTZ41D13F159K','Rob','Liddle','HankOyler4@gawab.es','Cartographer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UNRBIY80E55Q207T','Dylan','Wakefield','Ton.King2@gawab.it','Manager Branch Banki',508771);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QYXPZM84M13J040M','Jo','Chapman','JackLezniak4@yahoo.de','Drug Abuse Counselor',9657);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AARYAJ62B59L434Q','Steph','Whitehurst','RickBergdahl@lycos.net','Administrative Engin',339557);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GXLRBQ52R22H389P','Edwin','Braconi','GLee@libero.gov','Head Of Dialysis Uni',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UDSYXG85P53S406L','Klara','Lannigham','PetePensec@gawab.de','Hoisting Machine Ope',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BXVLCR48M31R280J','Francisco','Beckbau','HankGildersleeve@live.fr','Drill Press Operator',490565);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OBPKPA96T04M130B','Rolla','Thompson','JohanLinton@telefonica.no','Kitchen Helper',286186);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KKEDLS01A89J924Y','Ryan','Poplock','Lindsy.Climent@gmail.dk','Lathe Operator Numer',219359);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MXTIQQ95M99T688N','Paul','Wood','PetraWeinstein@hotmail.com','Accounts Receivable ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SCWGKG29S98I092Z','Gillian','Wilson','D.Ionescu1@libero.ca','Recreation Superviso',558670);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BYFINB17C08F334L','Emily','Rivers','E.McCrary@gmail.dk','Engineer Civil',15363);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ONULOO33T25S083U','Geoff','Wesolowski','HManson@msn.dk','Supervisor Personal ',615169);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SITYIX52A94V130Q','Julian','Ahlgren','E.Cappello@gawab.org','Engraver Machine',492510);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PQQGDF28C38G335U','Karen','Tudisco','KimGlanswol3@telfort.gov','Purchasing Manager',696747);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TNFFUN01M68P030A','Edwyn','Buchholz','FredRatliff@live.dk','Assembly Line Forema',296267);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LENKVS31R36A117Y','Agnieszka','Newman','LCain5@lycos.net','Drafter',884230);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZRUPTU91C38B134W','Maaike','Frega','Richard.DelRosso@live.gov','Separating Superviso',411168);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NHFTOG23C58U900N','Miriam','Allison','BillMitchell@mobileme.co.uk','Driver Taxi',989683);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ORWLKE22D77Y256M','Jack','Depew','MartBlacher@excite.no','Travel Accommodation',913365);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TNCGKI80B94X699I','Anne','Nelson','CToreau@gawab.com','Manager Tax',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QFSXOU97E85W806L','Linnea','Guyer','Camilla.Polti3@mobileme.it','Top Real Estate Offi',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CEKSOL20S78X905Z','Magnus','Mcgrew','Y.Jackson4@excite.de','Mining Engineer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ECHAZL92S11E169H','Philip','Durso','AnnThaler5@dolfijn.it','Packager Manual',323730);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YHHFJU81S47T154U','Chuck','Herzog','William.Helfrich2@mail.us','Operations Head Bank',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BBAKDT22S59X345M','Gill','Olson','Stein.Nelson@freeweb.co.uk','Web Press Operator',347270);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BIXWCJ72L16D588T','Siska','Williamson','J.Lee@yahoo.gov','Electric Meter Repai',626921);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PQOYBG21C90O836E','Klaas','Wakefield','William.Fox@gmail.be','Operator Numerical C',169649);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XZCZSZ18S77T619O','Elin','Donatelli','MaddyNelson@aol.it','Technologist EEG',177755);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GWGPOW72R41C077V','Tony','Uitergeest','RicoFriedman@myspace.cn','Beautician',203816);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TYNWTC26B31J899V','Bert','Spensley','H.van Goes@telefonica.cn','Infection Control Nu',942639);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VCQXOL48S94M479H','Ann','Brady','P.Uitergeest@weboffice.cc','Pharmacologist',777169);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SHPWYF64L54T822A','Tobias','Poplock','J.Massingill@aol.org','Funeral-Home Attenda',680065);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OUGMHI56H49A668R','Louise','Wilson','HansHamilton@mobileme.nl','Manager Benefits',420543);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZTUOBQ72M83H037Y','Sergio','DeBuck','PeterWood4@telefonica.it','Horticulturist',728126);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('STFFRR07B60N663L','Ike','Kingslan','Victor.Daniel1@aol.us','Foundry Molder',256839);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DFRPBE63L86B445F','Siem','Hollman','SMakelaar@web.es','Manager Materials Ma',743240);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZPWDXY00R11X468M','Esther','Zurich','Will.Gieske@excite.ca','College/University B',791767);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VQSSFS43E88T107N','Pip','Mitchell','WillChwatal@mymail.fr','Public Relations Top',957618);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DLBBGF71T70D554L','Ed','Wooten','Emma.Wooten@mobileme.es','Repairer Transformer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VNAUAT93E39Y116Z','Erik','Maribarski','D.Noteboom@myspace.no','Vice President Envir',293528);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JJDJIP90E37R716I','Ulla','Anderson','TStannard@msn.co.uk','Analyst Product Desi',737712);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NNIETW74L00T047L','Frederik','Robinson','HansAyers@yahoo.es','Loan Review Analyst',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DWGJPK35T13H282M','Karen','Igolavski','RFramus1@web.dk','Geophysicist',366458);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PFRFQE02C13Z097X','Lincoln','Schmidt','Jim.Hulshof4@gmail.it','Boat Builder Wood',662736);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YZBELR50R31V485I','Peg','Clarke','Peter.Freeman1@mail.org','Production Superinte',600894);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NCWUBI52A35N074L','Hanna','Helfrich','VictoriaHeyn@dolfijn.cn','Supervisor Software ',863579);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NLGQBR99H15J813F','Alva','Botsik','CJulieze@mobileme.co.uk','Analyst Systems',982297);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YLFONI53M78E805Y','Lotte','Hummel','RichardBuchholz@hotmail.net','Online Sales Manager',31414);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WOCEIB07A38J421Z','Sean','Griffith','Freddy.Green2@telefonica.no','Medical Nurse Office',571595);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DAARTL39R51K582S','Victor','Heyn','SBotsik@yahoo.gov','Operator Bindery',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VDJMHS07S03N185E','Jolanda','Huffsmitt','Jake.Nelson@weboffice.cc','Helper General',816602);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FUUGHB03H68Y935J','David','Turk','Ronald.Ahlgren@weboffice.us','Engineer Telecommuni',609205);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PHVSDR31D15X396N','Geoffery','Overton','Ton.Slater@telefonica.es','Market Research Mana',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AVHDDX75C23V720N','Thomas','Perilloux','IBruno5@libero.cc','Programmer Engineer',791127);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JCISOO86T63B087P','Ollie','Laudanski','Ben.DeWilde@msn.org','Computer Network Con',14117);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WUWNNQ84C84T053N','Carla','Kepler','MMuench@telefonica.it','Chief Medical Techno',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZKWCKC73T27L743N','Catherine','Mariojnisk','Frank.Herrin@mymail.es','Director Volunteer S',403581);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SBSCVZ88H79T247S','Margaret','Robinson','David.Lejarette3@kpn.es','Manager Beauty Or Ba',672485);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MKCAFJ64C87L089T','Sjon','Spensley','GStevenson@libero.gov','Attorney Legal Manag',809948);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WSRACG30D87Q543M','Ann','Cooper','R.Cohen1@libero.net','Electrical Appliance',531665);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DUGHNX03R10B114N','Sharon','Harness','HVan Toorenbeek@dolfijn.es','Advertising Top Offi',13701);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YCDKHY11P84H658T','Liam','Pearlman','JackHancock2@weboffice.fr','Water Treatment Plan',635928);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HYHWUY62S30E121W','Nick','Plantz','R.Carlos@telefonica.ca','Plastic Hospital Ass',156745);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IIXPHE06A79I919P','Cees','Overton','D.Cantere@live.cc','Banking Loan Manager',893939);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QCVHNM83C46D718E','Joshua','van Doorn','PaulLangham@web.dk','Medical Respiratory ',914142);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IWNQAF15A96I090A','Cecilie','Dittrich','Ronaldvan Doorn@libero.cc','Top Sales & Marketin',592259);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UQHMVC61T01E035T','Marco','Pickering','Frans.Queen@kpn.net','Storing Laborer',919842);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PVBXQF18L27Q862H','Joost','Sirabella','K.Yinger@kpn.fr','Photoengraver',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KYOCAS99L57F644I','Alva','Millis','Trees.Freed@live.cn','Quality Assurance Ma',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JSMZPM38A34S463Z','Paula','Ladaille','Frans.Wakefield@gawab.de','Officer Compliance',742634);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RAPTSG11M95Z929O','Jose','Barnett','RickLinton5@aol.de','Ophthalmic Photograp',514949);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SPFDKG89B74L613K','Duncan','Polti','YLinton@lycos.it','Buyer/Purchasing Age',593936);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UTMQCJ65S77N221I','Olivia','Wood','Frans.Aldritch3@mail.co.uk','Mechanic Head',762094);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VYUWFK59S84C570I','Fabian','Braconi','Hvan der Laar@lycos.es','Engineer Nuclear Was',178836);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WLSTWC37L91M225M','Nicky','Young','Fons.Zapetis@telfort.com','Construction Enginee',757124);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KCSPTT45H80M487U','Bob','Mitchell','SuzanneRobbins@freeweb.dk','Technician Optomecha',472116);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EHSGNH83L00L186J','Maggie','Helfrich','BasSanders3@mobileme.co.uk','Locomotive Engineer',750361);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BCUIYZ37D11W749W','Luke','Huston','GOlson5@web.co.uk','Telecommunications M',595304);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KSUDZR56H64S726C','Michel','van Doorn','GeoffryBernstein5@telfort.us','Computer Programmer ',661006);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TJIJGH79H43E980J','George','Linton','G.Depew@hotmail.gov','Embalmer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UPEGIJ88E33H514K','Alejandro','McCormick','Hans.Linhart@telefonica.co.uk','Top Manufacturing Of',985919);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UIKLUQ70A41T332B','Pedro','Chwatal','L.Grote@telefonica.it','Reactor Operator',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OWIHEG28C30Z528Q','Barbara','Schmidt','T.Malone@live.org','Programmer Midrange',326810);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YOHYAB12A66B562E','Ellie','Deleo','Will.Hendrix1@msn.cc','Obstetrics Staff Nur',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SQMUHG61R99R378X','Ted','Wilson','TreesRiegel@web.no','Cleaner Building',33220);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OERFSR89M60F713U','Ricky','Allison','Johan.Poissant1@hotmail.gov','Stress Test Technici',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BXAMOR52T37Q492R','Sergio','DelRosso','VincentDeBuck3@telfort.cn','Sales Livestock',688236);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZJAEZR05E48Z384J','Martien','Gibson','Freddy.Kidd@mail.de','Garde Manger',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KFLSXP91S91H350C','Diego','Shapiro','RickKnopp@mobileme.be','Supervisor Advertisi',629491);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LHZAEA50R74X775M','Carlos','Jones','Freddy.Weaver@libero.es','Hotel Front Office M',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RJUGHZ27H03Q066I','Maggie','Wesolowski','VBitmacs4@weboffice.dk','Medical Supervisor P',573197);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SDDOZR36S94T432Y','Mathilde','Gua Lima','MadeleinReyes@myspace.ca','Transportation Manag',961468);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LECCRV97R46X570E','Sophia','Chwatal','MichaelMcgrew4@mobileme.be','Equipment Washer',24314);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FUGFFF00T29U818I','Andrea','Cain','HankToler4@mymail.no','Geophysical Drafter',679352);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OVAJFY59R39S248I','Taylor','Lannigham','G.Anderson@hotmail.co.uk','Head Of Corporate Se',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RNPHEC82R17T583M','Mariska','Johnson','MCantere@gmail.com','Vice President Opera',86992);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MARXYD04A08R003I','Frederik','Kuehn','GRatliff@telfort.dk','Quality Control Test',921786);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LVQCKK86E71E829E','Javier','Chwatal','PPatricelli@freeweb.de','Asphalt Paving Machi',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UBIWQJ10T63I482W','Megan','Mariojnisk','TonGieske@gmail.cc','Pool Swimming Servic',20003);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KPGFXL19M64F606B','Koos','Lee','Hank.Mejia2@web.es','Clerk Travel Reserva',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NKLXNY76R33C804J','Ewa','Love','Bas.Harder@weboffice.net','Plant Chemist Utilit',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VATZAZ84H99H082W','Julia','Malone','Nick.Shapiro@mobileme.de','Repairer Telephone C',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FDNINN76S73B851F','Michel','Bernstein','GRobertson@hotmail.com','Nurse School',451545);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RMKJWE97A04T856R','Sofia','Bitmacs','FredBrady1@dolfijn.de','Spray Paint Helper',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HUVKMU33E85P294N','Isaac','Press','WilliamWarner@mobileme.be','Unix Administrator',669272);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YNAQAP85H24P355D','Herb','Thompson','YOlson@excite.ca','Analyst Occupational',774607);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HMGFUQ05A10O630L','Alfons','Morton','HGonzalez@yahoo.dk','Chipper',955445);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DVQROZ40T06M446E','Leo','Ionescu','Ben.DeWilde1@excite.cn','Supervisor Productio',152359);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZXJUQL56D98A757A','Anthony','Jenssen','TGuyer2@yahoo.ca','Metrologist',974271);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LPSAIB76E96H873L','Jill','Allison','Freddy.Morgan@libero.org','Crop Farmer',330177);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SBSYBU37L36V903I','Nick','Francis','Bart.van Dijk@libero.net','Technician Metallurg',946759);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FMTWGF03R33F545X','Kimberly','Langham','Nick.Chwatal4@gawab.cn','Manager Hospital Lau',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QPGGDX54S16P459R','Helma','Jackson','LHummel@telfort.co.uk','Food Science Technic',59356);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FRQWON52M88E587Z','Karen','Boyer','Freddy.Gaskins@kpn.be','Cashier Associate',324341);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FNDGBX56A22T957C','Chloe','Seibel','TDuvall4@mail.us','Product Design Engin',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BBZTSU69S87S535L','Sharon','DelRosso','Johan.Ray@yahoo.fr','Aircraft Sales',994316);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FBZTJH76R76E814F','Diego','Symms','Bas.Green@mail.be','Document Preparer Mi',238911);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LMTIYF82B90V507O','Hiram','DeWilde','BasPlantz1@mymail.gov','Therapist Recreation',842327);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DRGPXP22E44K326A','Will','Cantere','Bill.Bergdahl@yahoo.us','Drafter (Moderate)',837794);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QSKVKE87R26D606V','Elena','van der Laar','Matt.Gonzalez@msn.de','Investor Relations M',944348);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FUVJIJ70S86T792L','Chris','Wong','Bas.Harder1@mobileme.net','Operator Reactor Tes',563853);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EAWCEE83L85A767O','Marco','Bruno','FredRaines2@hotmail.org','Hotel Waiter/Waitres',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BSSNQD26C42Q685S','Hannah','Manson','Y.Harder@mail.gov','Desktop Publisher',436410);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DXDJYL23P22F453C','Alba','Fernandez','TreesKing1@mobileme.ca','Admissions Clerk',616336);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GREJOX43C04Z954A','Liza','Cain','Bill.Aldritch5@web.dk','Consumer Loan Manage',90803);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BDROMI19A41U683J','Alfons','Voigt','Johan.Poplock5@mobileme.org','Unit Clerk',588192);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UNXLMV78E18P679I','Anthony','van Goes','Freddy.Pyland3@hotmail.de','Radiologist Diagnost',68593);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OMPLQB84B21N785U','Ricardo','Brylle','JohanWargula@live.us','Vice President Adver',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SZFNVP26C82X170Y','Vincent','Bloom','Y.Pearlman4@mail.net','Analyst Methods & Pr',873021);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HJUZYA67S34C934O','Netty','Browne','R.Anderson3@aol.net','Head Of Lending Bank',161179);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IDXHEZ20S95D983U','Sammy','Hopper','LMatthew@weboffice.co.uk','Medical Occupational',313672);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NOPZWM10L57C104P','Nienke','King','Gretsj.Gonzalez3@hotmail.be','Technician Quality C',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ADKOSV04L76P949U','Krystyna','Leonarda','Brend.Marra@kpn.de','Civil Engineer',253850);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UGFXSX87R22L825Y','Caroline','Crocetti','T.Nefos3@gawab.co.uk','Designer Controls',167741);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MSIUKV39A91R810W','Jean','Walker','I.White@hotmail.gov','Technologist Cardiop',208927);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KCVQBU11E24O731F','Tim','Conley','RichardGibson5@kpn.net','Representative Veter',67974);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZJEEZN40E77S443P','Ewa','Dittrich','Freddy.Raines@kpn.net','Air Conditioning Tec',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BCCRZI60R25X784Q','Nicolas','Chwatal','G.Whitehurst@mymail.net','Supervisor Home Care',634736);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VUXCQP48T38W432A','Jo','Evans','Maddy.van het Hof@yahoo.it','Vehicle Maintenance ',487022);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OBIQUY72S87Z437E','Jeanne','Millis','Bas.Slocum3@dolfijn.be','Operator Boiler',373328);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MZTQBQ69L45T568E','Edwina','Zia','LStorrs@yahoo.it','Powerhouse Electrici',3054);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VVGSMK04T85W450T','Isabel','Sanders','HansCappello@libero.us','Coordinator Logistic',475165);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GFHEYH58D99D372K','Amy','Kidd','Kay.Botsik3@lycos.nl','Assembler Electronic',391923);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DWVTYC88B25B158A','Tinus','Fernandez','KHuston@myspace.dk','Clerk Job Order',838531);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GCWEXT27T71N331V','Steve','Sirabella','D.Langham@gawab.gov','Machine Shop Milling',179376);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EEOQXA37A81R904T','Barbara','Frega','D.Goodnight4@excite.be','Generic Engineer Mat',579662);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SYXBSY23R47M674U','Leon','Richter','SSchmidt3@libero.es','Supervisor Shipping ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KUOKUY06E75S515F','Ester','Miller','Freddy.Fox1@aol.it','Design Engineer',828669);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YRGIQZ20E58T970J','Luca','Laudanski','Kim.Jenssen5@freeweb.cc','Truck Driver Van',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KLQMBE17B78U195A','Talitha','Liddle','Rick.McCrary5@libero.net','Customer Service Rep',401556);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GBYTBO56A23M979S','Drew','Ionescu','N.Meterson4@myspace.com','Real Estate Appraise',826032);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LMEYPJ78R70A512G','Cath','Buchholz','Frans.Ray@aol.gov','Optical Lens Inserte',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LWEWAE40T80K641P','Freja','Oyler','JohanPrior2@gmail.dk','Clockmaker',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UZIRDR86D55J895Y','Siem','Clarke','AKorkovski@mymail.com','Clerk Bank Disbursem',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KZFREO96E55B120F','Martien','Plantz','Roy.Ladaille@aol.net','Physician Anesthesio',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MFOPXB14R92D338G','Samantha','Slemp','GOlson@telefonica.ca','Chief Legal Officer',255723);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XPIHWF45M73E358W','Claudia','Aldritch','R.Waddell@kpn.ca','Installer Molding An',889952);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GPFZCF60C66O977L','Dick','Bergdahl','BrentShapiro3@gmail.us','Banking Teller Loan',300337);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WZTFOS68S26X837Q','Zoe','Allison','WillOtto2@mymail.be','Iron Worker Structur',564237);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MRBWBB83A19F922N','Ciara','Nahay','Sjors.van Dijk@kpn.org','Test Mechanic',311312);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FIVXMV70A58H021D','Elin','Matthew','RChapman4@kpn.dk','Employee Relations S',213955);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TJZSZG76E25P535P','John','Anderson','Bill.Stewart@libero.be','Structural Assembler',634444);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CULGDV89E00G716D','Marie','Dulisse','Will.Imhoff@live.be','Medical Admitting He',205538);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JUBYUT62C90M521L','Marty','Mitchell','DaveEcchevarri@weboffice.dk','Manager Fast Food (S',849384);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UPUPZH14P03F272W','Sara','Storrs','IPoplock@aol.net','Engineering Manager ',518713);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WJHGZM76D47M141R','Janet','Kingslan','Bill.Evans5@dolfijn.it','Physical Therapy Aid',345323);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ACXEYB74M02B214W','Daan','Jones','MickArden5@kpn.es','Glass Blower',200901);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GQQMHG67C94L985Y','Suzanne','Hollman','Johan.Deans@live.com','Planning & Developme',55994);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LVOVDM46D63C251I','Anton','Mcnally','Peter.Seibel@kpn.nl','Respiratory Therapy ',252359);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BAPUBE62E18I522Y','Eleanor','Keller','Ton.McDaniel5@mobileme.cn','Supervisor Operation',442005);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JCOAJM05A53C580H','Joey','King','CiskaLawton5@telefonica.no','Attendant Morgue',853806);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HIXCLW36T35Q493B','William','Harness','Maddy.van het Hof4@aol.fr','Clerk Wire Transfer',582927);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VTCOJL70R28K853H','Margarita','Blount','VictorWood@myspace.cn','Bail Bonding Agent',181283);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GYBAYI72L35A985A','Chloe','Gaskins','EThompson@telfort.gov','Clerk Utility Locato',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IJZYZO41D01A598Q','Dylan','Gildersleeve','Dick.Roger1@mail.es','Vice President Labor',464518);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VJQGMI04H73T104T','Christa','Herrin','Frans.Moon@weboffice.fr','Security Aide',282165);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VENFIK90P80W495C','Samantha','Wilson','Sven.Gua Lima3@mymail.co.uk','Operator Lithographe',122473);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LKPNWO11L67T566A','Maja','Schubert','Frans.Freed@kpn.cn','Clerk Purchasing',74526);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AVXRMN75M63V667Q','Babet','Ionescu','J.Hendrix5@telefonica.it','Coordinator Hospital',396134);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LBKPZM19M60E859J','Lewis','Langham	','Nick.Press2@libero.co.uk','Cost Accounting Supe',455562);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SXEFGS51C20T317H','Liam','Bergdahl','LeonIjukop@mymail.ca','Infection Control Nu',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OVIIKX53D12J898M','Jonas','Brady','R.DeWald@mymail.com','Anesthesiology Nurse',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MZFMWY82C03T459F','Leon','Stevenson','Mandy.Goodnight@myspace.it','Operator Audiovisual',667908);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XNUFKK16D14N208S','Margaret','Blacher','Will.Angarano5@libero.net','Patient Representati',989609);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PUGMIG80D57M756I','Joop','Nithman','G.Katsekes@libero.es','Graphic Design Super',925579);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NFJHNA04B61M155U','Lewis','Wilson','Peter.McCormick@mymail.us','Assistant Estimator',78602);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SYVXDM46E52X208U','Pablo','Ditmanen','VGuyer@lycos.de','Physician Assistant',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EJGCHN45L22M654T','Mike','DeWald','MaddyAnderson5@kpn.net','Hardware Analyst Com',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QBIQWN81B40V010Y','Jessica','Deleo','RichardMayberry5@telfort.cc','Drafter Utilities',16620);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KKOJVP65L54B920J','Nicky','Prior','HankDeans3@live.be','Mechanic Maintenance',877337);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PPCFXM76M70H879C','Jaclyn','Sterrett','Petra.Brown@kpn.net','Abstractor',953133);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UGSDUB98B16S991E','Bess','Olson','BasWaldo@telfort.ca','Transformer Rebuilde',174997);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MKMNTD65A07I977R','Erin','Thompson','E.Mitchell3@mobileme.net','IT Director',156793);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BZCYSJ76P13W902O','Ellie','Brown','Geoffry.Daley@gawab.gov','IT Supervisor Applic',222716);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ESYVVL33P21R074B','Wilma','Goodman','WilliamSirabella@libero.be','Criminalist',578306);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HPLLJH84S62Z101B','Cameron','Allison','MartinPraeger5@libero.no','Plant Accountant',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OKSWRK09C41J510A','Co','Dulisse','Brent.Ionescu@kpn.no','Master Control Engin',958347);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DRCZBA81B58P386T','Piotr','Moreau','Y.Miller@dolfijn.dk','Medical Pharmacy Tec',771890);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HIVXKK57R67L786W','Jo','Vostreys','Kay.DeWilde4@myspace.ca','Technician Film Labo',719088);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EMNGOR73E75J056A','Sean','Frega','Maarten.Hulshof@excite.nl','Electrician - Certif',653041);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VHLIFZ32R02P902Y','Gert','van Goes','Ann.Thaler@telefonica.co.uk','Operator Apparel Tri',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PBSSWF40P23B889B','Nigel','Langham	','HAntonucci5@mail.it','Collection & Credit ',690629);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QBXTYY61R97W971P','Nate','Brown','PierreSchmidt@kpn.be','Operator Optical Eff',645736);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SDOPDX28E21I874V','Patricia','Forsberg','MickArden4@yahoo.no','Auditing Manager Int',617997);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZFWILT28M85E644Y','Caitlin','Friedman','T.Braconi@myspace.gov','Planning Manager Lon',817051);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SOBYVC05D29Y278I','Mathias','Thompson','BrentHaynes5@kpn.nl','Hotel Room Service C',765681);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SBECEP64T32N165L','Isabelle','Brisco','Fred.Kingslan@msn.ca','Building Cleaner',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SIJXHZ14L70B629M','Sjanie','Linton','FreddyOverton@mobileme.gov','Estimator Printing',738382);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GQGLTR82E52Y879D','Herb','Heyn','Bill.Moreau4@myspace.net','Producer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WDSZBI07P29P574J','Ton','Thaler','RoyHancock@myspace.no','Saw Filer',503926);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IBQBXB48S65W355K','JanCees','Polti','Rick.Comeau3@aol.ca','Deaf Interpreter',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BCPOZS18T02E005U','David','Waddell','Rogier.Goodman@gawab.no','Desktop Publisher',328660);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('SWFZIN93E55W683J','Siska','Riegel','BrentOyler@hotmail.us','Closer Real Estate',429525);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RGVLQL93L74X239R','Joshua','Igolavski','H.Aldritch@aol.nl','Skip Tracer',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HDQETU67L40E962I','Coby','Wesolowski','JohanDavis3@aol.be','Precision Lens Techn',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FAQOWQ55L81L122Q','JanCees','Bogdanovich','Richard.Wesolowski@msn.nl','Insurance Claims Cle',620646);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IVRWEL82B01D683Z','Harold','Malone','BillGaskins@aol.dk','Hairdresser',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VOYTWM47A99R045A','Babet','Hancock','Fred.Slemp@libero.es','Knitting Machine Ope',151319);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HQNSYI80T02Y137V','Dave','Moore','NickSlater2@gmail.be','Machine Shop Tool & ',205036);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UYJBJK29D03T380V','Rik','Phillips','H.Zurich@dolfijn.co.uk','Manager Operations',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YTYAMU97A46E131B','Edwin','Moon','YBryant5@telefonica.nl','Rolling Attendant',923276);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KZPBXK89D00G322J','Lucille','Byrnes','GBergdahl@aol.co.uk','Mental Retardation A',476229);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TADESN27R36I084D','Klaas','Antonucci','Rick.Anderson@kpn.nl','Manager Supply Chain',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YVEYZH88P58S539I','Sandra','Rauch','TonGreen@lycos.de','Technical Sales Medi',503721);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CDZRWL21E21L928D','Peter','Lannigham','M.Goodnight1@libero.gov','Research & Developme',502262);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HBQRIY13B28R854C','Lucia','Anderson','BVisentini5@aol.de','Drafter CAD/CAM Desi',19495);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WZNLTW84H93V637F','James','van Doorn','R.Stewart@excite.cn','Modeler Clay',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CUMCBU33D14N421V','Mart','Laudanski','SuzanneSchmidt@live.gov','Medical Optometric A',266215);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HNEOPC74M41H090J','Geoff','Queen','HankSakurai4@mail.cc','Installer Solar Ener',159239);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OAYYMJ62A74P806S','Sem','Wesolowski','LindsyWhitehurst1@telfort.be','Banking Branch Manag',560345);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FUBIQA06C78Z544R','Mike','Wicks','LiamGlanswol2@weboffice.dk','Disaster Recovery Pl',775801);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AIRAEC90R22Q199R','Lena','Framus','Nigel.Pekagnan4@kpn.co.uk','CAM Machinist',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HFZQVA33C42J361X','Lizzy','Arnold','PeterWarner@freeweb.co.uk','Flying Instructor (G',69045);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XSSQVV09B63T781K','Marco','Antonucci','GKellock1@libero.ca','Engineer Chief Hospi',179189);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ASOPAU50M19N127C','Babette','Zapetis','I.Moon2@mail.ca','Manager Warehouse',217751);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JWKQEI80H08T627O','Anna','Framus','GLee@telefonica.nl','Renal Dialysis Direc',836419);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IJAODN34L49K497J','Jordy','Brown','MandyKatsekes4@web.nl','Long-Range Planning ',984335);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WQJFZS29B30F384N','Emma','Frega','Peter.Freeman5@web.ca','Employee Services Su',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AREBRK59C85B308Q','Kees','Korkovski','SvenUitergeest5@libero.de','Hospital Top Support',227142);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FLEWSZ24E41S697G','Matthew','Antonucci','BrentAllison1@weboffice.org','Tax Attorney',833640);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CEXGTZ27R73C819B','Mathilde','Toler','Ann.Millis3@mymail.com','Operations Head Bank',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GWZSKW07M24X874F','Sem','Wicks','Trees.Oyler1@lycos.es','Computer Software De',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CQNFUH70M36W102R','Izzy','Freed','SteinWaldo@msn.es','Software Design Mana',691383);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NQYHSW64M60L677U','Sylvia','DeWilde','MartinGoodman@web.cn','Safety Consultant',856574);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XXPAFO70D05E292U','Sophia','van der Laar','E.Wilson@yahoo.de','Operator Cutter',101207);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ESZQZZ09D31W970M','Charles','Durso','J.Harder4@mobileme.fr','Top Internal Auditor',266074);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VEQCNK08P55O841W','Maja','Brady','Lynn.Cantere@mail.nl','Accounting Technicia',611233);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LUSWRP51H11V962N','Ron','Long','Johan.Cragin4@live.de','Right-Of-Way Agent',569103);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TRMLJC07R43H384T','Olivia','Cross','SteinReames5@lycos.gov','Web Developer',21930);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HBHVJY86R91D633P','Emma','Helfrich','Madeleinvan Goes@mymail.ca','Superintendent Plant',509731);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JURXJH67H79X224T','Taylor','Jessen','Carla.Ditmanen@dolfijn.nl','Supervisor Cloth Fin',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QQGDLB44C74B817K','Manuel','Helbush','WillFox5@telfort.it','Clerk Data Examinati',70419);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QIHZTY82E85G323P','George','Frega','NickTroher3@gmail.gov','Diet Clerk',737474);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PBEXAU60A02A222S','Jules','Maribarski','BJenssen@telefonica.cc','Operator Sewage Plan',428892);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('APJUXR14L01D262C','Betty','Davis','T.Duvall@mobileme.us','Animal Warden',323946);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WSNGHH21H53M052X','Isabelle','Otto','Bas.van Goes@web.com','Operator Master Cont',61841);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BLHUCY19S90Z040E','Manuel','Nahay','ICramer4@myspace.dk','Retread-Mold Operato',553115);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('NUXIDX26E84H192V','Krystyna','Hancock','Peter.Angarano@yahoo.org','Checker Engineering ',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BQHYVW24L56N250P','Pete','Spensley','Johan.Symms@aol.net','Loan Clerk Installme',698432);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ANUCUL07B51G267Y','Vanessa','Noteboom','Agnes.Suszantor1@telfort.co.uk','Operator Camera Head',863115);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZTZDJT19S05R691W','Catherine','Griffioen','JackFrancis1@live.no','Medical Technology T',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('DOWLFE44C83W591C','Pauline','Harness','LeoGeoppo5@hotmail.es','Buyer Grocery',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WDRYDA75H51Z155N','Saskia','Schmidt','HPekaban2@aol.be','Structural Drafter',90624);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('AEAHEZ61M05M459K','Nicoline','Knight','DanaBitmacs3@lycos.cc','Aide Recreation',941423);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EMOMQY08T59B476K','Ricardo','Symms','JohanNadalin@live.cc','Data Security Analys',64073);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RXCAEQ20E85F846P','Erik','Thompson','JForsberg@hotmail.nl','Driller Well',662489);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EMKHLS99M95F717L','Sigrid','Lee','Hank.Wong@lycos.nl','Clerk Loan Banking',687396);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TJFJRL75C86G381Y','Steven','Vostreys','Will.Stockton@yahoo.cn','Coordinator Work Stu',708774);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GYPSYM11D44H235L','Pablo','Love','MikeBotsik5@freeweb.it','Utilities Superinten',523926);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('OYDIWK43B56M872V','Joanne','Phillips','Maarten.Mulders@libero.no','Insurance Benefits C',133809);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JKAKCA02T72X134S','Lucia','Wood','HankLinhart@lycos.net','Operator Sawing Mach',152109);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XNVESI09S75D299G','Philippa','Daughtery','RickHaynes@lycos.de','Insurance Rater',522517);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('EYXRMW10H82X677B','Jules','Reames','Johan.Kingslan@live.de','Advertising Clerk',61633);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JRREPH07E72A865Z','Saskia','Overton','H.White4@kpn.nl','X-Ray Equipment Test',135893);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WSORUQ71A82O287M','Claudia','Watson','Bas.Wargula@kpn.nl','Engineering Technici',58052);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('CSCXZF23S26B974H','Ed','Sharp','Victor.Kuehn@mail.gov','Teacher Secondary Sc',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LPIQBO41E16K184L','Syd','Swaine','H.Markovi@kpn.de','Circulation Officer ',476063);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('PMAVZT44C80X849S','Matt','Press','AgnesSuszantor@yahoo.fr','Handyman',439286);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('HLMFNI82L99S546U','Rosa','Robertson','Michael.Blount@telefonica.no','Technician Offset Pr',687862);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RVYTGI91B45F503X','Agnieszka','Hulshof','HankWhite@excite.it','Transcriber Medical',745797);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UZFKKX33R89U200U','Oliver','Griffith','LindsyBraconi3@excite.com','Engineering Technici',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZBIKAL84M00F064U','Maximilian','Van Toorenbeek','Y.Mayberry3@dolfijn.nl','Lens Cutter',683873);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('QAVRGO66A35M777J','Alexander','Aldritch','JeanJackson@mail.cn','Hotel Reservation Cl',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KYSLGY55M88V359T','William','DeWald','AnnLee5@hotmail.cn','Biomedical Equipment',675414);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UGSEMR15M97J627K','Saskia','Manson','Nick.Robinson@web.fr','Operator Drill Press',604822);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YZUWPX77R74U041N','Stephen','Linton','Bill.Press@gmail.cc','Custodial Supervisor',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('LRISTV11S06X113L','Hank','Archer','Fons.Schubert@gmail.it','Board Member (Outsid',908452);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IZSLTU10C92G493I','Koos','Pensec','TBrown2@weboffice.cc','Sales Order Manager',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YYBEHQ16P97N253X','Sophie','Van Dinter','Vincent.Cantere@live.be','Clockmaker',219470);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BCJBKK14E71I000W','Bill','Davis','Eric.Cain1@aol.co.uk','Furniture Repairer',184100);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('WZJDXL33A85Y570P','Rasmus','Cooper','MLeonarda@libero.net','Computer Control Ope',375526);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VJQVUX07D70I443D','Mick','Gaskins','FredRobinson3@gmail.dk','Aircraft Navigator',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('IZSMIS42T80D026Z','Herbert','Gerschkow','JeanHerring1@web.co.uk','Cardiac Technician',168482);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FINDCD00H21K430Z','Cian','Wood','JohanMcCormick@mobileme.no','Numerical Control Ma',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TPTQCF67P09P952Q','Lewis','DeBuck','Bill.Foreman@weboffice.gov','Automobile Rental Cl',986100);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('YPUEZY95B65R612Y','Gerrit','Poissant','JFranklin1@excite.no','Advance Agent',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('XWETHN20E22C094M','Klaas','Schmidt','MandySchubert@web.be','Obstetrics Staff Nur',81529);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('RRNCUN97A93K476P','Sylvia','Harness','JohanMorton3@libero.fr','Worker Dock',541304);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('BTBVGI96H55W080Y','Margarita','Cohen','Freddy.Mitchell4@hotmail.co.uk','Materials Management',257040);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('MYWZYV44D24I733T','Alvaro','Donatelli','FrankZurich@live.ca','Insurance Claims Cle',489907);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZRFRUZ91S02Q223S','Elzbieta','Ratliff','M.Daley@gawab.dk','Technician Paint',831199);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('VKLDHI23L08G868J','Sjanie','Fox','Bill.Forsberg3@lycos.cc','Production Control &',569551);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('JDHNBO28E24T229D','Ryan','Bernstein','PSymms3@gawab.dk','Supervisor Economic ',860129);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('FKZJBO48C48T420B','Oscar','Huston','H.Sanders@lycos.nl','Storage Facility Ren',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('ZTLEHD99B17M910Y','Will','Moon','RogerBrennan@gmail.fr','Audit EDP Manager',396572);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('GLGRNW21R14Z895R','Lena','Noteboom','EmmaLangham@kpn.es','Retail Cashier',225364);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('TECVHF39S12B764H','Nathan','Naff','FrankToler@excite.net','Clinical Psychologis',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('KTQTXY80B40Y733B','Maggie','Tudisco','BiancaMiller3@msn.no','Technician Mechanica',NULL);
INSERT INTO "ortiScolastici"."persona" ("cf","nome","cognome","email","ruolo","telefono") VALUES ('UVGXAW67T45C061P','Lizzy','Chwatal','OttoIgolavski3@live.org','Sales Training Super',971978);

---

INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HOKU232363','McDaniel','1','HX','BRASILIA','RJRJLB01A99Q418W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AWSB463953','Brylle','1','NU','Yuzhou','RJRJLB01A99Q418W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MIAL404804','Geoppo','1','PZ','Xiaogan','RJRJLB01A99Q418W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EZPN556177','Naff','1','TG','Sendai','BPESFM87C80J906U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BBEQ642750','Bernstein','2','ET','BEIJING','BPESFM87C80J906U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XGOZ206775','Carlos','1','PX','Chengdu','BPESFM87C80J906U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JPAQ950880','Orcutt','1','MM','Weifang','MHNAUI93P55G907N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RMOH105619','Oyler','1','VL','Jingmen','OZTCAY77E56P837E');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XHEY917650','Markovi','2','OD','Phoenix (AZ)','SNHFDG01E34I738W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NRVP212218','Vostreys','1','JB','Davao','UNTDAS08E05B938A');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UVST785187','van Dijk','1','DA','Guikong','VUCVZA00D23E710F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BSTQ143737','Whitehurst','1','GY','Belém','ZJJRHE06D54X996R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XUMZ640083','LeGrand','2','RZ','Pusan','ZJJRHE06D54X996R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KRQO221401','Durso','2','DP','Naples','IFZZVR08H34J375A');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CCVM209965','Pearlman','1','HH','Xian','VAKUUK52R13Y681L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HABM675977','Lawton','2','QN','Bombay','VAKUUK52R13Y681L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VZUB660678','Long','2','BD','Dnepropetrovsk','UXQJHN86L68Y652B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RMWN141739','Millikin','1','BP','Malang','UXQJHN86L68Y652B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HQYS628139','Williamson','1','WS','Bombay','BMGAWK81C56O667L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WEYZ736087','Schubert','2','PV','Hyderabad','BMGAWK81C56O667L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IQYU292364','Matthew','1','KR','Perth','BMGAWK81C56O667L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TNQE507402','Deleo','2','XB','CARACAS','UDHAKN85P14Z664D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FUQG557186','Yinger','2','RZ','Omdurman','UDHAKN85P14Z664D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LPQK893789','Blount','2','WQ','Hiroshima','PCIHOZ76P49W836F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PHZI712016','Jones','2','DM','Guiyang','AOBIZC87M39V879F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ICHH641331','Frega','2','KU','Belgrade','QLBFSW34R89Y771O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VBFL696361','Prior','1','DC','Toronto','QLBFSW34R89Y771O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('INNO159766','Fernandez','1','OA','Sydney','MTGJPQ57E19K817Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WJFY993381','Schlee','2','HG','MANAGUA','MTGJPQ57E19K817Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CKGL041500','Wakefield','2','WT','Perm','MTGJPQ57E19K817Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HZSI671820','Wolpert','1','MX','Philadelphia (PA)','OBDJWF30M46I298U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VMVG538918','Schlee','1','WJ','Changde','OBDJWF30M46I298U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EOSU134636','Hamilton','2','GD','Haicheng','YBBCHG66B88Z526R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZUVV082123','Brown','2','EP','San Antonio (TX)','YBBCHG66B88Z526R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DYXL219640','Botsik','1','BN','Novosibirsk','ACKBPT54H46Z283F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WRYX835237','Ostanik','2','AJ','Xian','VDZHBU12T54R195K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HPFW066855','Linhart','2','SH','Volgograd','VDZHBU12T54R195K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FHUX246339','Goodman','1','CT','Wuhan','UYAFJH59B69Z431Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YFLO985733','Davis','2','ME','Guangzhou','UYAFJH59B69Z431Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ONVP684480','Anderson','1','JA','Ujung Pandang','UYAFJH59B69Z431Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DGPI802997','Morton','2','JM','Dengzhou','CQPCSJ68D54G047O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZCLA418514','Ward	','2','JT','Wulumuqi','CQPCSJ68D54G047O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YXRI924778','Royal','2','ZU','MONTEVIDEO','CTOHLH05L93K955O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SUMC912647','Deleo','1','RW','Xinghua','NZQFPM79S43V809D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BCAT073910','Hardoon','1','RR','BUCURESTI','NZQFPM79S43V809D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ISFN695651','Friedman','2','QR','SINGAPORE','GRSHKW87L60W551Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AXVM765511','Stockton','1','GC','Odessa','DHAGYK45C85U562G');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VWVI840013','Daniel','1','UR','TOKYO','DHAGYK45C85U562G');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JCMX459758','Mayberry','1','MK','Nanjing','BLRPTA64R13L152F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RCEI775123','Lezniak','1','VT','Los Angeles','TNHPNA50R92H187B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XVXQ085248','Brumley','2','DH','TEHRAN','TNHPNA50R92H187B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('REXE231415','Suszantor','1','TZ','Xinghua','TNHPNA50R92H187B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EDAO792413','Zurich','2','LM','Changchun','MITLLA44M69M750J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OCAB798533','Jones','1','JZ','Belgrade','IUYNHS97E17L161S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YDPL131659','Lawton','2','MP','Brisbane','ACNZRQ87A31Z077M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AMMO276040','Plantz','2','MI','DHAKA','ACNZRQ87A31Z077M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XFJM071528','Gerschkow','1','CH','SOFIA','ACNZRQ87A31Z077M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WVOK098475','Troher','2','VB','Yokohama','UQHIJJ60S20T115V');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NKLC275838','Wooten','1','NH','Nanning','NZNPSX57D22I283C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JAHG085442','Brylle','1','ZU','RABAT','NZNPSX57D22I283C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HIVX127078','Shapiro','2','QA','Kaohsiung','HIDAYF54L44X548C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VKSF672045','Braconi','2','TA','Zhanjiang','HIDAYF54L44X548C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NGPK007372','Brumley','1','OU','Leiyang','LNUEDP89E51D297Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GRMA600469','van Dijk','1','PS','Xinghua','LNUEDP89E51D297Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AVHC934552','Marra','2','AL','Jiangyin','NKLIUD53B05L379U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IABH313292','Scheffold','2','CP','Yuzhou','NKLIUD53B05L379U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GDMC148991','Walker','1','AH','BAGHDAD','HEOUSO33S87U856K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JUIG265908','Grote','1','TS','BANGKOK','HEOUSO33S87U856K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RLRZ812930','Stevens','2','CM','Perth','EBMXRG57P16Q638Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TSKG484779','Griffith','2','SA','Sapporo','NKQBYK21M51I423G');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GWBA292430','Noteboom','1','VZ','Tianmen','OBKOAB29R19F091W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BBJJ636077','Turk','1','SN','Nagpur','OBKOAB29R19F091W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QHDF053500','Harness','2','DQ','Chittagong','YNTJJE93T68G652C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IVDW339337','Millis','1','NZ','Xinghua','EZSHLY75M90R324B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FZKD472886','Pengilly','1','GR','Taegu','ZDNCSX56S75Y818Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PCON152997','van Dijk','1','ST','Lahore','ZDNCSX56S75Y818Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NREK820250','Dulisse','1','SK','Kaohsiung','ENLXYN86R38Y532Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SDQT316641','Cramer','1','DJ','Kunming','ENLXYN86R38Y532Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JAQT454002','Thaler','2','HG','Perm','WKXWLX43H37M651M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HDKJ083576','Archer','2','DK','Tangshan','WKXWLX43H37M651M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SRQR279989','Ionescu','2','ZG','Tianjin','WKXWLX43H37M651M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IQFM865439','Knopp','2','VL','Tianshui','HWPGWT25A95Z805O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EJSB464540','Aldritch','2','EI','KINSHASA','PWTFEF04L29J384R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JWWO474553','Bertelson','2','TX','Kwangchu','UARNAG74P81A834J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GVPI621762','Lawton','2','XB','Chaozhou','UARNAG74P81A834J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EJYP741398','Huffsmitt','2','XO','JAKARTA','GGIVOH26B61T847T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ALCO645584','Harness','2','SL','Gujranwala','GGIVOH26B61T847T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NOTU391188','Morgan','1','UT','Dar es Salaam','GGIVOH26B61T847T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FEXE393362','Love','1','FI','BAKU','ZUAOSJ65H91A655J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BZQT297971','Hedgecock','2','QC','Fortaleza','ZUAOSJ65H91A655J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JBFN281006','Arcadi','2','EA','Dongguan','ZUAOSJ65H91A655J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IWAI992831','Ionescu','1','GD','Novosibirsk','IKMWDQ55L85M140K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VDQI437671','Swaine','2','RM','Sapporo','IKMWDQ55L85M140K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QIXQ215517','McCormick','1','RJ','Pakalongan','TZVBUF90M31K132C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KKLY698903','Framus','2','MC','Manaus','GXLRBQ52R22H389P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QEAR862288','Reyes','2','HO','Changde','GXLRBQ52R22H389P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HTZE205898','Wood','1','EX','Kawasaki','GXLRBQ52R22H389P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IENI175363','Hoyt','2','RS','Barcelona','MXTIQQ95M99T688N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NSRO243077','Herzog','2','TK','Karachi','MXTIQQ95M99T688N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EMEI071224','Bitmacs','1','OM','Nagpur','PQQGDF28C38G335U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('THZF525024','Hendrix','1','EO','Nanjing','PQQGDF28C38G335U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BQCH151783','Sharp','1','OD','Suining','TNFFUN01M68P030A');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GKUP430475','Hulshof','1','MG','Changde','ECHAZL92S11E169H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TGFE250127','Muench','1','OZ','Fukuoka','ECHAZL92S11E169H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PORX302478','Perilloux','2','RI','Fengcheng','ECHAZL92S11E169H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AGWO238156','Lawton','1','PG','SANTIAGO','XZCZSZ18S77T619O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CELL920464','Franklin','1','QA','Dongguan','XZCZSZ18S77T619O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FWWB766658','Mairy','1','OG','Sendai','XZCZSZ18S77T619O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MJEU139194','Bright','2','EG','Huainan','OUGMHI56H49A668R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FHHE320565','Archer','2','MJ','ANKARA','OUGMHI56H49A668R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MNOZ485526','Gunter','1','BP','Barranquilla','OUGMHI56H49A668R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ODED857199','Petterson','2','LZ','Inchon','STFFRR07B60N663L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UEHA388048','Brown','1','BW','Fortaleza','STFFRR07B60N663L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MLOW676778','Wood','1','PV','Dongguan','STFFRR07B60N663L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MBWW975753','McDaniel','2','JC','Tangshan','VQSSFS43E88T107N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZVKH600412','Schmidt','1','TP','Vienna','VQSSFS43E88T107N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SNVI325308','Mairy','2','DR','Ufa','VQSSFS43E88T107N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MFGH024483','Byrnes','1','XB','Laiwu','DWGJPK35T13H282M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RQRH875335','Fox','1','DE','Kyoto','DWGJPK35T13H282M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KVPL632920','Watson','1','EX','Surat','DWGJPK35T13H282M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CSYV411279','Newman','2','UV','Zhucheng','NLGQBR99H15J813F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IRTW189459','Guyer','2','RQ','Changchun','NLGQBR99H15J813F');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CTBY462301','Crocetti','2','FP','Shanghai','PHVSDR31D15X396N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KDQF582412','Durso','2','DP','Los Angeles','PHVSDR31D15X396N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IHKC898322','Arcadi','2','UY','BUENOS AIRES','PHVSDR31D15X396N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LFII914383','Van Dinter','2','CL','Nanning','ZKWCKC73T27L743N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MYUG457596','Poissant','1','EF','Nanjing','ZKWCKC73T27L743N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GEIQ914585','Frega','2','ID','TEHRAN','ZKWCKC73T27L743N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GUEI411177','Caffray','2','IG','Los Angeles','YCDKHY11P84H658T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HIAA048041','Markovi','2','RP','LUSAKA','QCVHNM83C46D718E');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RJDA883645','Olson','1','OH','Chengdu','RAPTSG11M95Z929O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ESSS302937','Koch','1','KA','Kalyan','KSUDZR56H64S726C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DTJI265710','DeWald','1','CJ','Medan','KSUDZR56H64S726C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AURS710840','Stannard','1','AI','Guayaquil','KSUDZR56H64S726C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HLWO539091','Brown','2','XX','Xiaoshan','YOHYAB12A66B562E');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WTUV630262','Visentini','1','GI','Medan','ZJAEZR05E48Z384J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VLNS072181','Robinson','1','SS','LONDON','ZJAEZR05E48Z384J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IZBR614712','DeBuck','1','QO','Dnepropetrovsk','KFLSXP91S91H350C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CYNY040761','Zurich','1','ZY','Malang','KFLSXP91S91H350C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TZUC950478','Gieske','2','SZ','Madras','KFLSXP91S91H350C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PXQL972884','Geoppo','1','OO','Palembang','OVAJFY59R39S248I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IEAH194505','Ahlgren','2','SA','Zhanjiang','OVAJFY59R39S248I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KOZR361088','Hedgecock','1','IW','LUSAKA','OVAJFY59R39S248I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HMBM511018','Ecchevarri','1','XC','Lianyuan','UBIWQJ10T63I482W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FMFA660004','Richter','2','UX','Bhopal','UBIWQJ10T63I482W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ODBX933330','Hankins','1','ZX','Xinghua','HMGFUQ05A10O630L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WZES421832','Wood','1','ZG','Maracaibo','HMGFUQ05A10O630L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FECQ684588','McCormick','2','CI','BRASILIA','HMGFUQ05A10O630L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CDLT314988','Robbins','1','NZ','Xiantao','FRQWON52M88E587Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VRVD085844','Braconi','2','JD','BERLIN','FRQWON52M88E587Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZWIF463814','Raines','1','ZW','Lianyuan','LMTIYF82B90V507O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AAXR122951','Massingill','2','AE','Xian','EAWCEE83L85A767O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VLJV943736','Bitmacs','2','KP','Houston','EAWCEE83L85A767O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ICRT412949','Framus','1','CS','Nanning','EAWCEE83L85A767O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KFVU471545','Richter','2','QK','Hefei','SZFNVP26C82X170Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WZMN980318','Mairy','2','QS','Vienna','SZFNVP26C82X170Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YVWO739465','van Dijk','1','LB','Ufa','SZFNVP26C82X170Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YKDB001413','Stevenson','1','DQ','Shanghai','MSIUKV39A91R810W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BEGZ273671','Bugno','2','EX','Jinan','MSIUKV39A91R810W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KSFY622372','Nithman','1','JN','HongKong','BCCRZI60R25X784Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LWLN295284','Watson','1','WT','Jingmen','BCCRZI60R25X784Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JUFE955921','Laudanski','1','PM','Kampong Cham','BCCRZI60R25X784Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LONQ300966','Browne','1','RI','Chaozhou','VUXCQP48T38W432A');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YQQR514852','Queen','1','NO','Guangzhou','VVGSMK04T85W450T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AODK290647','Deleo','1','KB','Chelyabinsk','VVGSMK04T85W450T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HNVP731485','Muench','2','ZB','Pusan','VVGSMK04T85W450T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PIAL534004','Muench','2','KV','MONTEVIDEO','LMEYPJ78R70A512G');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KCEW490682','Poole','1','AU','Algiers','WZTFOS68S26X837Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JTYW620611','Ward	','1','HU','Kanpur','GQQMHG67C94L985Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EBUG684208','Warner','2','QQ','Houston','LKPNWO11L67T566A');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HAWZ717320','DeWald','1','MO','Pingdu','SYVXDM46E52X208U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SUYT247091','Slemp','1','OM','Kitakyushu','SYVXDM46E52X208U');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WKML530476','Deleo','2','KO','Jinan','QBIQWN81B40V010Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VYRI885363','Leonarda','2','DZ','MANILA','DRCZBA81B58P386T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QIRM677554','Moreau','2','GY','Macheng','SBECEP64T32N165L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BIGI276798','Warner','1','UA','LUSAKA','RGVLQL93L74X239R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PYTL568162','Symms','1','VQ','Taiyuan','RGVLQL93L74X239R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BRNF243418','Daughtery','1','CL','Taiyuan','RGVLQL93L74X239R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GBWG223911','Marra','1','LG','Kharkov','YVEYZH88P58S539I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HMQO690172','Swaine','1','VB','RABAT','YVEYZH88P58S539I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YAWN130854','Harness','1','WD','Tianshui','YVEYZH88P58S539I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('STSW045123','Blacher','1','DD','Delhi','FUBIQA06C78Z544R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YUPK544643','Petterson','2','JW','Chaozhou','FUBIQA06C78Z544R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OZBH954364','Ionescu','1','RV','Warsaw','FUBIQA06C78Z544R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AZRX146926','Conley','2','EO','Datong','JWKQEI80H08T627O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EEFN720901','Griffith','2','JP','JAKARTA','JWKQEI80H08T627O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZCZT349977','LeGrand','1','QE','Belo Horizonte','JWKQEI80H08T627O');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AFEV850059','Watson','1','MS','Changsha','AREBRK59C85B308Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WIWL306434','Rivers','2','IE','YANGON','CEXGTZ27R73C819B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OBUN668387','Petterson','1','GE','Handan','CEXGTZ27R73C819B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KTTL410818','Cross','2','UN','Barcelona','CEXGTZ27R73C819B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KGPT470388','Forsberg','1','GM','Sapporo','HBHVJY86R91D633P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UYGS903809','Brown','1','LU','Yuzhou','APJUXR14L01D262C');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FNCD870186','Waldo','2','FR','Dalian','WDRYDA75H51Z155N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XUPP737868','McDaniel','1','CE','Novosibirsk','WDRYDA75H51Z155N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KKEW207621','Stevens','2','SN','Birmingham','WDRYDA75H51Z155N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JZHS112590','DeBuck','1','PZ','CARACAS','TJFJRL75C86G381Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SQCY660654','van der Laar','1','WR','Lahore','TJFJRL75C86G381Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ACWP080908','Herrin','1','EF','Tianmen','TJFJRL75C86G381Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YOMX589970','Mcnally','2','TI','Shijiazhuang','JRREPH07E72A865Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WIIA630130','Jiminez','2','SC','Malang','JRREPH07E72A865Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UURQ004149','Waldo','1','OQ','Yokohama','JRREPH07E72A865Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WVNQ797832','Phillips','1','ZF','Changde','KYSLGY55M88V359T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZAOQ778460','Crocetti','2','BT','Salvador','KYSLGY55M88V359T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EELG032874','Williamson','1','UD','LIMA','KYSLGY55M88V359T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MHXA724008','Long','2','GA','Warsaw','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ROUE999524','Guyer','1','SI','Izmir','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XQRU737749','Moore','2','QL','LIMA','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BZNS539157','Wakefield','2','EQ','Fengcheng','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PFVM375972','Moreau','2','PF','Guarulhos','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LQOE882456','Slemp','1','KP','Changshu','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZGFS059775','Schlee','1','EG','MANILA','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UBPR501791','Guethlein','2','OD','Prague','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GOAJ212604','Helfrich','1','EA','RABAT','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GSPP027542','King','1','BN','Bogor','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JCDU710137','Toler','1','EQ','Nanchang','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PWNE304765','Francis','2','MQ','Bombay','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UWFV740811','Yinger','2','RF','Huaian','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CZHI942968','DelRosso','1','NW','Shanghai','YZUWPX77R74U041N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DHDI689216','DeWilde','1','AX','Palembang','YZUWPX77R74U041N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IJVW792473','Moore','2','UL','Ho Chi Minh City','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PSJL636357','Geoppo','2','IA','ROMA','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QDCW593533','Pyland','2','IO','Daqing','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DHCI879406','Nahay','2','AZ','BEIJING','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FQRK820993','Wooten','1','MC','Xiantao','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KEVC513523','Rivers','1','VD','São Paulo','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UUNP075389','van Doorn','2','FH','Taegu','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HRXF060699','Evans','2','BH','Qingdao','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DYCA216233','Richter','1','KC','Changchun','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TVHY167160','Reyes','1','OO','Lanzhou','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EYMW664821','Brennan','1','HX','Weifang','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CHVJ122150','Barnett','1','RX','Taipei','YZUWPX77R74U041N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MIKH372131','Cramer','2','DS','ROMA','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DQPK500518','McCormick','2','TZ','Kampong Cham','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AAST674606','Pierce','2','SN','Casablanca','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OGAM283178','Press','1','YJ','Zhucheng','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XBKM581590','Zimmerman','1','IZ','Pusan','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DGXP453840','Harness','1','OM','São Paulo','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MDWL274500','Gaskins','1','AD','Rawalpindi','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CGHZ184693','Perilloux','2','NY','Lagos','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HIVR897611','Roche','2','DW','Rawalpindi','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FQQK756040','Durso','1','MU','DHAKA','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AMGV757389','Durso','1','VO','Philadelphia (PA)','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CHOU252513','Helbush','1','KV','Chaozhou','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CQKB762968','Daley','1','VI','Huzhou','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TCKZ029486','Langham	','1','MF','Osaka','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FUBE410934','Hollman','1','LO','Kharkov','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FAUT691590','Suszantor','2','MY','Tangshan','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XYMY525868','Rauch','2','JN','CAIRO','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HSWA474382','Morton','2','PE','Qiqihaer','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SABL045541','McCormick','2','LS','Chongqing','FKZJBO48C48T420B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FZCG939483','Reyes','1','OY','Malang','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JVHC694963','Deans','2','FY','GUATEMALA CITY','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FHWR698912','Nelson','2','PS','ROMA','TPTQCF67P09P952Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TRFV704490','Huston','1','JI','Prague','TPTQCF67P09P952Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CKFC510989','Daniel','2','IU','Jaipur','TPTQCF67P09P952Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DGYE976815','Willis','2','XC','Birmingham','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SWUZ666594','Freed','1','NV','TOKYO','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZIXZ334053','Anthony','2','CV','Ekaterinoburg','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VVOA631460','Troher','2','LX','Hiroshima','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HCFY614583','Hardoon','2','FN','BUDAPEST','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OLEY272730','Dean','1','JN','Dar es Salaam','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FUSM821096','Press','1','LW','Kediri','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BRTD655750','Toreau','2','KE','Birmingham','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JAMX532624','Rauch','2','UU','Omsk','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FVAJ274064','Geoppo','2','KX','Chittagong','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JTWH406084','Nadalin','1','JV','Tianmen','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XAJJ339364','Haynes','1','UH','KINSHASA','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CYWJ823208','Nahay','1','II','Zhucheng','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TIDK576732','Sakurai','2','JC','SEOUL','YZUWPX77R74U041N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CDQH805186','Love','2','FR','Rizhao','YZUWPX77R74U041N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OBKB539031','Bertelson','2','GD','TRIPOLI','YZUWPX77R74U041N');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HPJV854351','Harder','1','YK','Qidong','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IYWX847165','Waldo','1','UE','Kyoto','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HOYC490381','Mitchell','2','AT','Macheng','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CGRD031609','Ditmanen','1','XJ','Shiraz','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HOZZ344699','Turk','2','XA','Nagoya','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CPOW362229','Conley','1','GM','Bandung','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZAVT148564','Whitehurst','1','VF','Hamburg','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TNVS455218','Friedman','1','VD','Tianshui','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LNQG588224','Hardoon','2','LE','Pingdu','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BCBH851940','Wesolowski','1','OP','Taejon','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QRZR459530','Herring','2','FA','MANAGUA','FKZJBO48C48T420B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LMBB683668','Lee','2','HM','Cali','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EYRS971164','Huston','1','IP','Tangshan','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ENKN613415','Antonucci','2','HP','KIEV','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ELYE442243','Mitchell','1','TD','Guangzhou','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YXRY472418','Stevens','1','QZ','San Diego (CA)','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LJEM468209','Pyland','1','MQ','Changshu','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CZYQ103574','Wooten','1','JS','St Petersburg','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DYDG052022','Kidd','1','KR','Changsha','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FZFX222504','Millikin','2','QJ','MINSK','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NEOE931850','Olson','2','EL','Yuzhou','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OCQF133197','Cragin','2','JQ','Recife','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KDVN939145','Williams','2','QN','Manaus','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JXQB805277','Waldo','2','VT','Moscow','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GZTL026596','Bergdahl','2','EQ','St Petersburg','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VKUA442722','Matthew','1','OJ','Jimo','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZQZP900436','Watson','1','MH','San Diego (CA)','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HNNK729126','Williamson','2','YV','LUANDA','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JFUI357563','Hoogbandt','2','XG','PYONGYANG','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KLIF067262','Archer','1','VC','Taian','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZOUT913672','Huffsmitt','2','EW','Fushun','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SCBE327866','Brumley','2','AI','Odessa','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VKHU121609','Gua Lima','1','CF','Istanbul','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WKKM272846','Stockton','1','TY','Lagos','TPTQCF67P09P952Q');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BZEN691581','Lezniak','2','GJ','Havanna','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VAPI024392','Emerson','1','HZ','Kaohsiung','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ELHI784704','Matthew','2','EI','QUITO','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LOSY546015','Freeman','2','OW','Pakalongan','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XCTD177324','Whitehurst','1','VZ','MANAGUA','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JFBL577624','Massingill','2','UG','Prague','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GIVO097060','Cramer','2','LF','Adana','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PTZU597548','Yinger','1','AK','BUCURESTI','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RAZB848346','Johnson','2','CU','Qiqihaer','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YVDU060684','Pekagnan','2','CK','LONDON','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BUGS169241','Angarano','1','TF','ADDIS ABABA','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YSJU925046','Aldritch','2','DU','San Diego (CA)','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MJIS394132','Kingslan','1','AR','YANGON','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MNZX730443','Byrnes','2','YF','BOGOTA','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XIHH599517','Chapman','2','KW','Handan','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PHMI133249','Ward	','1','VC','Kaohsiung','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GXFL556532','Weinstein','1','VJ','Milano','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HVEA851359','Waldo','1','CY','SEOUL','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RAGB441437','Tudisco','2','GN','Zaozhuang','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VPDQ730674','Reyes','2','BY','Suqian','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NCSF354686','Praeger','2','QZ','PYONGYANG','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VMTO608265','Jackson','1','PW','Dar es Salaam','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LSGF430892','Plantz','2','XO','Tangshan','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZOZM913851','Cross','1','PA','ADDIS ABABA','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PJQQ407799','Stevens','1','LV','Kharkov','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VEXY807696','Katsekes','2','RL','PORT-AU-PRINCE','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NAFK359218','Wood','2','ZE','Jeddah','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GZYL796517','Hopper','1','BD','KINSHASA','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OYQS062436','Brady','2','CP','Munich','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RYAS223099','Hankins','1','EK','Nizhny Novgorod','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OTDD474934','Oyler','1','UQ','BOGOTA','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NQRH824754','Voigt','1','RA','Esfahan','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FUJK032756','Brendjens','2','QL','HARARE','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EUED094664','Evans','1','CO','Belgrade','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TTXS210477','Clark','1','KJ','Kaohsiung','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UYWH236706','Langham','1','CJ','Dingzhou','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XFQH080392','Braconi','2','LD','YEREVAN','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZIKS528654','Mitchell','1','JV','Algiers','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YTWL461202','Oyler','1','HA','Belgrade','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZJAG992030','Brown','1','EO','Netzahualcóyotl','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GJUY873925','Sterrett','2','XP','Moscow','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QCFR394346','Oyler','2','IP','Ruian','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WXNI946273','Linton','2','KV','Jaipur','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ICRZ393880','Ditmanen','1','XX','Tengzhou','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NEEH124972','Zapetis','1','DZ','Surabaya','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IDZT985826','Nobles','1','MG','Wulumuqi','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ETNE029707','Manson','2','IS','Ujung Pandang','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BJAQ956398','Sharp','1','FV','Ludhiana','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UUOU964263','Anthony','2','WV','BAKU','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VAVP399720','Crocetti','1','CV','Jeddah','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DBWI278124','Kidd','1','HU','Qiqihaer','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ONEK452943','Daley','2','GF','Rizhao','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MLNM248939','Hamilton','1','EU','SANTIAGO','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZLSZ838521','Byrnes','2','FT','BUCURESTI','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JNUO931587','DeWald','2','NC','Fukuoka','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RWZC997574','Morton','2','IG','Cirebon','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UPBO093423','Comeau','1','WY','Fortaleza','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KVOA826650','Kellock','2','TY','Haozhou','WZJDXL33A85Y570P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GVCA448420','DeWilde','1','IU','Philadelphia (PA)','WZJDXL33A85Y570P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HTHF823957','Millikin','2','HE','Xiaoshan','WZJDXL33A85Y570P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OZXN012395','Lee','1','BW','Rawalpindi','XWETHN20E22C094M');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RPMO358195','Waldo','1','SD','Kanpur','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DHVO615548','White','2','RF','Lahore','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RBHS957691','Knopp','1','CU','Palembang','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KGRC701891','Duvall','1','OB','Omdurman','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OGOK355489','Perilloux','1','YQ','Palembang','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YHMN622918','McCormick','2','FX','Munich','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HBBY716600','Love','1','PK','PARIS','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IRZY031997','Nelson','1','MF','Dongguan','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PNXZ663068','Dean','1','AY','Hyderabad','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NBBR872165','Uitergeest','1','OX','Fortaleza','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KIUK246566','Davis','2','KK','Pingxiang','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UGWU356163','Stockton','2','MB','Laiwu','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JBUN991082','Shapiro','2','DL','Fengcheng','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PTIW351090','Thompson','2','HE','Kampong Cham','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WJTV935342','Freed','2','AC','Hyderabad','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RTAK628948','Shapiro','2','BG','Munich','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JIXS270384','Naff','1','XC','New York (NY)','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AUWE413238','Lawton','2','WQ','ROMA','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RKWU659055','White','1','HT','Yokohama','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WDEH992980','Blount','2','UY','Kalyan','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ARSM038356','Sirabella','1','CA','Wuxi','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FROX669458','Goodman','2','KT','Pune','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UMSQ941879','Walker','1','WS','ADDIS ABABA','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CJRL744606','Thompson','1','HU','Alexandria','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XGAL942511','Walker','2','LQ','SOFIA','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FVKC777277','Mairy','1','YQ','YEREVAN','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CWPL173020','Buchholz','1','IJ','Fortaleza','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LMMJ451918','Sakurai','1','GG','Chaozhou','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OIFH804462','Shapiro','2','AZ','Maracaibo','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PQXN524913','Gerschkow','1','DU','Almaty','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BYMN501822','Cooper','2','ZR','Fukuoka','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NZSJ448409','Lejarette','2','PO','Tianjin','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VBBD118173','Comeau','1','LW','Cali','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ISDK798681','Linton','1','YW','Leshan','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PNWC500160','Chwatal','1','WX','Pueblade Zaragoza','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DWGN995148','Goodman','2','FS','Bangalore','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WDQS946164','van der Laar','2','MQ','Taian','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MYJS724749','Symbouras','1','SS','Dongtai','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MKGK054742','Shapiro','1','ZC','NAIROBI','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CTCB566675','Walker','2','TP','Suizhou','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LOSZ684107','Pengilly','1','NB','Haozhou','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SWWO992093','Ostanik','2','AW','Fengcheng','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VXCK039470','Walker','2','EH','Prague','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QROP953699','Nadalin','1','NC','Inchon','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QWRN840198','Nefos','1','FO','Houston','FKZJBO48C48T420B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UAHI402939','Love','1','OD','Taejon','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DDOO437893','Morton','1','KD','Jeddah','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RBBK485517','Cramer','2','SQ','Pueblade Zaragoza','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YXAJ543306','Hancock','1','QF','Laiwu','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AGQR123957','Symbouras','2','UJ','Guarulhos','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KYDF778775','Paddock','1','FT','Hamburg','IZSMIS42T80D026Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SBIO984048','Miller','2','BT','Chongqing','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RIDT146314','Linton','1','JF','Nanjing','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VVYH797252','Hankins','1','SR','AMMAN','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('NGGH460819','Markovi','1','EB','Ruian','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DKSU592234','Kellock','2','XC','Houston','WZJDXL33A85Y570P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DZSB396994','Olson','1','CR','San Diego (CA)','WZJDXL33A85Y570P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DDFR709271','Turk','2','SD','Mashhad','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EDEW220949','McDaniel','1','EU','Handan','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MWHS497547','Bruno','2','BZ','BAGHDAD','FINDCD00H21K430Z');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ANYK901818','LeGrand','2','GT','JAKARTA','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IGUG532651','Goodman','1','OG','Bogor','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WYYR769282','Freed','1','ZS','Lagos','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QTTY479485','Brendjens','2','YM','Hiroshima','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ISDV893426','Ward	','1','SP','JAKARTA','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YTVQ158508','Cohen','2','MT','Ningbo','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UIDV757460','Hopper','2','UQ','Kawasaki','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BRCO812789','Martin','2','XU','Abidjan','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LGKO324142','Prior','1','KZ','Chengdu','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KFWI491128','Manson','2','LA','Fortaleza','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KARU430820','Pyland','2','BF','CAIRO','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GXBE719209','LeGrand','1','JZ','Rawalpindi','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GUHH436987','Paddock','1','RH','TEHRAN','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CEQW851577','Perilloux','1','EU','Haicheng','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XPZQ953283','Maribarski','2','EB','CARACAS','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IYWA910008','Anderson','1','UX','Datong','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YIMT646141','Brennan','2','UK','YANGON','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DHVH131587','Patricelli','1','FJ','Pingxiang','UGSEMR15M97J627K');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LMIC054369','Hardoon','2','FF','Hiroshima','WZJDXL33A85Y570P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BIOI959272','Pyland','1','LW','Jaipur','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('IWHA022693','Slater','2','EY','Chongqing','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EMWA544835','Richter','1','TN','Lahore','BTBVGI96H55W080Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HQIE971377','Korkovski','1','QS','Adelaide','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AQBE496850','Jenssen','1','SI','MADRID','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RPGU995734','Katsekes','2','LB','Hefei','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KJTM417052','Anderson','1','EX','Jilin','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RXBD588569','Zimmerman','1','FW','PORT-AU-PRINCE','VKLDHI23L08G868J');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('PAPE056177','Stockton','2','TD','Fukuoka','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UIVR814125','Koch','2','JW','Dongtai','TECVHF39S12B764H');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TZZQ532938','Gieske','1','TN','Hangzhou','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DJRU858966','Thompson','1','YA','Toronto','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DEWW797010','Newman','2','QW','São Paulo','UVGXAW67T45C061P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RVFM390729','Vostreys','1','YD','Xiaogan','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BXEX620534','Durso','1','WM','Dingzhou','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GEMA644483','Storrs','1','FL','Tianshui','LRISTV11S06X113L');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('RSYU811082','Gildersleeve','2','JD','BUCURESTI','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZSGR380886','Harder','1','TX','Haozhou','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DVIK096518','Bitmacs','1','AM','St Petersburg','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YCND315491','Schlee','2','MB','San Diego (CA)','YPUEZY95B65R612Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OOBT502107','Simonent','2','WP','Pikine-Guediawaye','FKZJBO48C48T420B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VIXX843070','Ijukop','2','ZX','Bhopal','FKZJBO48C48T420B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('LJVG642700','Grote','1','CV','Birmingham','FKZJBO48C48T420B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AWDE855655','Marra','1','IB','Caloocan','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YNQD049673','Uprovski','1','PU','Faisalabad','KTQTXY80B40Y733B');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('GQPL823628','Forsberg','2','IB','Nizhny Novgorod','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('SJTD809402','Watson','2','AX','Dingzhou','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('CRSC447313','Toler','2','TX','Qidong','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('FYIZ305484','Cantere','2','KI','Istanbul','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OYOI695673','Slemp','1','HN','Prague','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('OPWM866507','Jones','1','OD','Changchun','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YDUY938231','Robbins','1','XO','SEOUL','MYWZYV44D24I733T');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('EAOJ996432','Storrs','1','YV','Donetsk','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('WAEV271887','Toler','2','DG','Bursa','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('UZQJ331597','DeBerg','2','KZ','Qinzhou','GLGRNW21R14Z895R');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('MJJC474761','Archer','1','SD','YANGON','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('JEPG949935','DeWald','1','LX','Haerbin','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VJMB342548','Wicks','2','YU','Xinghua','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('HPNL897788','Goodman','1','YO','Córdoba','VJQVUX07D70I443D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QADE705245','Green','1','LD','Rio de Janeiro','ZRFRUZ91S02Q223S');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('BZJN034796','Imhoff','2','HE','Dar es Salaam','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('KUNF187615','Ijukop','1','RS','Weifang','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ZZKL219967','Jiminez','1','ED','Recife','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VJSD119688','Crocetti','1','EO','Kunming','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XEJU922944','Millikin','2','GY','Shanghai','BCJBKK14E71I000W');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('VING996466','Perilloux','1','FC','Tianshui','RRNCUN97A93K476P');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('AIWW543193','Caffray','2','BQ','Rio de Janeiro','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('COCY481960','Goodman','1','GF','Algiers','JDHNBO28E24T229D');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('TIHP085728','Wakefield','2','YP','Almaty','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('XAKC044018','Kuehn','1','PX','Kazan','ZTLEHD99B17M910Y');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('DOBZ860217','Overton','2','ST','Haozhou','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('ABPO454361','Tudisco','1','SD','San Antonio (TX)','IZSLTU10C92G493I');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('YTPQ300936','Anthony','2','CU','Montréal','YYBEHQ16P97N253X');
INSERT INTO "ortiScolastici"."scuola" ("codicemeccanografico","nomescuola","ciclo","provincia","comune","referenteiniziativa") VALUES ('QTVP148212','Brown','2','ZG','CAIRO','BCJBKK14E71I000W');

---

INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2O','XUMZ640083','liceo delle scienze umane','HPFQMF68C64X136S');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5K','IQYU292364','primaria','CTKYLN81L14L920N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2F','CKGL041500','liceo delle scienze umane','CTKYLN81L14L920N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4U','VMVG538918','primaria','MKCILE63S38O259R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2RQ','ZUVV082123','liceo artistico','MKCILE63S38O259R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3PB','YFLO985733','liceo musicale e coreutico','DUGDON96E35M468M');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3L','ZCLA418514','liceo classico','DUGDON96E35M468M');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4I','VKSF672045','liceo musicale e coreutico','USGPZK04P22P361H');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5NN','HOKU232363','secondaria di primo grado','HDPRTE47T00B859N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5HV','AWSB463953','secondaria di primo grado','YFAMBM87D51W928X');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1M','MIAL404804','secondaria di primo grado','YFAMBM87D51W928X');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3C','EZPN556177','primaria','YFAMBM87D51W928X');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4JL','BBEQ642750','istituto professionale','UNTDAS08E05B938A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3HO','SRQR279989','liceo musicale e coreutico','LLSIOT00A46Y603P');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2DN','SRQR279989','liceo scientifico','UNTDAS08E05B938A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4RD','SRQR279989','liceo scientifico','UNTDAS08E05B938A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2Y','NOTU391188','secondaria di primo grado','ADSUZW22M83H172G');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1TC','MBWW975753','liceo scientifico','CWROAP61R21G894A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1O','MBWW975753','liceo linguistico','LLSIOT00A46Y603P');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5Q','MBWW975753','liceo artistico','ADSUZW22M83H172G');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1Q','MBWW975753','liceo classico','CWROAP61R21G894A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3OW','GUEI411177','liceo linguistico','CWROAP61R21G894A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5UI','HLWO539091','liceo classico','IBPIIS16E50O122J');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4L','IEAH194505','liceo scientifico','GVRFRO88B93Q110L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4E','WIIA630130','liceo artistico','FBHHWG02C17G263A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3U','WIIA630130','liceo musicale e coreutico','GVRFRO88B93Q110L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3TL','WIIA630130','liceo scientifico','GVRFRO88B93Q110L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1UQ','WIIA630130','liceo artistico','BMGAWK81C56O667L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3KS','WIIA630130','liceo artistico','ZIWHNM51P40R797R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1DX','WIIA630130','liceo artistico','JEKHSI66P11M866Y');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5GR','MHXA724008','istituto tecnico','VKRVHR71R56U730E');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3FX','MHXA724008','istituto tecnico','FPPJNP78E81M319E');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1PN','MHXA724008','istituto professionale','ZIWHNM51P40R797R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5LD','MHXA724008','istituto professionale','LLSIOT00A46Y603P');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1RI','ZQZP900436','primaria','GQJVMS17B24L320V');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5VT','GOAJ212604','primaria','CKZAOU12B48X018E');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3ED','GOAJ212604','primaria','WLNDXV91T54V205W');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5PF','BZNS539157','istituto tecnico','WLNDXV91T54V205W');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1LI','UWFV740811','liceo delle scienze umane','TBICNR11E53H203J');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4JG','BZNS539157','istituto tecnico','TBICNR11E53H203J');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5SF','BZNS539157','istituto tecnico','JOASUU28E49J051A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4JW','HIVR897611','liceo delle scienze umane','JOASUU28E49J051A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5U','FUBE410934','secondaria di primo grado','LOOVTD68P73G143R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3D','XYMY525868','liceo musicale e coreutico','LOOVTD68P73G143R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2D','FHWR698912','liceo artistico','LOOVTD68P73G143R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2T','JAMX532624','liceo classico','OGECZF66T21M669T');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1WH','FHWR698912','liceo scientifico','OGECZF66T21M669T');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5B','FHWR698912','liceo linguistico','XQOTPQ07R92H554Y');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5X','FHWR698912','liceo linguistico','XQOTPQ07R92H554Y');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2C','FHWR698912','liceo delle scienze umane','XQOTPQ07R92H554Y');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1AM','LMBB683668','liceo classico','GQJVMS17B24L320V');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4B','LMBB683668','liceo scientifico','GQJVMS17B24L320V');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1K','SCBE327866','liceo artistico','TNHPNA50R92H187B');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5L','SCBE327866','liceo classico','TNHPNA50R92H187B');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1G','SCBE327866','liceo artistico','CKZAOU12B48X018E');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2K','SCBE327866','liceo artistico','UAKMXP75E05S955Z');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1R','SCBE327866','liceo artistico','UQHIJJ60S20T115V');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1OL','EUED094664','primaria','OCYVRS58E04A751C');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5Q','FUJK032756','istituto professionale','OCYVRS58E04A751C');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1O','FUJK032756','istituto professionale','OCYVRS58E04A751C');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3I','GJUY873925','liceo linguistico','JUGZVI59S77B765Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2HU','GJUY873925','liceo classico','UQHIJJ60S20T115V');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4VY','GJUY873925','liceo musicale e coreutico','JUGZVI59S77B765Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1I','EUED094664','secondaria di primo grado','UQHIJJ60S20T115V');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3H','ONEK452943','istituto tecnico','JUGZVI59S77B765Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3T','KVOA826650','liceo artistico','NGTGCD89A47K654X');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5L','KVOA826650','liceo scientifico','EBMXRG57P16Q638Z');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4T','KVOA826650','liceo musicale e coreutico','EBMXRG57P16Q638Z');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3GX','KVOA826650','liceo classico','ACYPTX60E31R882J');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2CM','KVOA826650','liceo classico','ACYPTX60E31R882J');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5G','EUED094664','primaria','ACYPTX60E31R882J');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4C','DWGN995148','liceo classico','CEYUHP32L12Y330Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3E','YTPQ300936','istituto professionale','PWTFEF04L29J384R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3G','DWGN995148','liceo linguistico','MLRIVQ80P37S393A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4AQ','YTPQ300936','istituto tecnico','MLRIVQ80P37S393A');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2R','DWGN995148','liceo musicale e coreutico','YYQKIF33T51U379R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4HL','DWGN995148','liceo artistico','CEYUHP32L12Y330Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4F','DOBZ860217','liceo musicale e coreutico','WUFBIQ64M29A460N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1W','YTPQ300936','istituto tecnico','CEYUHP32L12Y330Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4EJ','YTPQ300936','istituto professionale','KXNRDN52H33J400D');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5N','DOBZ860217','liceo musicale e coreutico','KXNRDN52H33J400D');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2P','EUED094664','primaria','TMXCKT42M84Q353Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4L','DOBZ860217','liceo artistico','TMXCKT42M84Q353Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1GM','EUED094664','primaria','TMXCKT42M84Q353Q');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1II','YTPQ300936','istituto professionale','DLTLKB62T74N098X');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4V','EUED094664','secondaria di primo grado','NXEPXD09R23A220L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3Q','DOBZ860217','liceo artistico','NXEPXD09R23A220L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3X','DOBZ860217','liceo artistico','NXEPXD09R23A220L');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1Y','XUMZ640083','liceo linguistico','SKQMAK14H52H621I');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2Q','XUMZ640083','liceo musicale e coreutico','SKQMAK14H52H621I');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4F','AIWW543193','liceo scientifico','AQWFPJ89H47S875X');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2L','JEPG949935','secondaria di primo grado','WUFBIQ64M29A460N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2VC','XUMZ640083','liceo artistico','WUFBIQ64M29A460N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3O','XUMZ640083','liceo delle scienze umane','HPFQMF68C64X136S');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('1K','IQYU292364','primaria','CTKYLN81L14L920N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('3F','CKGL041500','liceo delle scienze umane','CTKYLN81L14L920N');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5U','VMVG538918','primaria','MKCILE63S38O259R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('4RQ','ZUVV082123','liceo artistico','MKCILE63S38O259R');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('2PB','YFLO985733','liceo musicale e coreutico','DUGDON96E35M468M');
INSERT INTO "ortiScolastici"."classe" ("nomeclasse","scuola","ordinetipo","docenterif") VALUES ('5L','ZCLA418514','liceo classico','DUGDON96E35M468M');

---

INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Botrychium glabra','Love Chintz','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Adiantum jaempferx','Jak ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Void Clover','Blood Horn','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Lavatera aquaticum','Love Grass','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Tropaeolum coelestinum','Kathurumurunga ','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Pyrus bipinnata','Lime ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Bellis pulchra','Garden Variegata','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Pyrus malus','Ehala ','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Amelopsos wallichiana','Banana ','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Kalmia caprea','River Thistle','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Kadsura dracunculinus','Beli ','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Bellis cordata','Thorny Poinsettia','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Rosa numularia','Satinwood ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Drihhoot','Snow Daisy','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Adiantum velocis','Love Chintz','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Scutellaria intergrifolium','Blood Horn','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Meconopsis hysspoifolia','Thorny Bite','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Antigonon numularia','Goat Daisy','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ourillum','Ananas','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Geranium eychlora','King’s Geranium','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Pennisetum germanica','Pink Boxwood','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Restoration Sugarplum','Love Grass','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Solanum melongena','Germ Itchweed','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Korary','Cocount ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Hordeum vulgare','Purple Rhubarb','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Rhychospora quinata','River Needle','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Paeonia variegatus','Sheep’s Rhubarb','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Arctosis campestre','Sheep’s Freesia','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Frost Brier','Crow’s Tea','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Eriocaulon aquaticum','Night Itchweed','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Vlanium','Echo Flower','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Daucas carota','Apricot','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Eucommia recurvara','Dream Root','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Eucalyptus siderosticha','Snake’s Needle','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Bamboosa aridinarifolia','Garden Fern','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Spodiopogon prunifolia','Bee’s Cacti','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Lobularia typhina','Angel Flame','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Elymus crassipes','Passion Fruit','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Trachycarpus pinnatifida','Promoganate ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Twisted Clove','Toxic Twig','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Pygmy Polkweed','Dusk Miller','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Osteaspermum miconioides','Scorpion Herb','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Palsoes mungo','Kon ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Musa paradisicum','Palmaira ','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Cleome umbellata','Horse Head','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ruellia persica','Dream Cane','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ficus benghalensis','Halmilla ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Tropaeolum celere','Spike Hood','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Lavatera aquaticus','Blue Root','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Murraya koenigii','Blue Wheat','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Gypsophila paradoxa','Garden Variegata','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Sacred Bitterweed','Fire Ealmore','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Linum sagittatum','Doom Horn','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Habenaria gardenii','Glitter Button','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Zelkova asarifolia','Sun Eye','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Kadsura dracunculus','Mango ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Hakonechlao rosea','Bee’s Ladybird','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Poterium opaca','Dusk Ivy','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Helenium fulgens','Goat Vine','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ailanthus latifolium','Halmilla ','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Coriandrum atlantica','Toxic Twig','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Solenostemon punctiloba','Queen’s Hibiscus','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Glycine max','Silver Lavender','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ulmus edulis','Laulu ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Achras sapota','River Thistle','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Parthenium transmorrisonensis','Guava ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Carex kuisianum','Snake’s Button','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Setcreasea rubiginosa','Honey Hibiscus','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Shortia maritima','Woodapple ','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Lindera piperita','Ipil-lpil ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Fothergilla prunifolia','Beli ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Psidium guava','Witch’s Pepper','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Citrus Limonium','Sunflowers','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Paulownia hexagonoptera','Snow Daisy','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Adiantum brutus','Dog’s Daisy','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Botrychium pulchra','Toxic Twig','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ananus sativus','Sheep’s Ivy','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ocimum daconitum','Bee’s Peony','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Acer rubrum','Honey Hibiscus','sole-mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Santalum album','Garden Variegata','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Aucuba stratiotes','Beli ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Yucca spinosus','Blue Fieldcress','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Davidia casiinoides','Bear Herb','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Setcreasea','Angel Crimson','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Vitis refinerve','Kiwi','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Curcuma longa','Snake’s Whirl','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Citrullus vulgaris','Night Thistle','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Scutellaria','Angel Tongue','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Poterium','Snake’s Head','ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Incarvillea rotundifolia','Red Poppy','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Crataegus platyphylla','Poppies','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Spodiopogon','Dragon Forget-Me-Not','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Dodecatheon auriculata','Snow Plum','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Restoration','Snake’s Pepper','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Trollius sinautum','Ehala ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Lindera','Water Saffron','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ulmus','Palmaira ','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Silent Hogweed','Cocount ','sole');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Ugobgoss','Blue Hybrid','mezz''ombra');
INSERT INTO "ortiScolastici"."specie" ("nomescientifico","nomecomune","esposizionepossibile") VALUES ('Incarvillea','Snow Plum','mezz''ombra');

---

INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('8C2erIuMdDpoCUzJI','HOKU232363','in pieno campo',5966.46,'G5m4E63WxMbqKG0m5bvR6G56ffZ8a',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('CAgm','EZPN556177','in pieno campo',4478.75,'vwSHO6R4R',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('p','JPAQ950880','in vaso',158.61,'wmq7s2M4RwuTL6cyiumKZ3G',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('lXEcB6tUTfZxaN0iDO7','BSTQ143737','in pieno campo',9.62,'6FpqaDAF2A4D1PIObjpVDbDU',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('5WkgK','KRQO221401','in vaso',620.56,'Vqwsg2An7EiPR5YaU4upiu8cVxS71Z5T5W',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('3tyCswf5Ih','CCVM209965','in pieno campo',35.63,'KA4rnDFPfLLFqZyXJMoOge1LEsv',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('d','RMWN141739','in pieno campo',6.4,'gVILPJmtkYdjFlKXMoA0gD',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('5','FUQG557186','in pieno campo',8944.09,'sjxc0tsecDMAdIGjPIM',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('TStwUlIDgMmMRdEy2','INNO159766','in pieno campo',6.42,'jjV3Ebm0LtqCM4C0',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('C','ZUVV082123','in pieno campo',1629.32,'TReB5Npt8ZqQjtVxQnpETfZZ76DGnaKDKfHn1',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('4gs0','SUMC912647','in vaso',96.68,'ePhva0mEe2Cj',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('052rC','BCAT073910','in vaso',9.92,'FKf8YTJ7W7Ia62lHYc2nWyFe512GHP',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('i','ISFN695651','in vaso',80.16,'VyaQtPEYa0',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('fzkF0R57JDWGU1n','VWVI840013','in pieno campo',56.71,'1wC0GQyNX',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('V','REXE231415','in vaso',326.82,'SpSuc5iqowVbFZMJiAQLzw7T',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('IWCd','AMMO276040','in pieno campo',8.73,'Z80K',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('pwSF6XP4wDI','VKSF672045','in pieno campo',769.68,'w7rwmgTiOBJVdGNHc0tCBv2',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('bHFJd','GWBA292430','in vaso',4.69,'BkgJVwt4Zn7FniYiMbcaMlbMfwUWsfQnXyZUO',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('DF4HeorzKF7IzgGPz','SRQR279989','in pieno campo',697.64,'4dYR7mYUl8CcDLqjDun',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('Mtme2hqvyLeK4Zlpp','JWWO474553','in pieno campo',57.13,'Ktzu1Tt7btAs84BDv1c1',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('sEipr8MQ7fZoWqoKT','BZQT297971','in pieno campo',41.58,'R8MtukvrcXzyRFs8wvMDffetivGrjTb25Ng',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('c7kcVI1Xkvgfz4mPX','JBFN281006','in vaso',1153.38,'evBfrR7jkrBzfVnzeub6K1A',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('U67RtW6iscR2U7G','VDQI437671','in vaso',5904.13,'NOIH84xgky6S',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('Tx8xke','THZF525024','in pieno campo',4346.26,'cwrj3g05O8V',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('sC','GKUP430475','in pieno campo',245.71,'5',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('hIJP3DcpYTbJnYr','TGFE250127','in vaso',242.24,'6KwE0Hro83fApsCOMfJ7mRzw2ZT',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('NhuR7u661G','FHHE320565','in pieno campo',90.98,'2DrB4Io3Rq70rpGbMDttypp0C4JKz1jngnA',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('A','MNOZ485526','in pieno campo',18.17,'YwZkqZAJeYbeTsAP0fKzGgaWL08F8Fn4Bsv',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('2V1gzENvf','MLOW676778','in pieno campo',50.56,'r5pFUpcffRoyx0xB24mqOLE8ZDszqcWDbs1SfVd',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('RQ','SNVI325308','in vaso',63.41,'gwkmTX181Nx',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('i1AIWFlf5lDKa2h','KVPL632920','in vaso',870.62,'J3jYwgVlSc6bGu6ml8M48rvEzsrkuPCA',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('XwM5dDCyTZzSlnag','CSYV411279','in pieno campo',2088.21,'IkqrMqHJG3gq0sc5',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('f6eLZh4ouh','IRTW189459','in vaso',5301.85,'do4JCV4AZVTUUamH5OHAWHOpVXbD',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('QgrW','GEIQ914585','in vaso',205.77,'Zl777G',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('IJ00mKx2fCJ7zuj0han','DTJI265710','in vaso',8240.12,'2mGUBWRXWALiO6HRK87',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('ZgeKFrQ4s3KjL03CbaE','WTUV630262','in vaso',69.25,'buXJvpiSmlRKiyUxsKz5nzqADaQAqsTEygAi',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('6boTkgtkhojXpZ','PXQL972884','in vaso',1857.59,'zNNTOnYKsT',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('6','WZES421832','in pieno campo',6.06,'3XTH2',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('UzEJ252jy','VRVD085844','in pieno campo',3.23,'iy',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('jN4dMzObN8QxxC','YKDB001413','in pieno campo',2.4,'3WUaiuGDdaYrMb2',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('1rhDTJApCR','HNVP731485','in pieno campo',599.45,'aoOkjapGMWZMAw46qm1UcH',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('XsgSqf2x1J3Nt5sfC0','WKML530476','in pieno campo',23.24,'R',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('R','GBWG223911','in vaso',8.41,'5Fw',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('zjA8hcOttCQaWvuTOCD','ZCZT349977','in vaso',356.18,'EzMp1sMvrIluADOmqO31y144LwlIeeHx',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('ZSxr5dKm','KTTL410818','in vaso',8.17,'WzSrL2Agu2Az2jXaUcaEw6Wk2pgTYX2L6fSNaE0Q',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('o8voyKbPanjLgOrz','SQCY660654','in pieno campo',8.22,'d38uRQFYV6doQOYRInN',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('Noku4qUv5EEPU','ACWP080908','in vaso',9.11,'d3fPyunzPjMT30Xqpa0R7RId7WG6zTgTW2OC',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('ZjPLQN','EELG032874','in vaso',2558.95,'YE1bvNWIvoNRq2fAm5OJoYFPw',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('RriCZ','PFVM375972','in vaso',870.22,'N1lA',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('cU651HyQi62v5O','PWNE304765','in vaso',326.98,'OLEDrQKVH5Lupn',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('oHD','UUNP075389','in pieno campo',46.58,'nw7Z3zhotbJvr6rPgwFPH6gDBA8',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('AB6ETLBDaGoNooeYPkv2','HRXF060699','in pieno campo',95.81,'tHJrGMHqcIXLM5EVQnCJZT4YxlJSaHx70mrR',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('fRpQbc38L','DYCA216233','in vaso',456.57,'Owa8sshghlfSZgSyW2aN6hcRgF4VK3OunN',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('7rhsCHgamPk11KCW','DQPK500518','in vaso',133.86,'btvx8gjjrInCvDX8hcSFgIst8JQeyQxzAMXco5',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('WlGM','AAST674606','in pieno campo',665.05,'QXRACXnNOUcSOpwbS3',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('VXuBTGXlf2','FQQK756040','in pieno campo',65.16,'AyCFXWUInnJGELY10lc2cuozfNUWtHNL',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('z','HSWA474382','in pieno campo',179.85,'rf7JeUNh6rltXvc',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('MT6iqxX05','SABL045541','in vaso',394.99,'mPN4rBXrq3HBZATdat8T6vdub7gLg0o6',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('24TZA23HvOpRfhgyt','ZIXZ334053','in pieno campo',3154.47,'Fjub2mlNSxWLFcYsusSRUQMw',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('lhy25DIjEW','FUSM821096','in pieno campo',57.65,'dtRHd5',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('z8pj6tOwn6unyEOOY','CDQH805186','in pieno campo',36.14,'OUEaYDv4leaIzMYoD6fPce',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('hH3DfpR','ZAVT148564','in vaso',681.37,'4vHOLDFTx6zoxWI5V67c',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('XxQuXMXo4','BCBH851940','in pieno campo',250.38,'rW3q1Xk8JQp65noHtQzCnZotVIx',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('E6fN','FZFX222504','in vaso',719.13,'Bp246KI',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('OwyPAJKIwPD8nGN','VKUA442722','in vaso',9.23,'JHUSsUmLGxR0BAbK1wSXk8pq',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('VY','HNNK729126','in vaso',5102.96,'yuK6JeVzUdzbN',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('6obUxHO','VKHU121609','in pieno campo',4.72,'nBr8JW10QtjLT',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('EJU','GIVO097060','in pieno campo',1182.57,'0VFhtW3a1H',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('CqoWiUAb','GXFL556532','in vaso',9.13,'b5ZJYdTi5xT',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('ndjOyQE','PJQQ407799','in vaso',3569.04,'4IF0EKnCg26nD4uy8L3Ipuw',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('5G','NQRH824754','in pieno campo',8660.28,'XApeCgBlyzYqKT',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('oi078L','GJUY873925','in vaso',270.48,'rvLpWK1wm',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('GYMIc2gWF','QCFR394346','in vaso',6579.57,'SNRi4iB',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('X','NEEH124972','in vaso',4.03,'gLtGr7S',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('fwJeE8h4jgaJ5w0','ZLSZ838521','in vaso',90.99,'HX',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('vvIvabdZKFLkWQh6nu','RPMO358195','in vaso',98.35,'PxyXNBChZJ5JerYod2gZuANzw88n1aLtz',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('3ZVtl','OGOK355489','in pieno campo',594.45,'onVrx0TUy5cBjNHd',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('xyNG704CwvHLaVDNBN3','JBUN991082','in vaso',961.18,'k1PHXw',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('SIroeUVFsrhDgDA','JIXS270384','in pieno campo',402.79,'fn6n1FOu1rg0E5msQ4wQwEyjHZut5vI',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('NOeutVRTPS1e','CJRL744606','in vaso',40.92,'QWTVqKc771q0DjJx',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('hX64PicA','LMMJ451918','in vaso',492.51,'dwYvCp1liVTLr',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('Rg','OIFH804462','in pieno campo',23.81,'20K',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('VpW6BD5J4q','BYMN501822','in pieno campo',87.13,'NY0zkycaxP',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('A6oxZxqBuDjL','CTCB566675','in pieno campo',5.25,'EYxxT3PFSxSd13SHaKTDGwwHnoc2YPsHaxrJ5a',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('E8PUBXqMS','QROP953699','in vaso',9544.57,'kg82d',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('KOXqeC8MV8BW1dQ','QWRN840198','in pieno campo',15.16,'S',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('2','DDOO437893','in vaso',6005.91,'OUVvDIyDQidlAqtZJ2kB6NjL7n6VNePb',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('nMfMvQ','KYDF778775','in vaso',6.25,'xq7xkaZ1q60jxpvjCYR8pmp0FsFmMR111HniT',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('SxyqXlzYFVs','MWHS497547','in vaso',29.21,'ODfPbusKnft12efYB',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('kg6LkNolHdMkMmI','QTTY479485','in pieno campo',6241.27,'4Ofgcw8cCy5EIycha4JvoyKZvJBZdDi',True,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('TR','GUHH436987','in vaso',9.75,'KOnMGJBg6jtpI',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('7','CEQW851577','in pieno campo',74.38,'C',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('I','AQBE496850','in vaso',80.76,'BlrNa',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('E','BXEX620534','in pieno campo',73.89,'AuBKHDCMz4XigoDHyVq6xKzVrRINVpgeLAtp35',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('aD0PU','GEMA644483','in pieno campo',4004.29,'fcAPfnPuwW1qHW',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('kb7vwkN3a','YCND315491','in pieno campo',785.57,'VGPZDzL4DoPiMkMxVFLlD8lKi4k',False,True);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('R12','SJTD809402','in vaso',5.78,'OvCusNh2c7z36yJPS8d1BH',False,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('v','JEPG949935','in pieno campo',556.42,'XFmQrVgQR8TBB1BS4MqkfBKOHrOZXXHlQlbSVIh',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('yjIZfjkYmIEx','VJMB342548','in pieno campo',8728.9,'aJWD6GzfmZ1x',True,False);
INSERT INTO "ortiScolastici"."orto" ("nomeorto","scuola","tipoorto","superficie","gps","disponibilita","pulizia") VALUES ('HgsTXJFa','VING996466','in pieno campo',4183,'0QiUToTRmA3TqSDDGstQMsEgBzFv',True,True);


---

INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('sI','siTd','8C2erIuMdDpoCUzJI','HOKU232363');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('LTtWeqJPS','Tdwi46O5lHKsVwUxHaG','8C2erIuMdDpoCUzJI','HOKU232363');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('zm2GQodzPt60ttOQ4eXd','44tHXDXl','8C2erIuMdDpoCUzJI','HOKU232363');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Nsv1O','SMLoeHAGNk7d6DCjr','TStwUlIDgMmMRdEy2','INNO159766');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('LoqukZ7IWHzg5oxbc','qcALpN4f61peW0H02D','V','REXE231415');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('R','qXFgYDWoj','V','REXE231415');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('0rpnvJ5','1','sC','GKUP430475');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('XPCRY','G67','sC','GKUP430475');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('hArA8O','KdoSoGKdqIV7vnXtg6w','sC','GKUP430475');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('l','sgMvsiu0n0zc','f6eLZh4ouh','IRTW189459');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('wlEhoMg8PZrIegNf','JgpAzzntbx0sWaL','f6eLZh4ouh','IRTW189459');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('K','gCULIYty4rhB','QgrW','GEIQ914585');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('YFfa6vrRMZ3a1vBdk','G','QgrW','GEIQ914585');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('T0ve7qI','N','QgrW','GEIQ914585');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('o','Bxfk24dGaA','XsgSqf2x1J3Nt5sfC0','WKML530476');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('RX','BkL8Y7QFnmW','XsgSqf2x1J3Nt5sfC0','WKML530476');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Atekq','p','zjA8hcOttCQaWvuTOCD','ZCZT349977');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('MjbpNz0fHcZqaHuI','oaYE','zjA8hcOttCQaWvuTOCD','ZCZT349977');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Q43u6ewCx7ZcTGkVXa','Fb2QeLRrW2qq2pJhyC0e','ZSxr5dKm','KTTL410818');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('8','vhd4jA','fRpQbc38L','DYCA216233');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('4nNznF4','F1ogOI','z','HSWA474382');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('hHc7HXqod4D','7AsMK','z','HSWA474382');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('jY','aP','E6fN','FZFX222504');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('KR','bTCJS5dfRJgc','EJU','GIVO097060');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('fOqRb0rYMpztQX','PhuDrKu5ez24ltwX3','EJU','GIVO097060');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('bUtfRIP','BCuGaqnfm7ALp','CqoWiUAb','GXFL556532');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('abI3gr5','P4CXjZh7WBPN80','X','NEEH124972');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('p4Mnl4U1szhwr3TI','KiK1I1cfZnPnKwEL','X','NEEH124972');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('TexiYm20PtVAetZJcCm','6eY5','X','NEEH124972');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('AUMZdTjxnSbne1fsV','MxFgToTem47l0ZZXI','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('zM0jt87seHf','E2tmE','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('QiLP7g6Jqz8WcxyUxfh','wl61eiCZhpw72Se3RfrQ','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('ODCs','ivBVMKbiPAELJl','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('yJJ58U','5jf0DmaaTY3Col','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('qqbDnx','jE6Mmm','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('8sqETosx8','z63rgfSGUg4ehSZ','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('euzxZfscWsyNDPj','Lo6z4W','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('3F2Wz5Igz2jjgwqvk8','NMbf007KOi0NWZ7','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('3xWuZTEvGS1FRdPLifRU','y','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('tHtPI','xAT','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('JOUP','N4rsc','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('xcNOuhvHC20','GDmnhmT0berLShOo','3ZVtl','OGOK355489');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('J','CMwuz','3ZVtl','OGOK355489');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('fLK3zynOk','BmlYBVu','3ZVtl','OGOK355489');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('qn4x7kxJ22dtv0','Jg','2','DDOO437893');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('vbeFen','eIoOqQOduQX','aD0PU','GEMA644483');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('DEKgN0eXTNZIS','1','aD0PU','GEMA644483');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('C2z','L6vHhizeIo0fpY','v','JEPG949935');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('oMFecRcMOCpVI7Wkg','PcQskN0UAU','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('H7MD14UigsaK','usJ1V8qKJ52SJ','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('C8KFrI','dv','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('FSgxpirmZvSa','sK8umyR72N3Fqym6I0Z','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('GmDHdDioTfXuF1SW','OCb1','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('WXRz3fpHB3qmBe5zFWC','BvrR60lm3tyzklCPcu','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('bDOj3wCllutauaMOtpD','A2zcL3xBPlm','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('nbVu28X4QQb','otcTaxIp','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('dkdi8jqXkKiOWHlL','vTK2ZV4jfQPDZd','HgsTXJFa','VING996466');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('SuK','pFGD7YdkSLT','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('qWdWeBb8MecmEEs','s3lU','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('F6FQYofU7L','SKaq71HV6ihI5uSAc','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('7AWHbeg','cl2RbD7jf8g6CfFBd','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('zI1Md8kmZsFA','O2xtBOwVGT','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('GSHcL','yPrSQjIozmKarREQ','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('ieCSEtrQArB','jIVDtpVjIw8BvlngH','v','JEPG949935');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('vxo','Bof','v','JEPG949935');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('8FMIaG','zYGcVX6nrM5Str8i','v','JEPG949935');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('cM','wgaunyMzlL','HgsTXJFa','VING996466');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('MpKhKVsZgQXihX','1VWQxO','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Teh','m4w','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Vkex','YVMbbFT','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('0J','OM5','aD0PU','GEMA644483');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('em','D','aD0PU','GEMA644483');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('5NOXx','Q2NSFk1wNBZFNFdp','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('LSdHS','zRg3ENi0','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('mYVOu','WER','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('y1UzLzjVUY','l','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('S7i','4Us5a3','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('2Taftvl','JwqH','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('iAS8hRDyFQMNratOY','PmlSiyRD6ZZk1PS','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('a','z4bK11qVpIEJeocJ0','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('a0zx3','ODq','HgsTXJFa','VING996466');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('pBOhnuilM','DZVxDvjw2WqYMbi6f','HgsTXJFa','VING996466');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('m','lZVws5pq5W','E8PUBXqMS','QROP953699');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('c5ippLF5OoaNkW','gtmQzn','E8PUBXqMS','QROP953699');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('H','mMqDR1Um5m7fiLmCxr','E8PUBXqMS','QROP953699');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('IzIFjVWvn0uffW0R2','hy','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('LFPJliU7zUjMxyet6aGZ','g','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('aQV4Vh3Di8','5xzQWDANfUwPGq2d','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('q3RVlThDrBXf','Qy4Q','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('K7nDQBlUPgx3rs','Qvx4Z0wfkpLaF2grfxu','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('5jjwvmYmiHl','z','kb7vwkN3a','YCND315491');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('ybchkDaaRbdnukL2aMCe','LHHqzkTkCmrVN2e','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('yIV2RCLSPqsJPl1Zfyw','zUYE','E8PUBXqMS','QROP953699');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('8wn','jchmOpIRs2I','E8PUBXqMS','QROP953699');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('rVNnIklSRKHEleC8M','Zs','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('n','U1Gz2cdlez4jc0VTI','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Sp4nMA','IQqVNEt6mHGfAREItr','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('7vPRpmhDMyTyus','i8XK5wGA','SIroeUVFsrhDgDA','JIXS270384');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('iuDdGQJ6GHUCix67YisC','2hHgxq','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('NINKGtfROEMz7yi','F','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('BHboJa','qlWyCo17b4','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('BDd5Dyslt3cXx6zT1','a7MJdlAVTjG','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('QOosoqoHp','w','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('UTa','powOJ2dVdTPK','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('AqkgZl5cQVwAB5','3Mcck','KOXqeC8MV8BW1dQ','QWRN840198');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('UcpJnwiKsxuwLlezbq','dhgAweNwu20YFR','KOXqeC8MV8BW1dQ','QWRN840198');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Oilmobkkp1Jx61JrJhQL','AHVHIF','KOXqeC8MV8BW1dQ','QWRN840198');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('6ztTi','p','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('cE6OTnsPpxugRU','1','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('p','ehFv2rxBdYboQ','3ZVtl','OGOK355489');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('7BU1','wHpHc','3ZVtl','OGOK355489');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('mcw1AzUfoP8HsLWbiAD','5hWOx1P4','KOXqeC8MV8BW1dQ','QWRN840198');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('j4WzWS2e6fAovZz','6udjSqZOFp8','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Ir','OTK','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('I','h4xSXIixC','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('SK78VVZqZYYTbq0NN','VXI','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('aXbluZKf','uyASJabief','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('GRxZuqauD','pHnh56i','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('ttqrJgB23','34bWNTBzbTA3AzaS6','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('sNG6QsWUN','1','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('VR5VoY74hSt6qi','e1PhFj','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('WOCmSCU41M','N','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Uwcq47MJRRbNqw3z4','Wt6rKISuQr','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('nacDW8','4HgRsuuu3yIRJcSHI','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('LI','t6BBivxSFMMr0ms4H','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('DS','avDQq','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('PPpJ4th0uTNUfaFs','xaf7nGfM','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('fxELp6HxG8Z5LuHuya7','1ltYfORBDK28XzbkHh0','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('isrCcPuq6clxp0tJxA','mjIEdpt','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('ngrw','HOlG','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Yv5rR5','PhxAvijrHS','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('w8','n','kb7vwkN3a','YCND315491');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('w2YVOGmf6GN4OzxCi','aAo','kb7vwkN3a','YCND315491');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Cwdd2w','6','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('avvrd5J5LSDHUgTJK3A','H80JFNM7','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('EsouT','dDO','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('8xl6i','0Mf32Rv6VMB3Sjt','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('pcx8nrW','f7SsM1W','KOXqeC8MV8BW1dQ','QWRN840198');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('z','ivsM2s3C8AsN','KOXqeC8MV8BW1dQ','QWRN840198');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('IknJSTi1sQDMd','fDyDV','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('ouoM','KGYBbQtVpxuHun','R12','SJTD809402');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('elFvPQczdyRDn7','LG7qfRKiOXkIiq','3ZVtl','OGOK355489');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('pSJaKEda','JrcNj56vRsB','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('eo3cxDPJbf4R','MkpIBXiyL7QNV7X','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('61gWaXsMhE04mX2YRj','n6j3B73yLOKgdJEIWrR5','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('jwbB8Ghn2HlRpC','amVsVurN','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('W','jwauL','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('1fJH','I6Lm','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('71qBkCJpH4UfDMta','AsaQ6XxR55c6N0z2qH4s','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('f1pG','6WeYEpEWSBFf','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('tSAsMej2swMX6','j4NDeoPE','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('keKKNApzK3stM0AsZJbS','owVxHlBRtyF3z7Qe4Z','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('peV','cZqP2B1HiHIe','yjIZfjkYmIEx','VJMB342548');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('H1wu6NNpQpHq','B03pyS','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('14M2','lZkz','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('dBlj0w','TK4jNIL','hX64PicA','LMMJ451918');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('fSn','h1RHM2JWDp','A6oxZxqBuDjL','CTCB566675');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('fR1jA46','C1Vdf4fpe','7','CEQW851577');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('mBj6VMJ0TJ0Iw6CU','MxckVUUfYnlK5','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('zMbem2W6FtANOIr','VRX7VjJ1AL','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('J6hHAAc8LKoo','5LQDfG6okpParQIog','E','BXEX620534');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('MPM1RYLhOD','M','kb7vwkN3a','YCND315491');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('3w0oHVkKCGOjJ2K','iswfVPHYKkCsHM','R12','SJTD809402');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('qTKxgOknc','GVHNF2UKO5','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('kHSaetQBO','eW8u6757dI3zb','SIroeUVFsrhDgDA','JIXS270384');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('qyvS06SUlSaAblMs','OSrrKd2','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('goMCr6zW0vF','d','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('XMKOgt','RyURO60X4CmbVy','TR','GUHH436987');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Zeqo1wHQb8bEuBcv3','ERb6Hz','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('KOMG42sfGjerC','U','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('AmtQp','HzJjjXhfDIXgKiD6bW7p','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('rkndlJhlacb','VV302YvBJ','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('HLtX','Lw8PXKh','SxyqXlzYFVs','MWHS497547');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('eaJ1','6oKYdx8oJR6IuC1E','SxyqXlzYFVs','MWHS497547');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('xFx5XhSyScTcIPv','SCjGxeb1pQpDQki','SxyqXlzYFVs','MWHS497547');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('MyNQ77VR','CAMRdCvN5qM8','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('Xh2','lctFof4awy','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('uHCCkU','aOwZbRzDdfyr','kg6LkNolHdMkMmI','QTTY479485');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('wkCzo3hq5WFpzYhYaU','DN3cNgLO3Sm6Ux','v','JEPG949935');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('5bIae6ALpbfhi','BNv5q0PXyavqbT','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('D2','77kCZNi','xyNG704CwvHLaVDNBN3','JBUN991082');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('7kI','BCL','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('g','2Yd','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('0u8CtArM','pwup','NOeutVRTPS1e','CJRL744606');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('8dDFEBWoAQd4jkeRuLc','sKauHaq','2','DDOO437893');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('aatm4bEV0R','QI7xMdV7j7FuVsR4ev3','2','DDOO437893');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('deb','AsICY3xxhBfhj6A','2','DDOO437893');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('IiiDSrq5ScIzcKTevpn','6YyME8fDf','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('GjcPgZ','HpetHhBLEbWBfuD2sA','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('WLdy58CzFHwiZNjZfUx','j50jHy','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('sEORHt','MNDBKFaYV5wxhRdY6L','v','JEPG949935');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('aB8F','dkcDlJo7BBFP0pB','HgsTXJFa','VING996466');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('AvrahEks','8LtoRhbnut','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('75oohGrIuqnPwBSn5u','CqZKXyJ','VpW6BD5J4q','BYMN501822');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('pfTCwFdY7wl8ZB4uxd','t','I','AQBE496850');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('7WH47hkIHbHuLkz','R4PpkFQ7w4gPTk','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('3OwITmbHChYTPvhu4','F','vvIvabdZKFLkWQh6nu','RPMO358195');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('qZyqHzh5aTF','75B3qVe','Rg','OIFH804462');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('cf4Sf4x75ErMPB','LX7MQrF7eYkfXUAD','Rg','OIFH804462');
INSERT INTO "ortiScolastici"."sensore" ("codiceserie","tiposensore","orto","scuola") VALUES ('iLMIbZ','V7c3jvoJEk','Rg','OIFH804462');

---

INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (1,'p','JPAQ950880','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (2,'p','JPAQ950880','bio-stress',148282);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (3,'4gs0','SUMC912647','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (4,'4gs0','SUMC912647','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (5,'8C2erIuMdDpoCUzJI','HOKU232363','bio-controllo',579330);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (6,'4gs0','SUMC912647','bio-stress',579330);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (7,'4gs0','SUMC912647','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (10,'6','WZES421832','bio-controllo',964856);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (17,'5G','NQRH824754','bio-stress',989865);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (8,'5G','NQRH824754','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (9,'5G','NQRH824754','bio-stress',950563);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (11,'5G','NQRH824754','bio-stress',268171);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (12,'5G','NQRH824754','bio-stress',738585);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (13,'5G','NQRH824754','bio-stress',37574);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (14,'5G','NQRH824754','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (15,'5G','NQRH824754','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (16,'5G','NQRH824754','bio-stress',704301);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (18,'5G','NQRH824754','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (19,'5G','NQRH824754','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (20,'fwJeE8h4jgaJ5w0','ZLSZ838521','bio-controllo',268171);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (21,'SIroeUVFsrhDgDA','JIXS270384','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (22,'fwJeE8h4jgaJ5w0','ZLSZ838521','bio-controllo',898393);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (23,'SIroeUVFsrhDgDA','JIXS270384','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (24,'SIroeUVFsrhDgDA','JIXS270384','bio-stress',939599);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (25,'SIroeUVFsrhDgDA','JIXS270384','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (26,'SIroeUVFsrhDgDA','JIXS270384','bio-stress',757747);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (31,'E','BXEX620534','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (28,'KOXqeC8MV8BW1dQ','QWRN840198','bio-stress',262720);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (29,'KOXqeC8MV8BW1dQ','QWRN840198','bio-stress',898393);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (27,'xyNG704CwvHLaVDNBN3','JBUN991082','bio-controllo',262720);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (33,'E','BXEX620534','bio-stress',413138);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (30,'xyNG704CwvHLaVDNBN3','JBUN991082','bio-controllo',294494);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (32,'xyNG704CwvHLaVDNBN3','JBUN991082','bio-controllo',413138);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (47,'E8PUBXqMS','QROP953699','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (48,'E8PUBXqMS','QROP953699','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (34,'E8PUBXqMS','QROP953699','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (35,'E8PUBXqMS','QROP953699','bio-stress',657188);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (36,'E8PUBXqMS','QROP953699','bio-stress',451848);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (37,'E8PUBXqMS','QROP953699','bio-stress',654283);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (38,'E8PUBXqMS','QROP953699','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (39,'SxyqXlzYFVs','MWHS497547','bio-stress',593725);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (40,'SxyqXlzYFVs','MWHS497547','bio-stress',775247);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (41,'TR','GUHH436987','bio-stress',774334);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (42,'TR','GUHH436987','bio-stress',593698);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (43,'xyNG704CwvHLaVDNBN3','JBUN991082','bio-controllo',657188);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (44,'vvIvabdZKFLkWQh6nu','RPMO358195','bio-stress',370349);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (51,'vvIvabdZKFLkWQh6nu','RPMO358195','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (52,'vvIvabdZKFLkWQh6nu','RPMO358195','bio-stress',638182);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (53,'NOeutVRTPS1e','CJRL744606','bio-controllo',182240);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (45,'7','CEQW851577','bio-stress',475776);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (46,'xyNG704CwvHLaVDNBN3','JBUN991082','bio-controllo',567889);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (49,'xyNG704CwvHLaVDNBN3','JBUN991082','bio-controllo',654283);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (50,'NOeutVRTPS1e','CJRL744606','bio-controllo',504428);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (54,'NOeutVRTPS1e','CJRL744606','bio-controllo',209885);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (55,'7','CEQW851577','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (58,'SxyqXlzYFVs','MWHS497547','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (56,'NOeutVRTPS1e','CJRL744606','bio-controllo',567777);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (57,'hX64PicA','LMMJ451918','bio-stress',582761);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (59,'SxyqXlzYFVs','MWHS497547','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (65,'E8PUBXqMS','QROP953699','bio-stress',000013);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (68,'KOXqeC8MV8BW1dQ','QWRN840198','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (60,'TR','GUHH436987','bio-stress',131452);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (61,'TR','GUHH436987','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (62,'kb7vwkN3a','YCND315491','bio-controllo',131452);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (63,'vvIvabdZKFLkWQh6nu','RPMO358195','bio-stress',269070);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (64,'kb7vwkN3a','YCND315491','bio-controllo',269070);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (66,'E8PUBXqMS','QROP953699','bio-stress',333347);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (67,'KOXqeC8MV8BW1dQ','QWRN840198','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (69,'KOXqeC8MV8BW1dQ','QWRN840198','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (70,'vvIvabdZKFLkWQh6nu','RPMO358195','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (71,'vvIvabdZKFLkWQh6nu','RPMO358195','bio-stress',901030);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (72,'vvIvabdZKFLkWQh6nu','RPMO358195','bio-stress',215774);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (81,'2','DDOO437893','bio-controllo',284351);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (73,'v','JEPG949935','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (77,'E8PUBXqMS','QROP953699','bio-stress',575018);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (74,'v','JEPG949935','bio-stress',132063);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (75,'v','JEPG949935','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (76,'2','DDOO437893','bio-controllo',220290);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (78,'2','DDOO437893','bio-controllo',575018);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (79,'2','DDOO437893','bio-controllo',298780);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (89,'KOXqeC8MV8BW1dQ','QWRN840198','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (80,'KOXqeC8MV8BW1dQ','QWRN840198','bio-stress',736649);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (82,'KOXqeC8MV8BW1dQ','QWRN840198','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (83,'KOXqeC8MV8BW1dQ','QWRN840198','bio-stress',284351);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (84,'aD0PU','GEMA644483','bio-controllo',239504);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (90,'TR','GUHH436987','bio-stress',939062);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (85,'TR','GUHH436987','bio-stress',87879);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (86,'TR','GUHH436987','bio-stress',670008);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (87,'aD0PU','GEMA644483','bio-controllo',688611);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (88,'TR','GUHH436987','bio-stress',245467);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (91,'TR','GUHH436987','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (99,'nMfMvQ','KYDF778775','bio-stress',779546);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (92,'aD0PU','GEMA644483','bio-controllo',939062);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (93,'R12','SJTD809402','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (94,'R12','SJTD809402','bio-stress',556045);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (95,'SIroeUVFsrhDgDA','JIXS270384','bio-stress',422041);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (96,'aD0PU','GEMA644483','bio-controllo',377273);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (97,'SIroeUVFsrhDgDA','JIXS270384','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (98,'nMfMvQ','KYDF778775','fitobonifica',NULL);
INSERT INTO "ortiScolastici"."gruppo" ("codgruppo","orto","scuola","tipogruppo","codbio") VALUES (100,'R12','SJTD809402','fitobonifica',NULL);

---

INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (1,1,'sole-mezz''ombra','03/30/2012','4B','LMBB683668','mBj6VMJ0TJ0Iw6CU','Poterium opaca');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (2,6,'mezz''ombra','06/12/2019','5G','EUED094664','mBj6VMJ0TJ0Iw6CU','Poterium opaca');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (3,12,'sole','02/15/2002','1O','MBWW975753','mBj6VMJ0TJ0Iw6CU','Void Clover');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (4,19,'sole','11/19/2020','1O','MBWW975753','sI','Void Clover');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (5,27,'mezz''ombra','05/21/2009','5G','EUED094664','LTtWeqJPS','Void Clover');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (6,28,'sole-mezz''ombra','09/22/2004','5K','IQYU292364','K','Tropaeolum coelestinum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (7,32,'sole','12/16/2018','5K','IQYU292364','K','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (8,39,'ombra','06/26/2023','5UI','HLWO539091','0J','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (9,45,'sole-mezz''ombra','05/07/2008','5UI','HLWO539091','0J','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (10,55,'ombra','02/03/2015','5UI','HLWO539091','0J','Linum sagittatum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (11,63,'mezz''ombra','04/05/2022','5UI','HLWO539091','0J','Linum sagittatum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (24,85,'sole','01/10/2015','2F','CKGL041500','7kI','Poterium opaca');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (25,91,'sole','05/01/2022','2F','CKGL041500','7kI','Frost Brier');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (26,96,'sole','01/25/2007','2F','CKGL041500','7kI','Frost Brier');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (45,80,'mezz''ombra','07/10/2001','5NN','HOKU232363','6ztTi','Korary');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (46,83,'ombra','06/11/2000','5NN','HOKU232363','6ztTi','Korary');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (47,85,'ombra','10/11/2002','5NN','HOKU232363','6ztTi','Poterium opaca');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (49,97,'sole-mezz''ombra','09/30/2022','5B','FHWR698912','mBj6VMJ0TJ0Iw6CU','Tropaeolum coelestinum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (50,99,'ombra','02/16/2004','5B','FHWR698912','mBj6VMJ0TJ0Iw6CU','Ruellia persica');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (51,82,'sole','05/12/2017','5B','FHWR698912','mBj6VMJ0TJ0Iw6CU','Ruellia persica');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (52,87,'sole-mezz''ombra','11/19/2015','2K','SCBE327866','sI','Ruellia persica');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (53,93,'mezz''ombra','09/22/2003','2K','SCBE327866','sI','Sacred Bitterweed');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (54,78,'sole','05/22/2000','2K','SCBE327866','sI','Sacred Bitterweed');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (75,88,'mezz''ombra','02/04/2019','4RQ','ZUVV082123','em','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (76,90,'ombra','07/25/2004','4RQ','ZUVV082123','em','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (77,95,'sole-mezz''ombra','07/30/2013','4RQ','ZUVV082123','em','Poterium opaca');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (78,78,'sole','11/27/2003','4T','KVOA826650','g','Sacred Bitterweed');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (79,86,'mezz''ombra','08/08/2008','4T','KVOA826650','g','Korary');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (80,88,'ombra','01/07/2023','4T','KVOA826650','g','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (93,90,'sole-mezz''ombra','12/08/2021','1O','MBWW975753','tHtPI','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (94,96,'mezz''ombra','07/31/2016','1O','MBWW975753','tHtPI','Frost Brier');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (95,77,'ombra','07/05/2010','1O','MBWW975753','tHtPI','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (96,80,'sole','12/30/2004','1O','MBWW975753','6ztTi','Korary');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (97,90,'mezz''ombra','09/14/2007','1O','MBWW975753','6ztTi','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (27,97,'mezz''ombra','10/04/2006','2Y','NOTU391188','6ztTi','Tropaeolum coelestinum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (28,77,'mezz''ombra','03/22/2008','2Y','NOTU391188','g','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (29,87,'sole-mezz''ombra','09/25/2001','2Y','NOTU391188','g','Ruellia persica');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (30,90,'mezz''ombra','09/26/2001','2Y','NOTU391188','g','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (67,88,'mezz''ombra','12/21/2020','1AM','LMBB683668','Teh','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (68,92,'sole','03/19/2023','1AM','LMBB683668','Teh','Bellis cordata');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (69,93,'sole','10/08/2009','3I','GJUY873925','Teh','Sacred Bitterweed');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (70,77,'sole','03/18/2011','3I','GJUY873925','Teh','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (71,84,'sole-mezz''ombra','11/16/2009','5U','FUBE410934','Teh','Trollius sinautum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (72,91,'sole-mezz''ombra','06/06/2016','5U','FUBE410934','Teh','Frost Brier');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (31,93,'ombra','05/13/2008','2C','FHWR698912','w8','Sacred Bitterweed');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (32,98,'mezz''ombra','01/31/2020','2C','FHWR698912','w8','Ourillum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (33,76,'sole-mezz''ombra','10/16/2016','2C','FHWR698912','w8','Ourillum');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (36,89,'mezz''ombra','08/21/2022','2C','FHWR698912','w8','Bellis cordata');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (37,96,'ombra','11/28/2011','2C','FHWR698912','w8','Frost Brier');
INSERT INTO "ortiScolastici"."replica" ("numerorep","gruppo","esposizionespecifica","datamessaadimora","classemessaadimora","scuolamessaadimora","sensore","specie") VALUES (34,78,'mezz''ombra','04/09/2008','2C','FHWR698912','w8','Sacred Bitterweed');

---

INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (1,'HPFQMF68C64X136S',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (2,'GCOOFM21A70V473C',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (3,'PZHARD93B71X659S',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (6,'PYBMTX58T29K331F',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (8,'PWADBE79S64P153O',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (10,'ITLYNJ30H64A677J',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (12,'XXOVQF09H92W867I',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (13,'KYLNSL68L65I193K',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (14,'MHBDJZ20A54E342D',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (17,'POWHYT21H69E521J',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (19,'CTKYLN81L14L920N',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (21,'AOBIZC87M39V879F',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (24,'TWAEXK10B65V343L',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (26,'QLBFSW34R89Y771O',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (29,'HDPRTE47T00B859N',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (32,'EIFCFQ06R99Y853B',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (33,'GTSBWT13S08W565R',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (34,'BPESFM87C80J906U',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (39,'KPXSSA26E91N468W',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (41,'JVQIXY69H07Y804S',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (42,'MFZPSP07S59U629L',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (43,'MHNAUI93P55G907N',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (47,'MPPTLK14T98E930T',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (48,'OBDJWF30M46I298U',NULL,NULL);
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (4,NULL,'4HL','DWGN995148');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (5,NULL,'2O','XUMZ640083');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (7,NULL,'4U','VMVG538918');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (9,NULL,'2RQ','ZUVV082123');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (11,NULL,'3PB','YFLO985733');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (15,NULL,'5K','IQYU292364');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (16,NULL,'4I','VKSF672045');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (18,NULL,'2F','CKGL041500');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (20,NULL,'5NN','HOKU232363');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (22,NULL,'5HV','AWSB463953');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (23,NULL,'1M','MIAL404804');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (25,NULL,'3C','EZPN556177');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (27,NULL,'4JL','BBEQ642750');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (30,NULL,'3HO','SRQR279989');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (35,NULL,'2Y','NOTU391188');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (37,NULL,'1O','FUJK032756');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (38,NULL,'3L','ZCLA418514');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (44,NULL,'5Q','MBWW975753');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (46,NULL,'3OW','GUEI411177');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (49,NULL,'4L','IEAH194505');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (28,NULL,'4RQ','ZUVV082123');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (36,NULL,'3E','YTPQ300936');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (40,NULL,'3G','DWGN995148');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (45,NULL,'4AQ','YTPQ300936');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (50,NULL,'2R','DWGN995148');
INSERT INTO "ortiScolastici"."responsabile" ("codiceresp","persona","classe","scuola") VALUES (31,NULL,'4C','DWGN995148');



---

INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (2,6,'11/21/2009 03:23:00','08/28/2020 10:25:00','Arduino','suolo',NULL,79.29,1.49,37.36,9.57,38.15,8.88,5.86,26.64,346774,131741,497,7,2.7,6.22,6.94,11,9);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (3,12,'12/12/2002 04:19:00','05/01/2011 05:58:00','Arduino','suolo',NULL,85.14,4.36,2.33,32.25,5.63,2.1,14.81,2.54,8909,421616,85371,18.99,56,3.96,66.65,11,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (4,19,'09/27/2011 05:30:00','09/22/2018 07:04:00','Arduino','suolo','suolo',89.81,5.3,33.15,7.9,59.25,77.96,18.02,44.78,971169,566940,633978,7.77,4.68,7.45,93.35,11,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (5,27,'11/06/2007 01:35:00','07/11/2007 10:19:00','Arduino','terriccio',NULL,6.15,64.74,3.19,46.59,4.27,51.72,84.99,9.13,762792,545000,82229,3.68,12.66,4.27,11.17,15,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (6,28,'02/18/2015 04:02:00','07/18/2010 09:33:00','Arduino','suolo',NULL,6.7,29.21,1.32,97.33,39.79,94.25,9.32,29.24,61166,660443,562242,28.7,21.05,4.98,75.07,15,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (7,32,'09/22/2003 01:52:00','05/23/2021 02:30:00','app','terriccio',NULL,8.43,76.32,7.55,61.53,4.31,3.06,8.09,71.09,173328,652993,769140,8.51,14.49,9.38,3.4,18,11);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (8,39,'09/07/2004 10:39:00','07/17/2017 05:24:00','app','terriccio',NULL,3.11,26.95,66.65,3.38,11.48,9.81,1.03,74.43,669515,460400,823786,3.96,2.74,3.19,89.85,20,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (9,45,'09/12/2009 06:56:00','05/23/2011 07:10:00','Arduino','terriccio',NULL,1.7,6.66,7.84,4.72,56.94,11.15,9.17,3.21,838629,633707,845854,3.82,2.01,3.41,58.08,20,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (10,55,'01/29/2003 04:35:00','03/15/2002 05:14:00','app','suolo','aria',51.63,44.4,49.68,3.11,47.92,9.3,27.83,5.52,151740,514168,231132,29.13,38.12,7.13,40.13,20,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (25,91,'07/15/2022 02:27:00','10/10/2011 01:04:00','app','suolo','suolo',49.77,87.06,15.89,62.37,3.28,1.98,73.7,88.93,60359,1819,735677,2.8,5.21,8.76,5.68,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (26,96,'04/27/2018 03:23:00','03/28/2016 03:44:00','app','terriccio',NULL,87.84,24.55,54.37,57.52,54.58,9.42,2.01,7.59,591766,272883,692882,1.93,1.16,3.7,7.99,31,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (45,80,'11/23/2021 05:23:00','05/18/2015 07:15:00','Arduino','terriccio',NULL,54.27,60.75,34.15,67.25,39.02,8.94,6.34,92.81,603789,24396,585165,5.85,64.06,1.29,6.62,31,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (46,83,'07/31/2021 05:14:00','05/28/2004 04:50:00','app','suolo',NULL,2.09,3.48,25.16,1.89,96.52,7.07,1.83,95.19,631148,219758,883872,6.6,2.56,7.17,6.08,35,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (47,85,'02/24/2003 05:33:00','11/19/2007 03:47:00','Arduino','suolo',NULL,47.81,45.26,1.63,10.44,9.32,1.32,1.61,6.94,722640,163842,366486,56.78,68.39,6.88,53.5,37,18);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (50,99,'12/16/2019 09:35:00','10/29/2006 07:15:00','Arduino','terriccio',NULL,2.16,2.47,34.24,92.27,43.37,22.45,91.59,26.46,835934,13012,804425,66.71,23.23,3.38,56.1,42,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (52,87,'07/15/2008 10:49:00','02/20/2010 10:47:00','Arduino','suolo',NULL,63.97,6.06,3.78,15.03,24.78,42.2,5.92,3.44,571280,703895,305677,8.84,6.76,6.47,73.58,42,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (53,93,'07/17/2000 00:52:00','08/16/2006 10:11:00','Arduino','terriccio','aria',1.53,34.02,7.5,3.16,8.42,4.92,8.75,40.97,325109,471965,587433,2.94,9.83,11.96,6.14,50,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (75,88,'02/17/2019 00:18:00','03/20/2012 09:18:00','app','suolo',NULL,7.91,13.09,2.88,2.86,83.46,68.33,6.5,76.36,759789,859736,613765,7.69,21.66,5.96,91.03,50,21);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (76,90,'11/28/2006 07:01:00','06/16/2000 03:24:00','app','terriccio',NULL,18.79,2.45,63.3,51.86,9.92,7.79,9.33,82.97,287156,462384,532966,4.53,14.02,1.53,52.3,3,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (93,90,'09/13/2001 08:52:00','09/11/2013 10:22:00','Arduino','suolo',NULL,1.38,9.22,7.02,6.85,68.94,7.52,75.05,3.74,4932,981817,177677,49.61,5.52,9.17,44.33,21,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (27,97,'05/28/2003 08:58:00','10/22/2008 10:01:00','Arduino','terriccio','suolo',34,94.16,5.32,2.61,35.21,68.06,62.66,31.09,58156,396588,213534,84.33,82.48,9.94,2.35,26,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (67,88,'01/05/2023 07:33:00','01/16/2012 04:42:00','app','terriccio',NULL,2.37,1.47,5.77,79.86,7.91,6.65,50.58,22.26,806681,879187,762434,2.86,89.7,7.89,1.28,43,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (49,97,'10/29/2006 10:21:00','01/06/2022 03:06:00','app','terriccio','aria',5.83,50.41,9.67,72.35,6.41,4.03,3.87,2.75,940627,665414,476255,13.28,73.38,8.14,55.58,37,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (51,82,'10/06/2020 02:09:00','08/06/2016 03:36:00','app','terriccio','aria',61.24,2.05,5.52,1.6,1,37.84,6.39,1.22,343204,319195,436692,57.06,91.58,8.19,7.88,42,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (11,63,'08/17/2011 06:10:00','04/01/2000 09:19:00','Arduino','terriccio',NULL,9.96,33.55,1.77,3.11,90.28,74.94,45.2,4.96,458221,551499,695089,4.38,32.27,3.35,20.49,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (24,85,'06/03/2015 10:17:00','08/07/2021 01:52:00','Arduino','suolo',NULL,56.3,75.09,2.07,87.63,7.13,8.05,9.7,69.65,972650,182295,406495,8.87,98.85,6.82,4.02,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (54,78,'10/24/2001 07:22:00','08/31/2005 02:41:00','app','terriccio',NULL,2.92,7.8,32.33,2.29,8.85,5.73,83.72,91.69,690429,557389,335765,7.55,3.63,6.83,3.31,50,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (77,95,'09/14/2007 01:40:00','01/01/2006 02:29:00','app','terriccio',NULL,97.22,17.16,8.91,4.79,5.63,9.38,43.28,6.16,69472,500064,275208,7.6,96.23,1.95,81.45,3,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (78,78,'01/09/2019 02:23:00','04/22/2006 10:04:00','app','terriccio',NULL,9.74,59.25,6.37,9.09,46.37,51.11,65.69,7.56,554343,958219,908811,96.25,7.03,7.04,3.52,13,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (79,86,'06/01/2007 00:16:00','11/05/2013 10:46:00','Arduino','terriccio',NULL,3.52,8.97,6.83,51.49,9.88,2.66,4.22,9.5,740649,92573,810279,99.78,50.43,1.39,87.4,13,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (80,88,'06/07/2016 00:27:00','05/18/2020 01:49:00','Arduino','suolo',NULL,5.25,9.66,32.28,96.06,3.31,31.01,8.3,76.4,138871,608760,716536,54.68,80.91,7.96,53.59,13,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (94,96,'04/04/2022 06:25:00','11/28/2012 04:19:00','Arduino','terriccio',NULL,2.25,56.69,69.74,9.17,1.47,4.68,86.97,65.99,403789,915341,391336,9.97,9.75,4.72,6.09,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (95,77,'07/29/2006 05:13:00','07/17/2021 01:52:00','app','suolo',NULL,8.32,78.97,9.38,86.9,1.39,8.14,7.79,4.73,474555,172360,345937,8.08,7.96,6.13,5.89,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (96,80,'04/27/2023 03:11:00','04/18/2017 06:40:00','Arduino','suolo',NULL,26.09,1,83.65,39.7,9.8,6.88,3.33,9.78,703675,886878,47059,40.31,41,11.98,5.96,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (97,90,'07/12/2011 09:31:00','09/29/2002 01:20:00','Arduino','suolo',NULL,8.06,30.13,17.46,71.54,4.69,1.02,34.69,52.17,492818,780461,819025,37.77,5.34,1.03,6.18,26,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (28,77,'05/11/2021 09:25:00','11/11/2015 03:31:00','app','suolo',NULL,47.58,6.62,2.18,1.57,95.39,33.5,76.68,47.29,755497,686856,985923,2.52,82.08,7.69,6.74,34,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (29,87,'06/04/2006 10:50:00','07/24/2003 07:07:00','app','terriccio',NULL,8.21,75.88,6.88,8.04,7.96,45.67,41.81,27.43,722394,217179,909928,93.16,27.55,13.62,9.55,34,30);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (30,90,'02/07/2013 04:14:00','02/07/2005 05:07:00','Arduino','suolo',NULL,4.7,74.23,1.97,23.4,64.18,2.93,65.1,7.27,624756,412175,640922,9.02,8.74,2.64,5.03,43,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (68,92,'09/13/2011 07:11:00','09/12/2020 05:20:00','app','terriccio',NULL,44.93,1.97,1.1,44.08,32.56,4.65,7.25,4.45,154241,741909,388654,99.61,7.64,1.39,93.3,47,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (69,93,'02/12/2022 10:22:00','04/27/2012 03:51:00','Arduino','suolo','suolo',4.82,90.73,64.79,89,6.66,81.65,4.59,3.24,493734,6393,304216,4.89,6.33,9.09,9.49,47,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (71,84,'01/25/2013 08:14:00','11/08/2022 09:31:00','app','suolo',NULL,9.21,31.08,24.92,63.96,45.67,30.6,50.23,3.52,136943,416218,300270,87.22,9.83,7.14,2.13,5,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (72,91,'04/07/2010 10:47:00','09/05/2008 08:10:00','Arduino','suolo','suolo',67.08,1.64,4.98,3.51,79.49,7.53,7.04,27.39,708301,70779,657377,9.31,65.58,8.77,74.89,8,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (33,76,'05/28/2011 06:06:00','06/14/2000 03:55:00','Arduino','terriccio',NULL,6.28,30.98,64.05,61.72,37.12,8.08,1.53,1.53,260363,174706,48664,2.84,4.09,5.16,92.3,13,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (34,78,'02/07/2021 10:07:00','11/10/2003 06:03:00','Arduino','suolo',NULL,1.45,3.59,29.27,9.67,6.03,1.42,27.4,77.52,159430,757723,775950,1.65,8.03,6.11,4.7,17,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (37,96,'01/06/2006 09:27:00','12/06/2005 08:58:00','app','suolo',NULL,59.91,94.64,40.03,6.94,6.29,4.82,92.94,5.49,834409,891174,638822,6.46,65.26,9.96,15.9,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (2,6,'11/17/2000 01:51:00','11/05/2015 00:40:00','Arduino','suolo',NULL,5.08,28.97,2.54,51.8,5.63,9.59,50.17,46.43,90930,333325,691726,42.8,6.73,9.44,45.86,28,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (3,12,'11/25/2009 06:13:00','06/25/2007 02:05:00','Arduino','suolo',NULL,4.69,5.06,66.74,4.64,4.98,66.72,3.94,1.72,434118,221924,20483,2.39,56.65,3.9,68.84,28,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (6,28,'11/08/2022 07:55:00','04/06/2005 08:12:00','app','suolo',NULL,3.31,8.55,46.07,69.94,32.9,7.97,90.77,8.86,880708,730397,53012,6.75,2.56,2.5,9.73,41,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (7,32,'06/02/2007 06:14:00','04/18/2012 08:58:00','Arduino','terriccio',NULL,28.97,20.78,6.05,98.09,19.03,97.66,8.7,4.88,519757,593613,575876,4.46,7.06,6.34,47.07,41,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (8,39,'01/19/2003 03:40:00','08/27/2020 06:29:00','Arduino','suolo',NULL,71.67,2.11,22.26,4.55,5.72,8.59,54.7,5.76,901058,877611,784725,2.44,3.67,8.45,65.71,46,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (9,45,'12/05/2010 06:39:00','02/20/2000 03:23:00','Arduino','terriccio',NULL,30.92,7.09,42.91,7.03,20.96,7.72,4.75,84.47,352602,285818,671918,51.48,73.28,6.99,42.3,1,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (11,63,'05/24/2014 07:48:00','10/28/2012 09:35:00','app','suolo',NULL,7.33,23.54,6.13,12.48,66.67,68.52,3.62,68.75,764075,77404,878596,5.57,3,6.98,62.27,9,47);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (26,96,'01/28/2021 03:39:00','07/03/2023 03:13:00','app','terriccio',NULL,94.59,77.86,71.27,38.59,10.41,97.52,2.33,9.8,881974,365009,93791,2.14,91.05,3.94,6,19,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (49,97,'09/25/2005 03:05:00','02/19/2012 08:00:00','Arduino','terriccio','suolo',36.08,1.47,6.97,5.7,87.94,92.23,44.36,5.23,660474,473778,127448,45.39,67.23,1.84,2.07,35,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (50,99,'11/16/2004 02:37:00','10/11/2022 06:05:00','app','suolo',NULL,9.8,14.59,1.27,7.98,6.9,15.38,2.77,2.94,613631,12435,207801,7.26,7.6,4.22,8.72,44,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (51,82,'12/27/2014 01:13:00','05/26/2018 06:00:00','app','suolo','aria',5.34,5.85,40.07,3.13,14.77,7.06,88.11,52.9,231723,617626,316909,87.23,4.53,5.66,1.93,44,8);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (54,78,'06/18/2012 07:53:00','11/02/2003 06:27:00','Arduino','suolo',NULL,10.5,5.85,9.3,1.32,3.33,27.55,37.85,5.33,912751,762494,925931,2.13,9.15,7.46,1.75,49,17);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (75,88,'04/19/2006 08:29:00','05/11/2004 08:50:00','Arduino','suolo',NULL,88.21,55.25,4.75,95.84,9.78,59.22,24.53,75.51,852102,671287,788134,3.41,8.29,2.69,91.33,5,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (70,77,'07/04/2019 07:32:00','08/08/2017 00:09:00','Arduino','terriccio',NULL,69.19,38.61,85.04,1.5,15.09,12.9,18.46,49.23,716464,913208,708900,2.84,7.43,1.96,85.33,5,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (5,27,'04/06/2005 00:21:00','10/14/2002 02:21:00','app','suolo',NULL,5.89,9.36,7.25,5.26,8.07,6.24,6.51,57.61,579313,855496,762460,54.93,83.26,8.07,9.47,41,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (24,85,'12/23/2022 10:02:00','02/17/2015 01:38:00','app','suolo',NULL,3,34.49,5.4,48.71,3.11,97.49,3.19,3.44,87182,643793,765601,28.14,40.47,8.77,3.94,9,48);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (45,80,'05/13/2009 01:45:00','01/14/2015 08:16:00','Arduino','suolo',NULL,3.54,6.14,75.9,2.96,7.55,9.06,48.9,13.95,198462,903834,986347,2.74,66.44,5.26,65.55,23,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (46,83,'05/12/2003 07:03:00','11/29/2010 07:23:00','app','suolo',NULL,9.19,6.6,6,6,7.3,1.52,3.77,9.89,852941,333193,757310,3.23,15.75,2.48,53.84,32,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (47,85,'07/07/2021 08:17:00','11/30/2011 09:44:00','app','suolo',NULL,5.45,6.66,64.7,81.64,83.55,1.92,8.37,33.68,432063,939406,525736,3.17,49.41,3.03,11.1,35,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (52,87,'11/30/2012 05:04:00','02/12/2004 08:30:00','app','suolo',NULL,9.19,4.63,4.11,57.62,1.32,5.71,74.85,12.18,839241,549322,802621,1.41,8.88,9.08,47.93,49,15);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (31,93,'01/16/2023 01:17:00','11/09/2014 03:43:00','Arduino','suolo','suolo',64.59,63.75,79.83,1.13,88.76,9.53,2.26,54.86,862030,179758,803106,99.01,1.72,4.8,13.37,8,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (32,98,'08/11/2014 05:49:00','06/14/2014 09:48:00','Arduino','suolo','suolo',1.29,2.21,49.04,60.9,69.34,1.26,6.86,5.08,194164,940241,932479,2.59,8.72,3.07,6.26,13,35);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (36,89,'07/08/2017 00:40:00','12/29/2017 04:08:00','Arduino','suolo','suolo',1.13,90.31,88.26,5.92,2.19,76.1,27.69,49.08,946070,50957,145554,2.06,9.25,1.34,5.51,17,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (1,1,'03/15/2013 01:28:00','12/11/2020 04:23:00','Arduino','suolo','suolo',35.6,11.16,70.95,31.46,2.04,87.26,3.02,77.81,985448,419387,767766,9.14,1.21,1.26,1.24,22,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (4,19,'08/30/2018 09:56:00','06/14/2005 02:08:00','app','terriccio','aria',1.33,43.41,6.7,8.96,3.55,24.54,33.21,29.58,524851,953795,70622,26.9,4.6,7.23,9.91,31,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (53,93,'02/21/2020 06:21:00','01/28/2020 03:23:00','app','terriccio','aria',34.14,8.03,36.59,28.28,22.29,1.03,71.23,68.23,260549,937469,474371,75.34,93.93,8.01,3.29,49,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (10,55,'04/14/2000 08:57:00','04/06/2014 00:42:00','Arduino','suolo','aria',96.15,32.25,4.37,50.92,32.93,4.42,3.56,7.66,78091,906298,421139,79.23,8.66,6.76,4.29,1,41);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (25,91,'11/28/2005 02:38:00','11/18/2003 08:04:00','app','terriccio','aria',3.4,72.43,2.1,93.87,1.99,9.16,9.09,58.09,553894,768363,884021,8.02,9.82,2.92,4.37,19,2);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (79,86,'03/31/2015 10:03:00','05/28/2023 07:39:00','app','suolo',NULL,91.35,82.29,1.05,10.05,59.07,4.44,3.59,7.47,819874,808999,808847,83.67,3.38,2.6,82.08,8,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (80,88,'10/06/2006 05:37:00','10/08/2008 10:32:00','app','suolo',NULL,46.95,9.23,63.26,67.68,4.47,6.22,28.72,86.17,136728,486090,471389,65.47,7.7,6.1,6.76,16,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (93,90,'02/20/2014 05:51:00','04/22/2009 00:49:00','Arduino','suolo',NULL,11.06,9.7,4.49,77.19,8.88,4.83,66.64,8.14,847952,595964,5840,3.74,8.29,9.33,78.2,16,23);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (29,87,'09/02/2013 00:34:00','07/01/2003 03:55:00','Arduino','suolo',NULL,1.5,7.28,3.13,59.47,68.13,75.24,3.65,1.1,784539,368755,637194,35.71,54.54,8.38,4.34,25,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (69,93,'04/06/2023 08:05:00','06/07/2010 10:56:00','app','suolo','aria',33.5,8.01,7.18,74.29,7.91,8.27,7.35,37,573847,633580,172132,65.21,9.4,3.44,7.17,50,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (71,84,'01/01/2000 07:40:00','04/13/2023 03:15:00','app','suolo',NULL,49.49,1.21,6.11,74.03,66.48,45.51,1.51,2.23,293327,457976,326065,44.45,84.41,4.27,78.83,50,47);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (72,91,'06/18/2005 06:23:00','01/12/2009 01:36:00','app','terriccio','aria',5.8,3.49,2.02,7.09,2.74,3.55,6.82,72.12,200905,116868,329305,51.17,3.61,3.31,55.91,2,7);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (34,78,'05/05/2021 05:14:00','09/10/2001 08:04:00','Arduino','terriccio',NULL,2.62,9.34,82.3,5.89,35.74,7.97,4.86,9.45,314307,409383,780972,31.11,39.15,7.68,7.44,19,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (36,89,'02/07/2007 07:54:00','03/02/2003 01:52:00','Arduino','suolo','aria',6.98,7.63,9.23,41.92,6.26,3.57,3.71,66.6,681026,701244,164183,83.67,3.01,1.37,4.32,19,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (76,90,'09/02/2001 10:53:00','04/28/2008 05:11:00','app','suolo',NULL,8.87,2.64,8.9,98.71,86.41,80.79,83.46,23.83,817026,240421,452823,93.36,2.43,3.34,19.75,5,20);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (77,95,'01/04/2012 02:04:00','03/26/2009 00:57:00','Arduino','suolo',NULL,71.85,5.78,93.48,6.71,1.11,9.08,38.66,5.91,813077,397495,317846,1.53,88.67,5.78,4.69,8,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (78,78,'03/07/2007 01:52:00','05/05/2010 00:52:00','app','suolo',NULL,9.22,1.91,43.25,9.26,2.39,39.54,15.23,53.01,813669,947972,528523,4.21,25.56,5.93,60.02,8,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (94,96,'01/25/2018 00:04:00','08/24/2018 06:20:00','Arduino','suolo',NULL,25.53,93.9,80.69,46.44,38.36,7.45,79.07,6.86,762311,913321,136356,92.42,58.33,2.25,9.29,16,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (95,77,'06/01/2000 01:48:00','10/05/2018 03:36:00','Arduino','suolo',NULL,3.87,58.75,9.18,81.25,67.23,38.32,6.5,2.05,938170,308570,911362,6.08,9.72,13.67,6.98,18,28);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (96,80,'02/03/2021 02:12:00','08/11/2010 09:31:00','Arduino','suolo',NULL,6.22,40.92,3.81,5.85,21.37,1.88,2.95,9.53,882145,186721,542716,9.63,85.35,1.06,10.98,24,35);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (97,90,'05/27/2011 07:17:00','09/20/2017 09:36:00','app','terriccio',NULL,9.71,8.04,5.19,84.05,9.08,8.31,67.48,7.2,571394,493041,960392,9.45,55.1,8.81,17.84,24,38);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (28,77,'12/12/2011 01:11:00','10/15/2018 00:28:00','app','suolo',NULL,34.51,22.03,18.54,5.01,40.18,25.53,5.7,61.82,951504,33627,479718,8.77,97.6,6.65,7.17,25,43);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (30,90,'07/31/2019 10:23:00','07/09/2002 01:21:00','app','terriccio',NULL,44.24,13.09,48.66,94.81,8.31,24.54,49.9,6.61,959108,193797,263641,96.51,1.03,2.83,6.39,29,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (67,88,'09/14/2002 10:54:00','12/08/2018 06:07:00','Arduino','suolo',NULL,85.52,6.56,6.15,5.24,79.45,2.94,3.53,7.53,467706,316486,348576,2.69,4.72,2.83,7.85,39,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (68,92,'12/18/2015 09:13:00','09/15/2020 00:52:00','Arduino','suolo',NULL,1.08,4.38,6.64,2.41,48.31,5.18,8.2,27.93,83225,397546,350301,7.55,9.32,3.33,42.47,43,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (70,77,'09/29/2015 07:13:00','07/01/2019 09:17:00','Arduino','terriccio',NULL,4.75,95.13,2.1,1.54,93.84,8.19,82.97,15.61,793815,603408,718150,9.69,2.97,6.75,20.43,50,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (33,76,'06/22/2014 06:14:00','10/26/2004 04:09:00','Arduino','suolo',NULL,1.91,8.96,80.75,5.44,11.18,4.69,3.56,5.32,958081,647499,734522,36.36,7.66,9.8,66.53,19,22);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (37,96,'10/28/2019 02:45:00','03/19/2007 01:06:00','app','suolo',NULL,5.59,2.3,79.78,6.9,1.09,7.81,7.08,67.36,648816,305564,843678,1.89,5.24,2.76,3.13,24,31);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (27,97,'03/07/2012 02:46:00','01/17/2011 02:07:00','Arduino','terriccio','suolo',39.29,76.88,92.74,15.49,22.22,1.76,90.69,38.15,602265,187519,235452,53.72,2.9,2.5,45.11,24,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (1,1,'01/27/2013 00:16:00','04/25/2020 05:28:00','app','suolo','suolo',88.63,94.49,4.82,19.09,92.14,7.23,6.6,94.83,421035,625731,503063,6.05,7.3,3.87,7.56,32,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (31,93,'11/13/2015 04:30:00','09/20/2021 06:45:00','app','suolo','aria',8.21,5.44,5.6,6.76,6.04,9.15,8.22,7.81,8201,378175,643995,8.58,8.59,1.44,3.56,2,NULL);
INSERT INTO "ortiScolastici"."rilevazione" ("replica","gruppo","dataoraril","dataorains","modalitaacquisizione","substrato","cosamonitoro","pesofrescof","pesoseccof","larghezzaf","lunghezzaf","altezza","lunghezzar","pesofrescor","pesoseccor","nfiori","nfrutti","nfoglie","supperc","temperatura","ph","umidità","responsabilerilevazione","responsabileinserimento") VALUES (32,98,'09/12/2003 03:11:00','09/25/2006 09:04:00','Arduino','suolo','aria',90.38,36.05,33.29,7.73,6.92,10.21,45.49,6.19,580674,895927,840516,40.08,21.68,9.03,34.06,13,12);

---

INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('AWSB463953','CTKYLN81L14L920N','BPESFM87C80J906U','0MG');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('MIAL404804','CTKYLN81L14L920N','BPESFM87C80J906U','QFEIf42xiW3RM2ajs5UU');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('EZPN556177','CTKYLN81L14L920N','BPESFM87C80J906U','3C0Z');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('BBEQ642750','ZPCVQL60T42E093V','RCQWDF90C38Z130F','bj6PqvJNB');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('XGOZ206775','ZPCVQL60T42E093V','RCQWDF90C38Z130F','y7m0JKoxmh3PO7aX');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JPAQ950880','RCQWDF90C38Z130F','RCQWDF90C38Z130F','JYzpcDF7huaNdzljijTX');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('RMOH105619','RCQWDF90C38Z130F','DUGDON96E35M468M','ljtX');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('XHEY917650','RCQWDF90C38Z130F','EZVLIM14E72K858M','sjKk4I');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('NRVP212218','GSFQSG55M27P103S','USGPZK04P22P361H','1TI8IQlwaHrJlsoh1Rb');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('UVST785187','GSFQSG55M27P103S','USGPZK04P22P361H','MLBs8iEJPn');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('BSTQ143737','PQQICG99L62T966M','PQQICG99L62T966M','Gd3qdE4z');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('XUMZ640083','PQQICG99L62T966M','PQQICG99L62T966M','cQ8Oit');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('KRQO221401','PQQICG99L62T966M','SVERND99H27D626H','4');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('CCVM209965','VUCVZA00D23E710F','SVERND99H27D626H','5om');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HABM675977','VUCVZA00D23E710F','SXOOVE82H14M227W','WeoF0mZbsFs');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('VZUB660678','LLXCBI03E94F888H','SXOOVE82H14M227W','cQGMgeoo');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('RMWN141739','SXOOVE82H14M227W','SXOOVE82H14M227W','CZp3FAJGecvbwRtb');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HQYS628139','VIXGNY79C99K162Q','GVRFRO88B93Q110L','jdcuWi4r6Dglo');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('WEYZ736087','VIXGNY79C99K162Q','GVRFRO88B93Q110L','7J8nQJn');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('IQYU292364','VIXGNY79C99K162Q','GVRFRO88B93Q110L','pOsfiy7ij');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('TNQE507402','EUSXAI31R82F500W','BMGAWK81C56O667L','6M7QmVND8eybuKbaF');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('FUQG557186','EUSXAI31R82F500W','GNQIPV41C92S688V','WSPDL');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('LPQK893789','GNQIPV41C92S688V','GNQIPV41C92S688V','JXNqZidSC4W');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('PHZI712016','UDHAKN85P14Z664D','GNQIPV41C92S688V','noACSDfA2yvS0H');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('ICHH641331','DVGXMF54R52V200B','MGOLCJ58R62J571P','c');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('VBFL696361','DVGXMF54R52V200B','MGOLCJ58R62J571P','WSHD');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('INNO159766','DVGXMF54R52V200B','MGOLCJ58R62J571P','F33PMfDDiVIse');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('WJFY993381','JEKHSI66P11M866Y','PCIHOZ76P49W836F','5q');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('CKGL041500','JEKHSI66P11M866Y','PCIHOZ76P49W836F','N');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HZSI671820','FITAWM79S90C738T','POWHYT21H69E521J','etyQhpd0g');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('VMVG538918','FITAWM79S90C738T','POWHYT21H69E521J','VsLctw2X4ccrSJMnYh5');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('EOSU134636','USWSPF17A97E059N','POWHYT21H69E521J','UWL34');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('ZUVV082123','USWSPF17A97E059N','EIFCFQ06R99Y853B','MP8iRq6jXNAkdAd124');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('DYXL219640','USWSPF17A97E059N','EIFCFQ06R99Y853B','L1EP0HVBIBt');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('WRYX835237','GTSBWT13S08W565R','EIFCFQ06R99Y853B','wDupV43XQYe');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HPFW066855','GTSBWT13S08W565R','JVQIXY69H07Y804S','pkHjNt8cBa5');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('FHUX246339','YBBCHG66B88Z526R','JVQIXY69H07Y804S','lg15L5WgWR5BOnT');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('YFLO985733','YBBCHG66B88Z526R','JVQIXY69H07Y804S','20');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('ONVP684480','BNJEJX14B66R915T','MFZPSP07S59U629L','v8XtFYcXlC5mibninKh');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('DGPI802997','PVFSGI29B24V602R','CIMYYV14H98P964O','BR5r6UzuC7d6KMv');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('ZCLA418514','PVFSGI29B24V602R','CIMYYV14H98P964O','Zd4sSw1KYc2dRe763NfQ');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('YXRI924778','PVFSGI29B24V602R','CIMYYV14H98P964O','i07YRpg3y8OrVogn');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('SUMC912647','BEODZY95R95J641G','VKRVHR71R56U730E','sb');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('BCAT073910','BEODZY95R95J641G','VKRVHR71R56U730E','agR8uFmw4m1ewa');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('ISFN695651','BEODZY95R95J641G','YKPIFV46B88B691F','IH');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('AXVM765511','UYAFJH59B69Z431Q','UYAFJH59B69Z431Q','R2kiM73szOVzyXuox4');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('VWVI840013','UYAFJH59B69Z431Q','VJRBUI50M48G059K','0BJ');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JCMX459758','UYAFJH59B69Z431Q','VJRBUI50M48G059K','hDAMBG7FXHbz');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('RCEI775123','CQPCSJ68D54G047O','VJRBUI50M48G059K','lVU0qJY5wAfp');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('XVXQ085248','CTOHLH05L93K955O','NXCTUB28M29E937K','i');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('REXE231415','CTOHLH05L93K955O','NXCTUB28M29E937K','klqUqnlVpcLfAHDQlD');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('EDAO792413','GQJVMS17B24L320V','NNKIWK73A30P895R','R');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('OCAB798533','DHAGYK45C85U562G','NNKIWK73A30P895R','RER6');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('YDPL131659','DHAGYK45C85U562G','NNKIWK73A30P895R','L44GZt8WlBVuZXOnwfb');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('AMMO276040','ZORWID85L20V471J','GQJVMS17B24L320V','D0Rc88EAm');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('XFJM071528','ZORWID85L20V471J','GVMAUG06D47W524K','WjHy4UEYAG');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('WVOK098475','ZORWID85L20V471J','GVMAUG06D47W524K','TiSkcwPtOSsXf6joJUl');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('NKLC275838','CYJYIM29B30X556M','DYYQER24D08M437U','Vxn87Gf21');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JAHG085442','CYJYIM29B30X556M','DYYQER24D08M437U','ylbxREr');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HIVX127078','CYJYIM29B30X556M','DYYQER24D08M437U','yeIS');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('VKSF672045','LYMOCC88T55A243Z','PUDPHC53P12I059Z','eLq');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('NGPK007372','LYMOCC88T55A243Z','CLBEYY68L69H531O','wkJnvt');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('GRMA600469','LYMOCC88T55A243Z','CLBEYY68L69H531O','2jRnRWwaH');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('AVHC934552','JXDJFW35H02R860D','CLBEYY68L69H531O','soMycjRC');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('IABH313292','CYBHAR27E08W983I','WFXRCN17A35D927K','Ku4uiAv78pf75Rm37gem');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('GDMC148991','CYBHAR27E08W983I','WFXRCN17A35D927K','QTcCwiBFa0ClC');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JUIG265908','HIDAYF54L44X548C','WFXRCN17A35D927K','6vXW53');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('RLRZ812930','HLZKEG93H55L035E','YBYGNE75E00Q823Z','QBdMfzxDTsXIHwum');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('TSKG484779','LBXWSI91A11T130Z','YBYGNE75E00Q823Z','Udt17hgf6FY8woDfU3yg');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('GWBA292430','LBXWSI91A11T130Z','BGZWDY66C52S629P','8PGTypVb7VtSdYJ4R');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('BBJJ636077','LBXWSI91A11T130Z','BGZWDY66C52S629P','k6bqVmT2HrHT');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('QHDF053500','YWQTZI62D97N680Q','BGZWDY66C52S629P','P7w44OhNEpeRbC');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('IVDW339337','MMKCTW43B28U615R','NGTGCD89A47K654X','Q');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('FZKD472886','MMKCTW43B28U615R','NGTGCD89A47K654X','g2ULTl6SvBhpYxr');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('PCON152997','MLRIVQ80P37S393A','NGTGCD89A47K654X','xBPPHCdAtFuxqNOC');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('NREK820250','IOTBCP32A08K606N','BFBYMO16B63H821B','o3W');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('SDQT316641','IOTBCP32A08K606N','JYWEAS89A26C143Q','bhWJqxWYdOqm');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JAQT454002','IOTBCP32A08K606N','JYWEAS89A26C143Q','5ImLjOrMsrCXksdkB17');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HDKJ083576','NLGIXU77A58L634L','JYWEAS89A26C143Q','u2VW8G');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('SRQR279989','NLGIXU77A58L634L','OTPSEH23T11L743U','nMaMcL2pMs');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('IQFM865439','VROZBZ73E53P468T','OTPSEH23T11L743U','yeQCIH3qOjRRJgtELNkQ');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('EJSB464540','ZDNCSX56S75Y818Q','OTPSEH23T11L743U','PgcPPG0zEstI');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JWWO474553','AQWFPJ89H47S875X','IOTBCP32A08K606N','NUxNiSK2KZkwhzzy6');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('GVPI621762','AQWFPJ89H47S875X','IOTBCP32A08K606N','sM');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('EJYP741398','AQWFPJ89H47S875X','VFQLSU13R27Y942J','o81aiZ6IwYMn8jB0');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('ALCO645584','GHQRJE18R68N809T','VFQLSU13R27Y942J','ZJ');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('NOTU391188','GHQRJE18R68N809T','NCEVZP09A26S081A','Cvi');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('FEXE393362','GHQRJE18R68N809T','NCEVZP09A26S081A','WG');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('BZQT297971','OGKPTM08P21X629A','NCEVZP09A26S081A','ViAREQ8BwDSec');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('JBFN281006','OGKPTM08P21X629A','EZSHLY75M90R324B','77Om6TSMzZPf');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('IWAI992831','OGKPTM08P21X629A','EZSHLY75M90R324B','TTR');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('VDQI437671','QGHJXD80H94D064E','HUVKCZ92B53U833P','SmBy5ir');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('QIXQ215517','QGHJXD80H94D064E','HUVKCZ92B53U833P','Waf5WnX3YXX4aie');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('KKLY698903','IKMWDQ55L85M140K','HUVKCZ92B53U833P','BUmXfOflMCWkoCj6jl');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('QEAR862288','LUPPEE41E02W251Z','AQWFPJ89H47S875X','egHpWLVS');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('HTZE205898','LUPPEE41E02W251Z','AQWFPJ89H47S875X','DoIFaG0AwEYFQ7');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('IENI175363','LUPPEE41E02W251Z','AQWFPJ89H47S875X','UBEIi7P7bhnyQ');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('NSRO243077','UNRBIY80E55Q207T','PWTFEF04L29J384R','rkKQ3rLL2u5t2');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('EMEI071224','OBPKPA96T04M130B','PWTFEF04L29J384R','GaBRh4prdwslsYz');
INSERT INTO "ortiScolastici"."finanziamento" ("scuola","referentefin","partecipantefin","tipofin") VALUES ('THZF525024','OBPKPA96T04M130B','PWTFEF04L29J384R','KwXSisYO');

---

INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('AWSB463953','Adiantum jaempferx');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('MIAL404804','Void Clover');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('EZPN556177','Lavatera aquaticum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('BBEQ642750','Tropaeolum coelestinum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('XGOZ206775','Pyrus bipinnata');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JPAQ950880','Bellis pulchra');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('RMOH105619','Pyrus malus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('XHEY917650','Amelopsos wallichiana');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('NRVP212218','Kalmia caprea');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('UVST785187','Kadsura dracunculinus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('BSTQ143737','Bellis cordata');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('XUMZ640083','Rosa numularia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('KRQO221401','Drihhoot');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('CCVM209965','Adiantum velocis');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HABM675977','Scutellaria intergrifolium');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('VZUB660678','Meconopsis hysspoifolia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('RMWN141739','Antigonon numularia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HQYS628139','Ourillum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('WEYZ736087','Geranium eychlora');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('IQYU292364','Pennisetum germanica');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('TNQE507402','Restoration Sugarplum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('FUQG557186','Solanum melongena');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('LPQK893789','Korary');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('PHZI712016','Hordeum vulgare');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('ICHH641331','Rhychospora quinata');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('VBFL696361','Paeonia variegatus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('INNO159766','Arctosis campestre');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('WJFY993381','Frost Brier');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('CKGL041500','Eriocaulon aquaticum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HZSI671820','Vlanium');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('VMVG538918','Daucas carota');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('EOSU134636','Eucommia recurvara');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('ZUVV082123','Eucalyptus siderosticha');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('DYXL219640','Bamboosa aridinarifolia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('WRYX835237','Spodiopogon prunifolia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HPFW066855','Lobularia typhina');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('FHUX246339','Elymus crassipes');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('YFLO985733','Trachycarpus pinnatifida');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('ONVP684480','Twisted Clove');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('DGPI802997','Pygmy Polkweed');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('ZCLA418514','Osteaspermum miconioides');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('YXRI924778','Palsoes mungo');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('SUMC912647','Musa paradisicum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('BCAT073910','Cleome umbellata');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('ISFN695651','Ruellia persica');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('AXVM765511','Ficus benghalensis');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('VWVI840013','Tropaeolum celere');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JCMX459758','Lavatera aquaticus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('RCEI775123','Murraya koenigii');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('XVXQ085248','Gypsophila paradoxa');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('REXE231415','Sacred Bitterweed');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('EDAO792413','Linum sagittatum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('OCAB798533','Habenaria gardenii');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('YDPL131659','Zelkova asarifolia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('AMMO276040','Kadsura dracunculus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('XFJM071528','Hakonechlao rosea');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('WVOK098475','Poterium opaca');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('NKLC275838','Helenium fulgens');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JAHG085442','Ailanthus latifolium');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HIVX127078','Coriandrum atlantica');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('VKSF672045','Solenostemon punctiloba');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('NGPK007372','Glycine max');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('GRMA600469','Ulmus edulis');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('AVHC934552','Achras sapota');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('IABH313292','Parthenium transmorrisonensis');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('GDMC148991','Carex kuisianum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JUIG265908','Setcreasea rubiginosa');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('RLRZ812930','Shortia maritima');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('TSKG484779','Lindera piperita');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('GWBA292430','Fothergilla prunifolia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('BBJJ636077','Psidium guava');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('QHDF053500','Citrus Limonium');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('IVDW339337','Paulownia hexagonoptera');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('FZKD472886','Adiantum brutus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('PCON152997','Botrychium pulchra');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('NREK820250','Ananus sativus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('SDQT316641','Ocimum daconitum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JAQT454002','Acer rubrum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HDKJ083576','Santalum album');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('SRQR279989','Aucuba stratiotes');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('IQFM865439','Yucca spinosus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('EJSB464540','Davidia casiinoides');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JWWO474553','Setcreasea');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('GVPI621762','Vitis refinerve');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('EJYP741398','Curcuma longa');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('ALCO645584','Citrullus vulgaris');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('NOTU391188','Scutellaria');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('FEXE393362','Poterium');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('BZQT297971','Incarvillea rotundifolia');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('JBFN281006','Crataegus platyphylla');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('IWAI992831','Spodiopogon');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('VDQI437671','Dodecatheon auriculata');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('QIXQ215517','Restoration');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('KKLY698903','Trollius sinautum');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('QEAR862288','Lindera');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('HTZE205898','Ulmus');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('IENI175363','Silent Hogweed');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('NSRO243077','Ugobgoss');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('EMEI071224','Incarvillea');
INSERT INTO "ortiScolastici"."sioccupadi" ("scuola","specie") VALUES ('THZF525024','Botrychium glabra');

----------------------------------------------------------
-------------------- SEZIONE 3: Vista --------------------
----------------------------------------------------------

---- 'Definizione di una vista che fornisca alcune informazioni riassuntive per ogni attività
----  di biomonitoraggio: per ogni gruppo di stress e per il corrispondente gruppo di
----  controllo mostrare il numero di piante, la specie, l'orto in cui è posizionato il gruppo
----  e, su base mensile, il valore medio dei parametri ambientali e di crescita delle
----  piante (selezionare almeno tre parametri, quelli che si ritengono più significativi)'

SET datestyle TO 'DMY';

CREATE OR REPLACE VIEW InfoBiomonitoraggio(numeroBiomonitoraggio, numeroGruppoStress, numeroPianteNelGruppoStress, specieGruppoStress, ortoGruppoStress, meseGruppoStress, annoGruppoStress,
										  						  mediaAltezzaStress, mediaFioriStress, mediaFruttiStress, mediaTemperaturaStress, mediaUmiditaStress, mediaPHStress,
										   						  numeroGruppoControllo, numeroPianteNelGruppoControllo, specieGruppoControllo, ortoGruppoControllo, meseGruppoControllo, annoGruppoControllo,
										  						  mediaAltezzaControllo, mediaFioriControllo, mediaFruttiControllo, mediaTemperaturaControllo, mediaUmiditaControllo, mediaPHControllo										  
										  ) 
AS
SELECT G1.codBio, G1.codGruppo, COUNT(DISTINCT R1.numeroRep), R1.specie, G1.orto, EXTRACT (MONTH FROM Ril1.dataOraRil), EXTRACT (YEAR FROM Ril1.dataOraRil),AVG(Ril1.altezza) AS mAltezzaStress, AVG(Ril1.nFiori) AS mFioriStress, AVG(Ril1.nFrutti) AS mFruttiStress, AVG(Ril1.temperatura) AS mTemperaturaStress, AVG(Ril1.umidità) AS mediaUmiditàStress, AVG(Ril1.pH) AS mPHStress,
				  G2.codGruppo, COUNT(DISTINCT R2.numeroRep), R2.specie, G2.orto, EXTRACT (MONTH FROM Ril2.dataOraRil), EXTRACT (YEAR FROM Ril2.dataOraRil), AVG(Ril2.altezza) AS mAltezzaControllo, AVG(Ril2.nFiori) AS mFioriControllo, AVG(Ril2.nFrutti) AS mFruttiControllo, AVG(Ril2.temperatura) AS mTemperaturaControllo, AVG(Ril2.umidità) AS mediaUmiditàControllo, AVG(Ril2.pH) AS mPHControllo
FROM gruppo G1 
	JOIN gruppo G2 ON G1.codBio = G2.codBio
	JOIN replica R1 ON G1.codGruppo = R1.gruppo
	JOIN replica R2 ON G2.codGruppo = R2.gruppo
	JOIN rilevazione Ril1 ON R1.gruppo = Ril1.gruppo AND R1.numeroRep = Ril1.replica
	JOIN rilevazione Ril2 ON R2.gruppo = Ril2.gruppo AND R2.numeroRep = Ril2.replica
WHERE G1.codGruppo != G2.codGruppo AND G1.tipoGruppo = 'bio-stress'
GROUP BY G1.codBio, G1.codGruppo, R1.specie, G1.orto, G2.codGruppo, R2.specie, G2.orto,
		EXTRACT (MONTH FROM Ril1.dataOraRil), EXTRACT (MONTH FROM Ril2.dataOraRil), EXTRACT (YEAR FROM Ril1.dataOraRil), EXTRACT (YEAR FROM Ril2.dataOraRil)
HAVING (EXTRACT (MONTH FROM Ril1.dataOraRil) = EXTRACT (MONTH FROM Ril2.dataOraRil)) AND  (EXTRACT (YEAR FROM Ril1.dataOraRil)= EXTRACT (YEAR FROM Ril2.dataOraRil));


----------------------------------------------------------
---------------- SEZIONE 4: Interrogazioni ---------------
----------------------------------------------------------


---- Query 1: 'determinare le scuole che, pur avendo un finanziamento per il progetto,
----		   non hanno inserito rilevazioni in questo anno scolastico'

SELECT scuola
FROM FINANZIAMENTO
WHERE scuola NOT IN (SELECT scuola
					 FROM GRUPPO JOIN RILEVAZIONE ON gruppo=codGruppo
					 WHERE dataOraRil BETWEEN '01-09-2022' AND '30-06-2023'
					);

---- Query 2: 'determinare le specie utilizzate in tutti i comuni in cui ci sono
----		   scuole aderenti al progetto'

SELECT nomeScientifico
FROM SPECIE 
	JOIN SIOCCUPADI ON specie = nomeScientifico
	JOIN SCUOLA ON scuola = codiceMeccanografico
GROUP BY nomeScientifico
HAVING COUNT (DISTINCT comune) = (SELECT COUNT (DISTINCT comune) FROM SCUOLA);

---- Query 3: 'determinare per ogni scuola l'individuo/la classe della scuola
----		   che ha effettuato più rilevazioni'

SELECT responsabileRilevazione, persona, classe, scuola
FROM RESPONSABILE 
	JOIN RILEVAZIONE ON responsabileRilevazione = codiceResp
WHERE responsabileRilevazione IN (SELECT responsabileRilevazione
								  FROM RILEVAZIONE
								  GROUP BY responsabileRilevazione
								  HAVING COUNT (*)>= ALL (SELECT COUNT(*) 
						   								  FROM RILEVAZIONE
						  								  GROUP BY responsabileRilevazione));

----------------------------------------------------------------
---------------- SEZIONE 5: Procedure e funzioni ---------------
----------------------------------------------------------------

---- Funzione 1: 'funzione che realizza l'accoppiamento tra gruppo di stress e
----			  gruppo di controllo nel caso di operazioni di biomonitoraggio'

CREATE OR REPLACE FUNCTION abbinaGruppi(IN ilGruppo INTEGER, OUT bioGruppo INTEGER)
AS
$$
	DECLARE 
		nomeOrto VARCHAR(20);
		scuolaOrto CHAR(10);
		tipo VARCHAR(20);
		codice INTEGER;
	
	BEGIN

		SELECT orto,scuola,tipoGruppo,codBio INTO STRICT nomeOrto,scuolaOrto,tipo,codice FROM gruppo WHERE codGruppo = ilGruppo;
		
		RAISE NOTICE 'TROVATI: orto: %, ', nomeOrto;
		RAISE NOTICE 'scuola: %, ', scuolaOrto;
		RAISE NOTICE 'tipo: %, ', tipo;
		RAISE NOTICE 'codBio: %, ', codice;
		
		IF tipo = 'bio-stress'
			THEN bioGruppo := (SELECT codGruppo FROM gruppo WHERE tipoGruppo = 'bio-controllo' AND codBio = codice);
			ELSEIF tipo = 'bio-controllo'
				THEN bioGruppo := (SELECT codGruppo FROM gruppo WHERE tipoGruppo = 'bio-stress' AND codBio = codice);
			ELSE
				RAISE EXCEPTION 'ERRORE:solo i gruppi di tipo bio-stress o bio-controllo possono avere gruppi corrispondenti del tipo opposto';
		
		END IF;
	END;
$$
LANGUAGE plpgsql;

---- Funzione 2: 'Funzione che corrisponde alla seguente query parametrica: data una 
----              replica con finalità di fitobonifica e due date, determina i valori 
----              medi dei parametri rilevati per tale replica nel periodo compreso 
----              tra le due date'


---- !!!! OPPURE QUERY PARAMETRICA NEL SENSO CHE IL PARAMETRO DI CUI SI VUOLE MISURARE LA MEDIA VA PASSATO????
---- SI POSSONO FARE ENTRAMBE LE ALTERNATIVE DICHIARANDO CHE LA RICHIESTA ERA AMBIGUA...

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
				INTO STRICT numeroReplica, numeroGruppo, mediaPFFoglie, mediaPSFoglie, mediaLarghezzaFoglie, mediaAltezza, mediaLunghezzaRadici, mediaPFRadici, mediaPSRadici, mediaNumeroFiori, mediaNumeroFrutti, mediaNumeroFoglie, mediaSupPerc, mediaTemperatura, mediaPH, mediaUmidità
				FROM rilevazione
				WHERE laReplica = replica AND ilGruppo = gruppo AND dataOraRil BETWEEN dataInizio AND dataFine
				GROUP BY replica, gruppo;
		ELSE
			RAISE NOTICE 'ERRORE: il tipo deve essere fitobonifica';
		END IF;
	END;
$$
LANGUAGE plpgsql;

----------------------------------------------------------------
-------------------- SEZIONE 6: Trigger ------------------------
----------------------------------------------------------------

------------- Trigger richiesti --------------------

---- Trigger 1: 'Verifica che il vincolo che ogni scuola dovrebbe concentrarsi 
----             su tre specie e ogni gruppo dovrebbe contenere 20 repliche'

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

---- Trigger 2: 'Generazione di un messaggio (o inserimento di una informazione di 
----             warning in qualche tabella) quando viene rilevato un valore 
----             decrescente per un parametro di biomassa'

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
		   replica = NEW.replica AND gruppo = NEW.gruppo AND
		   dataOraRil = (SELECT MAX(dataOraRil) FROM rilevazione WHERE replica = NEW.replica AND gruppo = NEW.gruppo AND dataOraRil < NEW.dataOraRil);
		
		IF NOT FOUND
		THEN RETURN NEW;
		END IF;
		
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

---- Trigger dedotti dai vincoli introdotti


---- Trigger v4: 'Se l'attributo PULIZIA in ORTO è "True" allora l'orto ha solo GRUPPI di 
----              controllo per il biomonitoraggio, mentre se l'ambiente non è pulito allora 
----              può contenere solo GRUPPI per la fitobonifica o GRUPPI di stress per il 
----              biomonitoraggio.'

-- Il controllo va fatto sia in caso di aggiornamento di orto (per mantenere la consistenza)
-- sia in quello di inserimento e/o di aggiornamento di gruppo.

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


CREATE OR REPLACE FUNCTION puliziaGruppo() RETURNS TRIGGER AS
$$
	DECLARE
		puliziaO BOOLEAN;
	BEGIN
		SELECT pulizia INTO STRICT puliziaO FROM orto WHERE nomeOrto = NEW.orto AND scuola = NEW.scuola;
		
		IF puliziaO AND NEW.tipoGruppo IN ('bio-stress', 'fitobonifica')
		THEN RAISE EXCEPTION 'Un gruppo dedicato al biomonitoraggio in condizioni di stress o alla fitobonifica non può trovarsi in un orto pulito';
 		END IF;
 
		IF NOT puliziaO AND NEW.tipoGruppo = 'bio-controllo'
		THEN RAISE EXCEPTION 'Un gruppo dedicato al biomonitoraggio con finalità di controllo non può trovarsi in un ambiente non pulito';
		END IF;
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER controllaPuliziaGruppo
BEFORE INSERT OR UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE puliziaGruppo();

---- Trigger v5: 'L'attributo ciclo in SCUOLA deve essere coerente 
----              con l'attributo ordineTipo in CLASSE.'

-- Il controllo va effettuato sia inserendo/modificando una classe, 
-- sia modificando una scuola

CREATE OR REPLACE FUNCTION ordineTipoClasse() RETURNS TRIGGER AS
$$
	DECLARE
		cicloScuola CHAR(1);

	BEGIN
		SELECT ciclo INTO STRICT cicloScuola FROM Scuola WHERE NEW.scuola = codiceMeccanografico;
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

---- Trigger v6:'Non possono essere dislocate repliche da scuole esterne in orti non 
----             disponibili alla collaborazione, ovvero orti in cui 
----             l'attributo DISPONIBILITA è "False".'	

-- Il controllo va effettuato sia nella modifica dell'attributo in orto,
-- sia nell'aggiunta/modifica del gruppo

CREATE OR REPLACE FUNCTION disponibilitaOrto() RETURNS TRIGGER AS
$$
	DECLARE
		scuolaMetteADimora CHAR(10);
	BEGIN
		SELECT sioccupadi.scuola INTO STRICT scuolaMetteADimora 
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



CREATE OR REPLACE FUNCTION disponibilitaGruppo() RETURNS TRIGGER AS
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
		
		
		IF NOT disponibilitaO AND scuolaMetteADimora != NEW.scuola
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


---- Trigger v7:'Se il gruppo della REPLICA è 'fitobonifica' allora è obbligatorio l'attributo 
----             cosaMonitoro in RILEVAZIONE. Se è 'bio-controllo' o 'bio-stress' allora 
----             non deve essere presente.'	

-- Il controllo va effettuato sia negli aggiornamenti in gruppo sia negli
-- aggiornamenti/inserimenti in rilevazione

CREATE OR REPLACE FUNCTION tipoGruppo() RETURNS TRIGGER AS
$$
	DECLARE
		monitorato VARCHAR(5);
	BEGIN
		SELECT cosaMonitoro INTO STRICT monitorato
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



CREATE OR REPLACE FUNCTION tipoRilevazione() RETURNS TRIGGER AS
$$
	DECLARE
		tipo VARCHAR(20);
	BEGIN
		SELECT tipoGruppo INTO STRICT tipo
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

---- Trigger v11:'Una sola specie per gruppo'

-- Da verificare solo nel caso di aggiunta/modifica di replica

CREATE OR REPLACE FUNCTION specieGruppo() RETURNS TRIGGER AS
$$
		
	BEGIN
		IF EXISTS(SELECT DISTINCT specie FROM replica WHERE gruppo = NEW.gruppo AND specie != NEW.specie)
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

---- Trigger v12:'A un gruppo di bio-stress deve corrisponderne 
----              uno solo di bio-controllo e viceversa'	

-- Da verificare solo negli inserimenti e nelle modifiche in gruppo

CREATE OR REPLACE FUNCTION corrispondenzaBio() RETURNS TRIGGER AS
$$
		
	BEGIN
		IF NEW.tipoGruppo = 'fitobonifica' AND NEW.codBio IS NOT NULL
		THEN RAISE EXCEPTION 'Un gruppo di tipo fitobonifica non può avere un codBio';
		END IF;


		IF EXISTS(SELECT * FROM Gruppo WHERE codBio = NEW.codBio AND tipoGruppo = NEW.tipoGruppo)
		THEN RAISE EXCEPTION 'Un gruppo di tipo biomonitoraggio non può avere più di un gruppo corrispondente del tipo opposto (e ovviamente nessuno dello stesso tipo)';
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER controllaCorrispondenzaBio
BEFORE INSERT OR UPDATE ON Gruppo
FOR EACH ROW
EXECUTE PROCEDURE corrispondenzaBio();


