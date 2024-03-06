# RELAZIONE DI BASI DI DATI

###### Simone Lazzaro, Fabrizio Sardo, Sonia Spinelli

###### PARTE I



## REQUISITI RISTRUTTURATI

Per eliminare le ambiguità, si decide di riprendere la specifica di dominio e proporre in grassetto l'interpretazione con cui si è svolto il progetto:

"Si vuole realizzare una base di dati a supporto dell’iniziativa di citizen science rivolta alle scuole “Dalla botanica ai big data”. L’iniziativa mira a costruire una rete di supporto per le scuole che partecipano a progetti relativi agli orti scolastici. 

Per ogni scuola si vogliono memorizzare il nome dell’istituto scolastico **(ISTITUTO SCOLASTICO E SCUOLA SONO DA CONSIDERARSI SINONIMI)**, il codice meccanografico **(CHE LA IDENTIFICA)**, la provincia, **IL COMUNE (AGGIUNTO PERCHE' RICHIESTO DA UNA QUERY)** , il ciclo di istruzione (primo o secondo ciclo di istruzione) e se l’istituto beneficia o meno di un finanziamento per partecipare all’iniziativa, in tal caso ne memorizziamo il tipo **(UNA SCUOLA PUÒ PARTECIPARE ANCHE SENZA FINANZIAMENTI)**. 

Per ogni scuola c’è almeno una persona di riferimento per l’iniziativa **(REFERENTE PER L’INIZIATIVA “Dalla botanica ai big data”)**, ma possono essercene diverse. 

Per ogni persona coinvolta **(COINVOLTA GENERICAMENTE NELL’INIZIATIVA)** vogliamo memorizzare nome, cognome, indirizzo di email, opzionalmente un contatto telefonico e **(NON OPZIONALMENTE)** il ruolo (dirigente, animatore digitale, docente, …). **(QUESTA SARÀ IDENTIFICATA DA IL SUO CODICE FISCALE CHE ANDRÀ QUINDI MEMORIZZATO)**

Nel caso la scuola sia titolare di finanziamento per partecipare all’iniziativa **(NEL QUAL CASO PUÒ ESSERE TITOLARE DI UN SOLO FINANZIAMENTO)** (es. finanziamento per progetto PON EduGreen **(IL NOME “PON EduGreen” COSTITUISCE UN ESEMPIO DI “Tipo di Finanziamento”)**) si vuole memorizzare se la persona **(UNA PERSONA CHE, SE COINVOLTA NELL’INIZIATIVA, PUÒ ESSERLO UNA SOLA VOLTA)** sia il referente **(RESPONSABILE DEL FINANZIAMENTO)** e un partecipante al progetto da cui deriva il finanziamento. 

All’interno della scuola, possono esserci più classi partecipanti all’iniziativa. Per ognuna di esse si vuole memorizzare la classe (es. 4E), l’ordine (es. primaria, secondaria di primo grado) o il tipo di scuola (es. liceo scienze applicate, agrario) **(L’ORDINE RIGUARDA LE SCUOLE PRIMARIE E SECONDARIE DI PRIMO GRADO, MENTRE PER LE SCUOLE SECONDARIE DI SECONDO GRADO SI MANTIENE IL TIPO)** e il docente di riferimento per la partecipazione di tale classe **(UNA PERSONA PUÒ ESSERE DOCENTE DI RIFERIMENTO E, SE LO È, LO È PER UNA E UNA SOLA CLASSE).  (UNA CLASSE È IDENTIFICATA DAL SUO NOME E DALLA PRESENZA IN UNA DETERMINATA SCUOLA).**

Ogni scuola ha uno o più orti, identificati da un nome che identifica l’orto all’interno della scuola. Ogni orto può essere in pieno campo o in vaso, ed è caratterizzato da coordinate GPS **(LA PRECISIONE DEL GPS NON E' SUFFICIENTE A IDENTIFICARE UN ORTO IN UNA SCUOLA)** e una superficie in mq. Si vuole inoltre memorizzare se le condizioni dell’orto lo rendono adatto a fare da controllo per altri istituti (cioè se si trova in un contesto ambientale "pulito" e l’istituto è disposto a collaborare con altri). Le piante vengono piantate con scopi di biomonitoraggio o fitobonifica. 

Con biomonitoraggio si intende il monitoraggio dell'inquinamento mediante organismi viventi. Le principali tecniche di biomonitoraggio consistono nell'uso di organismi bioaccumulatori per fornire informazioni sulla situazione ambientale. Fornisce stime sugli effetti combinati di più inquinanti sugli esseri viventi, ha costi di gestione limitati e consente di coprire vaste zone e territori diversificati, consentendo una adeguata mappatura del territorio. Con fitobonifica si intende l’utilizzo delle piante per disinquinare aria, acqua, sedimenti e suoli. **(È NECESSARIO QUINDI DISTINGUERE TRA TRE GRUPPI DI REPLICHE: LE REPLICHE UTILIZZATE PER BIOMONITORAGGIO IN UN ORTO PULITO E QUINDI APPARTENENTI AL GRUPPO DI CONTROLLO, QUELLE UTILIZZATE PER BIOMONITORAGGIO IN UN ORTO NON PULITO E QUINDI APPARTENENTI AL GRUPPO DI STRESS E QUELLE UTILIZZATE PER LA FITOBONIFICA CHE PER DEFINIZIONE DEVONO TROVARSI IN UN ORTO NON PULITO. BISOGNA SALVARE IL COLLEGAMENTO TRA GRUPPI PER IL BIOMONITORAGGIO DI CONTROLLO E IL CORRISPONDENTE STRESS)**

Si considerano un certo numero di specie **(IDENTIFICATE DAL LORO NOME SCIENTIFICO)**(vedi allegato 1, da cui si evincono anche le informazioni da memorizzare per ogni specie) per i diversi scopi e per ogni specie vengono utilizzate un certo numero di repliche (cioè esemplari veri e propri delle piante). In particolare, in caso di biomonitoraggio le repliche del gruppo di controllo (“nel pulito”) dovranno essere lo stesso numero di quelle del gruppo per cui vogliamo monitorare lo stress ambientale. Le repliche di controllo potranno essere dislocate in un orto a disposizione dello stesso istituto o in un orto messo a disposizione da altro istituto **(DISPOSTO QUINDI A COLLABORARE)** e andrà mantenuto il collegamento tra gruppo per cui si monitora lo stress ambientale e il corrispondente gruppo di controllo. In particolare, ogni scuola dovrebbe concentrarsi su tre specie e ogni gruppo dovrebbe contenere 20 repliche. 

Per ogni specifica pianta messa a dimora **(PIANTA E REPLICA SONO DA CONSIDERARSI SINONIMI)**, verrà memorizzata la specie, il numero di replica, il gruppo, l’orto, l’esposizione specifica, la data di messa a dimora e la classe che l’ha messa a dimora. **(LE REPLICHE SONO IDENTIFICATE DAL NUMERO DI REPLICA E DALL’APPARTENENZA A UN GRUPPO, MA ANCHE DALLA CLASSE CHE LE HA MESSE A DIMORA INSIEME AL NUMERO DELLA REPLICA).** 

Le rilevazioni (osservazioni) vengono effettuate sulle specifiche piante (repliche) **(DISTINGUENDO TRA  ESPOSIZIONE CONSIGLIATA PER LA SPECIE E L'ESPOSIZIONE SPECIFICA PER LA REPLICA)** e le informazioni acquisite (in accordo alle schede in Allegato 2) memorizzate con data e ora della rilevazione, data e ora dell’inserimento, responsabile della rilevazione (può essere un individuo o una classe) e responsabile dell’inserimento (**(MEMORIZZATO)** se diverso da quello della rilevazione e anche in questo caso può essere un individuo o una classe). 

Le informazioni ambientali relative a pH, umidità e temperatura vengono acquisite mediante sensori o schede Arduino (vedi Allegato 3, da cui si possono dedurre le informazioni da monitorare per i diversi tipi di sensore/scheda), si vogliono memorizzare numero e tipo di sensori presenti in ogni orto (e le repliche associate a quel sensore). Le informazioni possono essere rilevate tramite app e inserite nella base di dati oppure essere trasmesse direttamente da schede Arduino alla base di dati. Si vuole tenere traccia della modalità di acquisizione delle informazioni."

------

------

---------------------------



## PROGETTAZIONE CONCETTUALE



### Diagramma ER

![Orto](C:\Users\sonia\OneDrive\Desktop\AGGIORNA\Orto.svg)

----

### Documentazione delle entità e degli attributi

Di seguito sono esposte le entità individuate con i relativi domini degli attributi. Per ciascuna entità, gli identificatori sono sottolineati oppure, nel caso di identificatori misti, sono esplicitati in fondo.

- **SCUOLA**:  rappresenta una scuola o istituto scolastico che partecipa all'iniziativa, identificata univocamente dal codice meccanografico. Ne viene salvato il nome, il ciclo di istruzione e la provincia. Il ciclo di una scuola può essere primo o secondo, quindi il suo dominio è stato codificato in {'1', '2'}.

  | ATTRIBUTO                   | DOMINIO              |
  | --------------------------- | -------------------- |
  | <u>codiceMeccanografico</u> | string               |
  | nomeScuola                  | string               |
  | ciclo                       | string{'1', '2'}     |
  | provincia                   | string (2 caratteri) |
  | comune                      | string               |

  

- **PERSONA:** è l’entità che indica una persona coinvolta nell’iniziativa, identificata univocamente dal codice fiscale, il quale è stato aggiunto perché non presente nella specifica del dominio.

  | **ATTRIBUTO** | **DOMINIO**          |
  | ------------- | -------------------- |
  | <u>CF</u>     | string(16 caratteri) |
  | nome          | string               |
  | cognome       | string               |
  | mail          | string               |
  | ruolo         | string               |
  | telefono      | int (Opzionale)      |



- **SPECIE**:  rappresenta le specie di piante coinvolte nell’iniziativa ed è identificata dal nome scientifico della specie. L’esposizione possibile è quella consigliata per la crescita delle piante di una determinata specie, ma ogni scuola può decidere, a seconda dei suoi spazi o di altre considerazioni, di non seguire il consiglio.

  | **ATTRIBUTO**          | **DOMINIO** |
  | ---------------------- | ----------- |
  | <u>nomeScientifico</u> | string      |
  | nomeComune             | string      |
  | esposizionePossibile   | string      |

  

- **REPLICA:** è l’entità che rappresenta le singole repliche di una specie. Ha quattro identificatori misti: l'associazione con FITOBONIFICA e il numero della replica; l'associazione con BIO-CONTROLLO e il numero della replica; l'associazione con BIO-STRESS e il numero della replica; l'associazione con CLASSE e il numero della replica.

  | **ATTRIBUTO**        | **DOMINIO**   |
  | -------------------- | ------------- |
  | numeroRep            | int(positivo) |
  | esposizioneSpecifica | string        |




- **GRUPPO**: è l'entità che raccoglie i gruppi che si trovano in un orto. E' identificata dal codGruppo, un codice (aggiunto) che lo identifica univocamente.

  | **ATTRIBUTO** | **DOMINIO**   |
  | ------------- | ------------- |
  | codGruppo     | int(positivo) |

  


- **BIO-CONTROLLO**: è il gruppo che contiene le repliche del gruppo di controllo per il biomonitoraggio piantate in un ambiente pulito. Potranno essere dislocate in un orto della stessa scuola oppure in uno messo a disposizione da un'altra. Il collegamento con il suo corrispondente gruppo stress è reso dall'attributo codBio, che per le coppie di gruppi stress/controllo è uguale.

  | **ATTRIBUTO** | **DOMINIO**   |
  | ------------- | ------------- |
  | codBio        | int(positivo) |

  

- **BIO-STRESS**: è il gruppo che contiene le repliche del gruppo di stress per il biomonitoraggio, posizionate in un ambiente sotto stress ambientale. L'attributo codBio è uguale a quello del gruppo di bio-controllo corrispondente.

  | **ATTRIBUTO** | **DOMINIO**   |
  | ------------- | ------------- |
  | codBio        | int(positivo) |

  

- **FITOBONIFICA**: è il gruppo che contiene le repliche del gruppo per la fitobonifica

  


- **SENSORE**: indica il tipo di sensore, o la scheda Arduino, che viene impiegato per la raccolta di informazione. E' stato aggiunto un codice di serie che lo identifica univocamente. Un sensore può essere associato a una o più piante e si trova in un orto.

  | ATTRIBUTO          | DOMINIO |
  | ------------------ | ------- |
  | <u>codiceSerie</u> | int     |
  | tipoSensore        | string  |

  

- **ORTO** :  è identificato mediante nome all'interno di una scuola e può contenere gruppi di repliche della scuola stessa o di altre. E' localizzato da coordinate GPS e può essere di tipo "in vaso" o "in pieno campo" con le condizioni che indicano se l'orto è mantenuto pulito con disponibilità dell'istituto per mantenerlo tale. 

Si sceglie si non usare le coordinate GPS come identificatore alternativo, siccome c'è la possibilità di errore di 7 metri, una distanza significativa.

| ATTRIBUTO     | DOMINIO                  |
| ------------- | ------------------------ |
| nomeOrto      | string                   |
| tipoOrto      | string {'vaso', 'campo'} |
| superficie    | double                   |
| GPS           | string                   |
| condizioni    | bool x bool              |
| numeroSensori | int(positivo)            |




- **CLASSE** : è identificata con il nome della classe all'interno di una scuola, l'attributo ordineTipo specifica se appartiene ad una scuola primaria o secondaria di primo grado o, nel caso di scuola superiore, esplicita l'indirizzo.

  | ATTRIBUTO  | DOMINIO |
  | ---------- | ------- |
  | nomeClasse | string  |
  | ordineTipo | string  |



- **RESPONSABILE** : rappresenta il responsabile di rilevazioni e inserimenti. E' identificato da un codice diverso per ogni responsabile, che può essere una classe oppure una persona. Altri identificatori esterni sono la persona e la classe.

  | ATTRIBUTO         | DOMINIO       |
  | ----------------- | ------------- |
  | <u>codiceResp</u> | int(positivo) |

  


- **RILEVAZIONE** : è l'entità che raccoglie informazioni di una specifica rilevazione, identificata dalla replica e dalla data e ora. Le informazioni riguardano la modalità di memorizzazione, che può avvenire tramite app o mediante schede Arduino, il tipo di coltivazione, il tipo di substrato, la data e l'ora di inserimento, specifiche riguardo la biomassa, le alterazioni di fioritura e fruttificazione, la presenza di danni evidenti e i parametri del suolo .

  | ATTRIBUTO            | DOMINIO                                                 |
  | -------------------- | ------------------------------------------------------- |
  | dataOraRil           | datetime                                                |
  | dataOraIns           | datetime                                                |
  | modalitaAcquisizione | string                                                  |
  | substrato            | string{'terriccio', 'suolo'}                            |
  | tipoColtivazione     | string{'vaso', 'campo'}                                 |
  | cosaMonitoro         | string{'suolo', 'aria'} (opzionale)                     |
  | biomassa             | double x double x double x double x double x double     |
  | fioriFrutti          | double x double x int(non negativo) x int(non negativo) |
  | danni                | int(positivo) x double                                  |
  | suolo                | double x double x double                                |

----

#### Vincoli non esprimibili nel diagramma

| nome | entità/associazioni coinvolte                              | descrizione                                                  |
| ---- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| v1   | RILEVAZIONE-dell'inserimento-RESPONSABILE                  | RILEVAZIONE partecipa a questa associazione con cardinalità 1 solo se il responsabile dell’inserimento è diverso dal responsabile della rilevazione |
| v2   | RESPONSABILE-è-PERSONA/CLASSE                              | Il responsabile, se esiste, è obbligatoriamente o una persona o una classe. |
| v3   | FITOBONIFICA/BIO-STRESS/BIO-CONTROLLO - contiene - REPLICA | Ogni gruppo di repliche di stress, di controllo o di fitobonifica deve contenere 20 repliche. |
| v4   | ORTO-ha-GRUPPO                                             | Se il campo PULIZIA dell'attributo composto CONDIZIONI in ORTO è "True" allora l'orto ha solo GRUPPI di controllo per il biomonitoraggio.  Se, invece, l'ambiente non è pulito allora può contenere solo GRUPPI per la fitobonifica o GRUPPI di stress per il biomonitoraggio. |
| v5   | CLASSE-di-SCUOLA                                           | L'attributo ciclo in SCUOLA deve essere coerente con l'attributo ordineTipo in CLASSE. |
| v6   | RILEVAZIONE, ORTO                                          | L'attributo tipoColtivazione in RILEVAZIONE deve essere coerente con l'attributo tipoOrto in ORTO, per una particolare replica in un determinato orto. |
| v7   | REPLICA-dislocata in-ORTO                                  | Non possono essere dislocate repliche da scuole esterne in orti non disponibili alla collaborazione, ovvero orti in cui l'attributo DISPONIBILITA è "False". |
| v8   | RILEVAZIONE                                                | Se il gruppo della REPLICA è 'fitobonifica' allora è obbligatorio l'attributo cosaMonitoro in RILEVAZIONE. Se è 'bio-controllo' o 'bio-stress' allora non deve essere presente. |
| v9   | SCUOLA-finanziamento-PERSONA                               | Nel caso in cui la scuola sia titolare di finanziamento per partecipare all'iniziativa, la partecipazione all'associazione è obbligatoria, altrimenti SCUOLA non deve partecipare all'associazione. |
| v10  | GRUPPO BIO-CONTROLLO / BIO-STRESS                          | L'attributo codBio è uguale per i corrispondenti gruppi di bio-controllo e bio-stress. |
| v11  | GRUPPO-contiene-REPLICHE-di-SPECIE                         | Un gruppo può contenere repliche di una sola specie          |
| v12  | RILEVAZIONE                                                | La data di inserimento dataOraIns deve essere successiva alla data di rilevazione dataOraRil |

--------

#### Specifica dei tipi di gerarchie di generalizzazione

| ENTITA' PADRE | ENTITA' FIGLIE                          | TIPOLOGIA        |
| ------------- | --------------------------------------- | ---------------- |
| GRUPPO        | BIO-STRESS, BIO-CONTROLLO, FITOBONIFICA | Totale/esclusiva |

----------

--------------

-------------------------

## PROGETTAZIONE LOGICA



### Diagramma ER ristrutturato

![OrtoRistrutturato](C:\Users\sonia\OneDrive\Desktop\AGGIORNA\OrtoRistrutturato.svg)





--------------------------

### Analisi delle ridondanze 

- **tipoColtivazione** in RILEVAZIONE: 

​		è ridondante perchè la stessa informazione è deducibile dall'attributo tipoOrto in ORTO.

- **numeroSensori** in ORTO: 

​		è ridondante perchè la stessa informazione è deducibile dall'associazione tra ORTO e SENSORE. 

- **esposizioneSpecifica** in REPLICA:

​		Non si ritiene ridondante perchè, sebbene l'attributo esposizionePossibile in SPECIE possa fornire la stessa informazione, 		non è detto che  la replica venga messa a dimora in modo corretto.

-----------

#### Modifiche dei domini degli attributi e informazioni sui domini di eventuali attributi introdotti; 

Sono riportati solo gli attributi per i quali è stato modificato il dominio.

- **ORTO**

  | **ATTRIBUTI** | DOMINI |
  | ------------- | ------ |
  | diponibilità  | bool   |
  | pulizia       | bool   |



- **RILEVAZIONE**

  | **ATTRIBUTI** | DOMINI        |
  | ------------- | ------------- |
  | pesoFrescoF   | double        |
  | pesoSeccoF    | double        |
  | larghezzaF    | double        |
  | lunghezzaF    | double        |
  | altezza       | double        |
  | lunghezzaR    | double        |
  | pesoFrescoR   | double        |
  | pesoSeccoR    | double        |
  | nFiori        | int(positivo) |
  | nFrutti       | int(positivo) |
  | nFoglie       | int(positivo) |
  | supPerc       | double        |
  | temperatura   | double        |
  | pH            | double        |
  | umidità       | double        |




- **GRUPPO**

  | **ATTRIBUTI** | DOMINI                                                |
  | ------------- | ----------------------------------------------------- |
  | tipoGruppo    | string{'bio-stress', 'bio-controllo', 'fitobonifica'} |
  | codBio        | int(positivo)                                         |



--------------------

#### Modifiche dei vincoli

| nome | entità/associazioni coinvolte | descrizione                                                  |
| ---- | ----------------------------- | ------------------------------------------------------------ |
| v3   | GRUPPO - contiene - REPLICA   | Ogni gruppo deve contenere 20 esemplari                      |
| v4   | ORTO-ha-GRUPPO                | Se l'attributo PULIZIA in ORTO è "True" allora l'orto ha solo GRUPPI con tipoGruppo uguale a 'bio-controllo', mentre se l'ambiente non è pulito allora può contenere solo GRUPPI con tipoGruppo uguale a 'fitobonifica' o 'bio-stress'. |
| v6   | RILEVAZIONE, ORTO             | non è più necessario perchè è stato rimosso tipoColtivazione in RILEVAZIONE |
| v10  | GRUPPO                        | L'attributo codBio è obbligatorio per i gruppi con tipoGruppo 'bio-stress' o 'bio-controllo', invece non deve essere presente per gruppi con tipoGruppo 'fitobonifica'. |

-------------------

#### Scelte per eliminare le gerarchie di generalizzazione 

- **GRUPPO** : vengono eliminate le entità figlie BIO-STRESS, BIO-CONTROLLO e FITOBONIFICA e viene aggiunto un attributo tipoGruppo, in cui si memorizza se il gruppo ha scopi di biomonitoraggio di stress o di controllo oppure di fitobonifica. Questo sarà obbligatorio, grazie alla totalità ed esclusività del tipo di gerarchia. Viene aggiunto l'attributo codBio, che è uguale per gruppi di biomionitoraggio corrispondenti tra stress e controllo e mantiene il loro legame. Non è presente nel caso il gruppo sia dedito alla fitobonifica.

--------------------------------------

#### Schema logico



**SCUOLA**(<u>codiceMeccanografico</u>, nomeScuola, ciclo, provincia, comune, referenteIniziativa<sup>PERSONA</sup>)



**PERSONA**(<u>CF</u>, nome, cognome, email, ruolo, telefono<sub>0</sub> )



**CLASSE**(<u>nomeClasse</u>, <u>scuola</u><sup>SCUOLA</sup>, ordineTipo, docenteRif<sup>PERSONA</sup>)



**SPECIE**(<u>nomeScientifico</u>, nomeComune, esposizionePossibile)



**ORTO**(<u>nomeOrto</u>, <u>scuola</u><sup>SCUOLA</sup>, tipoOrto, superficie, GPS, disponibilita, pulizia, numeroSensori)



**SENSORE**(<u>codiceSerie</u>, tipoSensore, orto<sup>ORTO</sup>, scuola<sup>ORTO</sup>)



**GRUPPO**(<u>codGruppo</u>, orto<sup>ORTO</sup>, scuola<sup>ORTO</sup>, tipoGruppo, codBio<sub>0</sub>)



**REPLICA**(<em><u>numeroRep</u></em>, <u>gruppo</u><sup>GRUPPO</sup>, esposizioneSpecifica, dataMessaADimora, <em>classeMessaADimora<sup>CLASSE</sup></em>, <em>scuolaMessaADimora<sup>CLASSE</sup></em>, sensore<sup>SENSORE</sup>, specie<sup>SPECIE</sup>)

- Nella relazione REPLICA è presente la chiave alternativa {numeroRep, classe, scuola}. Si è deciso di prendere come chiave primaria {numeroRep, gruppo} perchè i due attributi hanno valori numerici.



**RESPOSABILE**(<u>codiceResp</u>, persona<sub>0</sub><sup>PERSONA</sup>, classe<sub>0</sub><sup>CLASSE</sup>, scuola<sub>0</sub><sup>CLASSE</sup>)

- La relazione RESPONSABILE ha come chiavi alternative {persona} e {classe,scuola}.

  

**RILEVAZIONE**(<u>replica</u><sup>REPLICA</sup>, <u>gruppo</u><sup>REPLICA</sup>, <u>dataOraRil</u>, dataOraIns, modalitaAcquisizione, substrato, cosaMonitoro<sub>0</sub> , pesoFrescoF, pesoSeccoF, larghezzaF, lunghezzaF, altezza, lunghezzaR, pesoFrescoR, pesoSeccoR, nFiori, nFrutti, nFoglie, supPerc, temperatura, pH, umidità, responsabileRilevazione<sup>RESPONSABILE</sup>, responsabileInserimento<sub>0</sub><sup>RESPONSABILE</sup>) 



**FINANZIAMENTO**(<u>scuola</u><sup>SCUOLA</sup>, <u>referenteFin</u><sup>PERSONA</sup>, <u>partecipanteFin</u><sup>PERSONA</sup>, tipoFin)

- sotto il vincolo di integrità: una scuola può avere al più un solo finanziamento, la relazione diventa

​		**FINANZIAMENTO**(<u>scuola</u><sup>SCUOLA</sup>, referenteFin<sup>PERSONA</sup>, partecipanteFin<sup>PERSONA</sup>, tipoFin)



**SIOCCUPADI**(<u>scuola</u><sup>SCUOLA</sup>, <u>specie</u><sup>SPECIE</sup>)

- con il vincolo di integrità: una scuola deve occuparsi obbligatoriamente di tre specie diverse.


-----

#### Verifica di qualità dello schema 

In base all'interpretazione del dominio e allo schema relazionale individuato, si studiano le dipendenze funzionali e si individuano le chiavi per verificare la qualità delle relazioni.

- **SCUOLA** :

  - Dipendenze funzionali :

    ​	codiceMeccanografico &rarr; nomeScuola, comune, provincia, ciclo, referenteIniziativa

  - Chiavi e conclusioni :

    ​	La chiave della relazione SCUOLA è {codiceMeccanografico}.

    ​	La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

    

- **PERSONA** :

  - Dipendenze funzionali :

    ​	CF &rarr; ruolo, telefono, nome, cognome, email 

  - Chiavi e conclusioni :
    La chiave della relazione PERSONA è {CF}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

    

- **CLASSE** :

  - Dipendenze funzionali :

    ​	nomeClasse, Scuola &rarr; ordineTipo, docenteRif

  - Chiavi e conclusioni :
    Le chiave della relazione CLASSE è {nomeClasse, Scuola}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

    

- **FINANZIAMENTO**

  - Dipendenze funzionali :

    ​	scuola &rarr; referenteFin, partecipanteFin, tipoFin

  - Chiavi e conclusioni :
    Le chiave della relazione FINANZIAMENTO è {scuola}
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione

  

- **ORTO** :

  - Dipendenze funzionali :
    nomeOrto, Scuola &rarr; disponibilità, pulizia, superficie, GPS, tipoOrto, numeroSensori

  - Chiavi e conclusioni :
    La chiave della relazione ORTO è {nomeOrto, Scuola}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

    

- **GRUPPO**

  - Dipendenze funzionali :

    ​	codGruppo &rarr; orto, scuola, tipoGruppo, codBio

  - Chiavi e conclusioni :
    La chiave della relazione GRUPPO è {codGruppo}
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione

    

- **SENSORE** :

  - Dipendenze funzionali : 

    ​	codiceSerie &rarr; tipoSensore, orto, scuola

  - Chiavi e conclusioni :
    La chiave della relazione SENSORE è {codiceSerie}
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione

  

- **SPECIE** :

  - Dipendenze funzionali :
    nomeScientifico &rarr; esposizionePossibile, nomeComune 

  - Chiavi e conclusioni :
    La chiave della relazione SPECIE è {nomeScientifico}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

    

- **SIOCCUPADI**

  - Dipendenze funzionali : 

    ​	scuola, specie &rarr;scuola, specie

  - Chiavi e conclusioni :
    La chiave della relazione SIOCCUPADI è {scuola, specie}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

  

- **REPLICA** :                                             

  - Dipendenze funzionali :

    ​	numeroRep, gruppo &rarr; esposizioneSpecifica, dataMessaDimora, classe, scuola, sensore, specie

    ​	numeroRep, classe, scuola &rarr; esposizioneSpecifica, dataMessaDimora, gruppo, sensore, specie

  - Chiavi e conclusioni :
    Le chiavi della relazione REPLICA sono {numeroRep, gruppo} e {numeroRep, classe, scuola}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

    

- **RESPONSABILE**

  - Dipendenze funzionali :

    ​	codiceResp   &rarr;  CF, classe, scuola

  - Chiavi e conclusioni :
    La chiave della relazione RESPONSABILE è {codiceResp}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.


- **RILEVAZIONE** :

  - Dipendenze funzionali :

    ​	dataOraRil, replica gruppo &rarr; pesoFrescoR, pesoSeccoR, nFrutti, nFiori, nFoglie, supPerc, substrato, DataOraIns, modalitaAcquisizione, lunghezzaF, altezza, lunghezzaR, pesoFrescoF, larghezzaF, pesoSeccoF 

  - Chiavi e conclusioni :
    La chiave della relazione RILEVAZIONE è {dataOraRil, replica, gruppo}.
    La relazione è in BCNF dato che la dipendenza funzionale presenta a sinistra una chiave della relazione.

-----


#### Scelte per l'implementazione dei vincoli

| **NOME VINCOLO** | **RELAZIONI COINVOLTE** | **DESCRIZIONE**                                              | **TIPOLOGIA** |
| ---------------- | ----------------------- | ------------------------------------------------------------ | ------------- |
| v1               | RILEVAZIONE             | O il responsabileInserimento è NULL o se non lo è allora questo deve essere diverso dal responsabileRilevazione. | CHECK         |
| v2               | RESPONSABILE            | O {persone} è NULL o {classe, scuola} sono NULL, non possono esserci entrambe le chiavi alternative né possono essere entrambe NULL. | CHECK         |
| v3               | REPLICA                 | Ogni gruppo deve contenere 20 repliche.                      | TRIGGER       |
| v4               | ORTO, GRUPPO            | Se l'attributo PULIZIA in ORTO è "True" allora l'orto ha solo GRUPPI con tipoGruppo uguale a 'bio-controllo', mentre se l'ambiente non è pulito allora può contenere solo GRUPPI con tipoGruppo uguale a 'fitobonifica' o 'bio-stress'. | TRIGGER       |
| v5               | CLASSE, SCUOLA          | L'attributo ciclo in SCUOLA deve essere coerente con l'attributo ordineTipo in CLASSE. | TRIGGER       |
| v6               | ORTO, GRUPPO            | Non possono essere dislocate repliche da scuole esterne in orti non disponibili alla collaborazione, ovvero orti in cui l'attributo DISPONIBILITA è "False". | TRIGGER       |
| v7               | GRUPPO, RILEVAZIONE     | Se il gruppo della REPLICA è 'fitobonifica' allora è obbligatorio l'attributo cosaMonitoro in RILEVAZIONE. Se è 'bio-controllo' o 'bio-stress' allora non deve essere presente. | TRIGGER       |
| v10              | GRUPPO                  | L'attributo codBio è obbligatorio per i gruppi con tipoGruppo 'bio-stress' o 'bio-controllo', invece non deve essere presente per gruppi con tipoGruppo 'fitobonifica'. | CHECK         |
| v11              | REPLICA                 | Una sola specie per gruppo                                   | TRIGGER       |
| v12              | RILEVAZIONE             | dataOraIns >= dataOraRil                                     | CHECK         |
| v13              | GRUPPO                  | A un gruppo di bio-stress deve corrisponderne uno solo di bio-controllo e viceversa | TRIGGER       |

----

#### Ipotesi del carico di lavoro

In base allo schema logico definito e alcune richieste da svolgere, sono state ipotizzate alcune operazioni possibili sulla base di dati.



- Operazione 1

  Inserisce una rilevazione a settimana per ogni replica (frequenza: 60 rilevazioni/settimana per ogni scuola).

  

- Operazione 2

  Stampa una volta al mese la media dei parametri per ogni gruppo (frequenza: 1 stampa/mese).

  

- Operazione 3

  Stampa gli orti presenti in un comune (frequenza: 1 stampa/anno).

  

- Operazione 4

  Stampa il responsabile di più rilevazioni del mese (frequenza: 1 stampa/mese)

  

- Operazione 5

  Aggiorna il docente di riferimento della classe ogni anno (frequenza: 1 aggiornamento/anno per classe)

  

--------------------------------------------

-----------

---------------------------------------





