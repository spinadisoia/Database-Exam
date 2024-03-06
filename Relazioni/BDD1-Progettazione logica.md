



# RELAZIONE DI BASI DI DATI

Simone Lazzaro, Fabrizio Sardo, Sonia Spinelli

###### PARTE I

## PROGETTAZIONE LOGICA



### Diagramma ER ristrutturato





### Analisi delle ridondanze 

- **tipoColtivazione** in RILEVAZIONE: 

  è ridondante perchè la stessa informazione è deducibile dall'attributo tipoOrto in ORTO. 

  

- **esposizioneSpecifica** in REPLICA:

  Non si ritiene ridondante perchè, sebbene l'attributo esposizionePossibile in SPECIE possa fornire la stessa informazione, non è detto che  la replica venga messa a dimora in modo corretto.

  

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





#### Modifiche dei vincoli

| nome | entità/associazioni coinvolte | descrizione                                                  |
| ---- | ----------------------------- | ------------------------------------------------------------ |
| v3   | GRUPPO - contiene - REPLICA   | Ogni gruppo deve contenere 20 esemplari | 
| v4   | GRUPPO - contiene - REPLICA   | Se lo scopo di una replica è biomonitoraggio, allora i gruppi aventi lo stesso codBio dovranno avere lo stesso numero di repliche |
| v5   | ORTO-ha-GRUPPO                | Se l'attributo PULIZIA in ORTO è "True" allora l'orto ha solo GRUPPI di controllo per il biomonitoraggio, mentre se l'ambiente non è pulito allora può contenere solo GRUPPI per la fitobonifica o GRUPPI di stress per il biomonitoraggio. |
| v12  | GRUPPO                        | L'attributo codBio è obbligatorio per i gruppi con tipoGruppo 'bio-stress' o 'bio-controllo', invece non deve essere presente per gruppi con tipoGruppo 'fitobonifica'. |

ELIMINATO v7 perché è stato rimosso tipoColtivazione in RILEVAZIONE



#### Scelte per eliminare le gerarchie di generalizzazione 

- **GRUPPO** : vengono eliminate le entità figlie BIO-STRESS, BIO-CONTROLLO e FITOBONIFICA e viene aggiunto un attributo tipoGruppo, in cui si memorizza se il gruppo ha scopi di biomonitoraggio di stress o di controllo oppure di fitobonifica. Questo sarà obbligatorio, grazie alla totalità ed esclusività del tipo di gerarchia. Viene aggiunto l'attributo codBio, che è uguale per gruppi di biomionitoraggio corrispondenti tra strass e controllo e mantiene il loro legame. Non è presente nel caso il gruppo sia dedito alla fitobonifica.



#### Schema logico

**SCUOLA**(<u>codiceMeccanografico</u>, nomeScuola, ciclo, provincia, comune, referenteIniziativa<sup>PERSONA</sup>)

**PERSONA**(<u>CF</u>, nome, cognome, email, ruolo, telefono<sub>0</sub> )

**CLASSE**(<u>nomeClasse</u>, <u>scuola</u><sup>SCUOLA</sup>, ordineTipo, docenteRif<sup>PERSONA</sup>)

**SPECIE**(<u>nomeScientifico</u>, nomeComune, esposizionePossibile)

**ORTO**(<u>nomeOrto</u>, <u>scuola</u><sup>SCUOLA</sup>, tipoOrto, superficie, GPS, disponibilita, pulizia, numeroSensori)

**SENSORE**(<u>codiceSerie</u>, tipoSensore, orto<sup>ORTO</sup>, scuola<sup>ORTO</sup>)

**GRUPPO**(<u>codGruppo</u>, orto<sup>ORTO</sup>, scuola<sup>ORTO</sup>, tipoGruppo, codBio<sub>0</sub>)

**REPLICA**(<em><u>numeroRep</u></em>, <u>gruppo</u><sup>GRUPPO</sup>, esposizioneSpecifica, dataMessaADimora, <em>classeMessaADimora<sup>CLASSE</sup></em>, <em>scuolaMessaADimora<sup>CLASSE</sup></em>, sensore<sup>SENSORE</sup>, specie<sup>SPECIE</sup>)

**RESPOSABILE**(<u>codiceResp</u>, persona<sub>0</sub><sup>PERSONA</sup>, classe<sub>0</sub><sup>CLASSE</sup>, scuola<sub>0</sub><sup>CLASSE</sup>)

