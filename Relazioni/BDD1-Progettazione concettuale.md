# RELAZIONE DI BASI DI DATI

Simone Lazzaro, Fabrizio Sardo, Sonia Spinelli

###### PARTE I

## PROGETTAZIONE CONCETTUALE



### Diagramma ER



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

  | **ATTRIBUTO**        | **DOMINIO**                                |
  | -------------------- | ------------------------------------------ |
  | numeroRep            | int(positivo)                              |
  | esposizioneSpecifica | string                                     |




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



- **RESPONSABILE** : rappresenta il responsabile di rilevazioni e inserimenti. E' identificato da un codice diverso per ogni responsabile, che può essere una classe oppure una persona.

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



#### Vincoli non esprimibili nel diagramma

| nome | entità/associazioni coinvolte                              | descrizione                                                  |
| ---- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| v1   | RILEVAZIONE-dell'inserimento-RESPONSABILE                   | RILEVAZIONE partecipa a questa associazione con cardinalità 1 solo se il responsabile dell’inserimento è diverso dal responsabile della rilevazione |
| v2   | RESPONSABILE-è-PERSONA/CLASSE                              | Il responsabile, se esiste, è obbligatoriamente o una persona o una classe. | CHECK
| v3   | FITOBONIFICA/BIO-STRESS/BIO-CONTROLLO - contiene - REPLICA | Ogni gruppo di repliche di stress, di controllo o di fitobonifica deve contenere 20 esemplari **Serve???** |
| v4   | BIO-STRESS/BIO-CONTROLLO - contiene - REPLICA              | Se lo scopo di una replica è biomonitoraggio, allora le repliche del gruppo di controllo dovranno essere lo stesso numero di quelle del gruppo per cui si monitora lo stress ambientale. |
| v5   | ORTO-ha-GRUPPO                                             | Se il campo PULIZIA dell'attributo composto CONDIZIONI in ORTO è "TRUE" allora l'orto ha solo GRUPPI di controllo per il biomonitoraggio.  Se, invece, l'ambiente non è pulito allora può contenere solo GRUPPI per la fitobonifica o GRUPPI di stress per il biomonitoraggio. |
| v6   | CLASSE-di-SCUOLA                                           | L'attributo ciclo in SCUOLA deve essere coerente con l'attributo ordineTipo in CLASSE. |
| v7   | RILEVAZIONE, ORTO                                          | L'attributo tipoColtivazione in RILEVAZIONE deve essere coerente con l'attributo tipoOrto in ORTO, per una particolare replica in un determinato orto. |
| v8   | REPLICA-dislocata in-ORTO                                  | Non possono essere dislocate repliche da scuole esterne in orti non disponibili alla collaborazione, ovvero orti in cui l'attributo DISPONIBILITA è "False". |
| v9   | RILEVAZIONE                                                | Se il gruppo della REPLICA è 'fitobonifica' allora è obbligatorio l'attributo cosaMonitoro in RILEVAZIONE. Se è 'bio-controllo' o 'bio-stress' allora non deve essere presente. |
| v10  | SCUOLA-finanziamento-PERSONA                               | Nel caso in cui la scuola sia titolare di finanziamento per partecipare all'iniziativa, la partecipazione all'associazione è obbligatoria, altrimenti SCUOLA non deve partecipare all'associazione. |
| v11  | SCUOLA-finanziamento                                       | Una scuola può partecipare all'associazione finanziamento solo una volta |
| v12  | GRUPPO BIO-CONTROLLO / BIO-STRESS                          | L'attributo codBio è uguale per i corrispondenti gruppi di bio-controllo e bio-stress. |



#### Specifica dei tipi di gerarchie di generalizzazione

| ENTITA' PADRE | ENTITA' FIGLIE                          | TIPOLOGIA        |
| ------------- | --------------------------------------- | ---------------- |
| GRUPPO        | BIO-STRESS, BIO-CONTROLLO, FITOBONIFICA | Totale/esclusiva |