**RILEVAZIONE**(<u>replica</u><sup>REPLICA</sup>, <u>gruppo</u><sup>REPLICA</sup>, <u>dataOraRil</u>, dataOraIns, modalitaAcquisizione, substrato, cosaMonitoro <sub>0</sub> , pesoFrescoF, pesoSeccoF, larghezzaF, lunghezzaF, altezza, lunghezzaR, pesoFrescoR, pesoSeccoR, nFiori, nFrutti, nFoglie, supPerc, temperatura, pH, umidità, responsabileRilevazione<sup>RESPONSABILE</sup>,responsabileInserimento<sub>0</sub><sup>RESPONSABILE</sup>) 

**FINANZIAMENTO**(<u>scuola</u><sup>SCUOLA</sup>, referenteFin<sup>PERSONA</sup>, partecipanteFin<sup>PERSONA</sup>, tipoFin)

**SIOCCUPADI**(<u>scuola</u><sup>SCUOLA</sup>, <u>specie</u><sup>SPECIE</sup>)


<u>Vincoli di integrità</u>:

- **SIOCCUPADI**: una scuola deve occuparsi obbligatoriamente di tre specie diverse.
- **FINANZIAMENTO**: una scuola può avere al più un solo finanziamento.


Nella relazione REPLICA è presente la chiave alternativa {numeroRep, classe, scuola}. Si è deciso di prendere come chiave primaria {numeroRep, gruppo} perchè i due attributi hanno valori numerici.


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


### Scelte per l'implementazione dei vincoli

RICONTOLLARE RELAZIONI COINVOLTE PERCHé QUALCHE NOME POTREBBE ESSERE RIMASTO DAL PRIMO ER

  | **NOME VINCOLO** |**RELAZIONI COINVOLTE**|**DESCRIZIONE**| **TIPOLOGIA** |
  | --- | --- | --- | --- |
  | v1 | RILEVAZIONE-dell'inserimento-RESPONSABILE | RILEVAZIONE partecipa a questa associazione con cardinalità 1 solo se il responsabile dell’inserimento è diverso dal responsabile della rilevazione | CHECK |
  | v2 | RESPONSABILE-è-PERSONA/CLASSE | Il responsabile, se esiste, è obbligatoriamente o una persona o una classe. | CHECK |
  | v3 | GRUPPO - contiene - REPLICA | Ogni gruppo deve contenere 20 esemplari | TRIGGER |
  | v4 | GRUPPO - contiene - REPLICA | Se lo scopo di una replica è biomonitoraggio, allora i gruppi aventi lo stesso codBio dovranno avere lo stesso numero di repliche | TRIGGER |
  | v5 | ORTO-ha-GRUPPO | Se l'attributo PULIZIA in ORTO è "True" allora l'orto ha solo GRUPPI di controllo per il biomonitoraggio, mentre se l'ambiente non è pulito allora può contenere solo GRUPPI per la fitobonifica o GRUPPI di stress per il biomonitoraggio. | TRIGGER |
  | v6 | CLASSE-di-SCUOLA | L'attributo ciclo in SCUOLA deve essere coerente con l'attributo ordineTipo in CLASSE. | TRIGGER |
  | v8 | ORTO-ha-GRUPPO | Non possono essere dislocate repliche da scuole esterne in orti non disponibili alla collaborazione, ovvero orti in cui l'attributo DISPONIBILITA è "False". | TRIGGER |
  | v9 | GRUPPO, RILEVAZIONE | Se il gruppo della REPLICA è 'fitobonifica' allora è obbligatorio l'attributo cosaMonitoro in RILEVAZIONE. Se è 'bio-controllo' o 'bio-stress' allora non deve essere presente. | TRIGGER |
  | v10 | FINANZIAMENTO | Nel caso in cui la scuola sia titolare di finanziamento per partecipare all'iniziativa, la partecipazione all'associazione è obbligatoria, altrimenti SCUOLA non deve partecipare all'associazione. | SI è AUTOIMPLEMENTATO FACENDO LA RELAZIONE |
  | v11 | SCUOLA-FINANZIAMENTO | Una scuola può partecipare all'associazione finanziamento solo una volta | COME V10 |
  | v12 | GRUPPO | L'attributo codBio è obbligatorio per i gruppi con tipoGruppo 'bio-stress' o 'bio-controllo', invece non deve essere presente per gruppi con tipoGruppo 'fitobonifica'. | CHECK |
  | v13 | GRUPPO | A un gruppo di bio-stress deve corrisponderne uno solo di bio-controllo e viceversa | TRIGGER |
  | v14 | GRUPPO-SPECIE (FORSE DA AGGIUNGERE ANCHE AI PRIMI VINCOLI) | Una sola specie per gruppo | TRIGGER |


V15? CLASSE METTE A DIMORA DEVE ESSERE DELLA SCUOLA CHE SI OCCUPA DI QUELLA SPECIE (TRIGGER) -> Una classe 'esterna' può mettere a dimora una replica della 'nostra' scuola? Se sì va benissimo perché fare questo vincolo non è semplice.
