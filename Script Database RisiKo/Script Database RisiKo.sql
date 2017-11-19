--------------------------  --------------------------  [Definizione Tabelle]  --------------------------  --------------------------  

/* PARTITA: contiene informazioni relative a ogni partita e al giocatore vincente */
CREATE TABLE PARTITA
(
    /* Attributi Chiave */
    ID_PARTITA    NUMBER(6) PRIMARY KEY, -- Identifica univocamente ogni singola partita con un valore numero crescente (non visibile all'utente)

    /* Attributi */
    NOME_PARTITA  VARCHAR2(30) UNIQUE,   -- Indrodotto per facilitare eventuali ricerche di una partita partendo dal suo nome (visibile all'utente)
    DATA          DATE NOT NULL,         -- Utilizzato per eventuali query
    ID_GAMER_VINC NUMBER(1)              -- Informazione relativa all'id (numero identificativo) del gioctore vincente
);
  
/

/* CARTA_OBIETTIVO: contiene informazioni reletive alle carte di tipo obiettivo */
CREATE TABLE CARTA_OBIETTIVO
(
    /* Attributi Chiave */
    ID_CARTA    NUMBER(6) NOT NULL,     -- Identifica ogni singola carta obiettivo

    /* Attributi */
    DESCRIZIONE VARCHAR2(400) NOT NULL, -- Descrizione visibile al giocatore riguardante l'obiettivo da completare
    
	/* Vincoli */
    CONSTRAINT PK_Carta_Obiettivo PRIMARY KEY (ID_CARTA) ENABLE
);
  
/

/* GIOCATORE: contiene informazioni reletive ai giocatore presenti in ogni partita con i rispettivi obiettivi e il "giro" da effettuare */
CREATE TABLE GIOCATORE
(
    
    /* Attributi Chiave */
    ID_GAMER           NUMBER(1) NOT NULL,   -- Identificatore numerico (da 1 a 6) associato ad ogni giocatore in ogni partita
    ID_PARTITA         NUMBER(6) NOT NULL,   -- Riferimento a ID_PARTITA nella tabella PARTITA

    /* Attributi */
    COLORE             CHAR(1),              -- Identifica il colore scelto dalla armate del giocatore. Puo' essere: R (Rosso), N (Nero), G (Giallo), V (Verde), B (Blu), U (Viola)
    NICKNAME           VARCHAR2(30),         -- Identifica il nickname scelto dal giocatore
    ID_CARTA_OBIETTIVO NUMBER(6),            -- Riferimento a ID_CARTA nella tabella CARTA_OBIETTIVO
    Posizione_Turno    NUMBER(1),            -- Stabilisce in maniera numerica (da 1 a 6 a seconda dei giocatori) il turno/giro dei vari giocatori. (nda: in partica a chi tocca)
    N_Armate_Tot       NUMBER(32) DEFAULT 0, -- Informazione relativa alle armate tatali possedute dal giocatore in tutto il mondo
    
	/* Vincoli */
    CONSTRAINT PK_Giocatore PRIMARY KEY (ID_GAMER,ID_PARTITA) ENABLE,
    CONSTRAINT FK_ID_Partita FOREIGN KEY (ID_PARTITA) REFERENCES PARTITA (ID_PARTITA) ON DELETE CASCADE ENABLE,
    CONSTRAINT FK_ID_Carta_Obiettivo FOREIGN KEY (ID_CARTA_OBIETTIVO) REFERENCES CARTA_OBIETTIVO(ID_CARTA),
    CONSTRAINT Controllo_Colore CHECK (Colore IN('R', 'N', 'G', 'V', 'B', 'U')) ENABLE -- R=Rosso, N=Nero, G=Giallo, V=Verde, B=Blu, U=Viola
);
  
/

/* TURNO: contiene informazioni riguardante ogni singolo turno svolto da ogni giocatore in partita. Turno permette di creare ordine in base alle azioni svolte. */
CREATE TABLE TURNO
(
    /* Attributi Chiave */
    ID_TURNO    NUMBER(6) DEFAULT 0, -- Valore numerico crescente che identifica il turno di ogni giocatore. Quando turno e' 0 (zero) si eseguono le azioni del turno preliminare (conto giocatori, scelta giro, assegnazione carte ecc...)
    ID_PARTITA  NUMBER(6) NOT NULL,  -- Riferimento a ID_PARTITA nella tabella PARTITA

    /* Attributi */
    ID_GAMER    NUMBER(1) NOT NULL,  -- Riferimento a ID_GAMER nella tabella GIOCATORE
 
    /* Vincoli */
    CONSTRAINT PK_Turno PRIMARY KEY (ID_TURNO, ID_PARTITA) ENABLE,
    CONSTRAINT FK_Turno_ID_Partita FOREIGN KEY (ID_PARTITA) REFERENCES PARTITA (ID_PARTITA) ON DELETE CASCADE ENABLE,
    CONSTRAINT FK_Turno_ID_Gamer FOREIGN KEY (ID_GAMER,ID_PARTITA) REFERENCES GIOCATORE (ID_GAMER,ID_PARTITA) ON DELETE CASCADE ENABLE
);
  
/

/* TERRITORIO: contiene informazioni relative ai territori presenti nel gioco */
CREATE TABLE TERRITORIO
(
    /* Attributi Chiave */
    ID_TERRITORIO   NUMBER(2) NOT NULL,    -- Valore numerico che identifica il territorio

    /* Attributi */
    NOME_TERRITORIO VARCHAR2(60) UNIQUE,   -- Nome associato al valore numerico di un territorio
    ID_CONTINENTE   NUMBER(1) NOT NULL,    -- Valore numerico che identifica un continenete comprendente n° territori
    NOME_CONTINENTE VARCHAR2(60) NOT NULL, -- Nome associato al valore numerico di un territorio
   
    /* Vincoli */
    CONSTRAINT PK_Territorio PRIMARY KEY (ID_TERRITORIO) ENABLE
);
  
/

/* POSIZIONAMENTO_ARMATA: contiene informazioni relative alla prima fase di gioco che prevedere il posizionamento di tot armate */
CREATE TABLE POSIZIONAMENTO_ARMATA
(
    /* Attributi Chiave */
    ID_POSIZIONAMENTO NUMBER(6) NOT NULL,   			-- Valore numerico crescente che identifica ongi singolo spostamento da parte dei giocatori
    ID_TURNO          NUMBER(6) NOT NULL,			    -- Riferimento a ID_TURNO nella tabella TURNO
    ID_PARTITA        NUMBER(6) NOT NULL,  		        -- Riferimento a ID_PARTITA nella tabella TURNO->PARTITA

    /* Attributi */
    RINFORZI_TRUPPE   NUMBER(3) NOT NULL, 				-- Numero di truppe che il giocatore guadagna dopo ogni turno e/o dal bonus carte che ha a disposizione
    TIPO_POSIZIONAMENTO NUMBER(1) NOT NULL,             -- Valore numerico che indica la tipologia di posizionamento effettuata dal giocatore 
    ID_TERRITORIO_POS NUMBER(2) NOT NULL,
	  
    /* Vincoli */
    CONSTRAINT PK_Pos_Armata PRIMARY KEY (ID_POSIZIONAMENTO, ID_PARTITA, ID_TURNO) ENABLE,
    CONSTRAINT FK_Pos_Turno FOREIGN KEY (ID_TURNO, ID_PARTITA) REFERENCES TURNO (ID_TURNO, ID_PARTITA) ON DELETE CASCADE ENABLE, -- Default No Action
	CONSTRAINT Controllo_Posizionamento CHECK (TIPO_POSIZIONAMENTO IN('0','1','2','3','4','5','6','7','8')) ENABLE,
	-- Valori numerici:
	-- 0 = Inserimento di fase preliminare 
	-- 1 = Inserimento classico
	-- 2 a 8 = Inserimenti derivati dalla combinazione di carte scelta (ulteriori info nella documentazione dell'applicativo)
	CONSTRAINT FK_ID_Territorio_Pos FOREIGN KEY (ID_TERRITORIO_POS) REFERENCES TERRITORIO(ID_TERRITORIO) ENABLE
);


/

/* COMBATTIMENTO: contiene informazioni relative alla seconda fase di gioco che puo' effettuare un giocatore nel suo turno */
CREATE TABLE COMBATTIMENTO
(
    /* Attributi Chiave */
    ID_COMB                  NUMBER(6) NOT NULL,    -- Valore crescente associato ad ogni combattimento effettuato
    ID_TURNO                 NUMBER(6) NOT NULL,    -- Riferimento a ID_TURNO nella tabella TURNO
    ID_PARTITA               NUMBER(6) NOT NULL,    -- Riferimento a ID_PARTITA nella tabella TURNO->PARTITA
    
    /*Attributi*/
    ID_G_DIFENSORE           NUMBER(1) NOT NULL,    -- Riferimento a ID_GAMER nella tabella GIOCATORE
    VINCENTE                 NUMBER(1) ,            -- 1 se tale combattimento ha portato ad una conquista; 0 se è stato infruttuoso.
    TIPO_AVANZAMENTO         NUMBER(1) ,            -- 1 Se le armate d'avanzare sono quelle pari al numero di dadi lanciati; 2 Se le armate d'avanzare sono tutte le armate presenti sul territorio meno uno.
    ID_TERRITORIO_ATTACCANTE NUMBER(2) NOT NULL,    -- Riferimento a ID_TERRITORIO nella tabella TERRITORIO
    ID_TERRITORIO_ATTACCATO  NUMBER(2) NOT NULL,    -- Riferimento a ID_TERRITORIO nella tabella TERRITORIO
    
    /* Vincoli */
    CONSTRAINT PK_Combattimento PRIMARY KEY (ID_COMB, ID_TURNO, ID_PARTITA) ENABLE,
    CONSTRAINT FK_Combattimento_Turno FOREIGN KEY (ID_TURNO, ID_PARTITA) REFERENCES TURNO(ID_TURNO, ID_PARTITA) ON DELETE CASCADE ENABLE,
    CONSTRAINT FK_Terr_Attaccante FOREIGN KEY (ID_TERRITORIO_ATTACCANTE) REFERENCES TERRITORIO(ID_TERRITORIO) ENABLE,   -- Default No Action
    CONSTRAINT FK_Terr_Attaccato FOREIGN KEY (ID_TERRITORIO_ATTACCATO) REFERENCES TERRITORIO(ID_TERRITORIO) ENABLE,     -- Default No Action
    CONSTRAINT FK_Difensore FOREIGN KEY (ID_G_DIFENSORE, ID_PARTITA) REFERENCES GIOCATORE(ID_GAMER, ID_PARTITA) ON DELETE CASCADE ENABLE,
    CONSTRAINT TIPO_S CHECK((TIPO_AVANZAMENTO = 1) OR ( TIPO_AVANZAMENTO = 2)), -- 1 Se dopo un attacco devono esser spostare SOLO le armate pari ai dadi lanciati; 2 Se devono esser spostate tutte le armate presenti sul territorio.
    CONSTRAINT TIPO_V CHECK((VINCENTE = 0) OR (VINCENTE = 1))
);
  
/

/* LANCIO DADI: contiene informazioni sul lancio dei dadi effettuati dal giocatore attaccate e difensore */  
CREATE TABLE LANCIO_DADI
(
    /* Attributi Chiave */
    ID_COMB       NUMBER(6),           -- Valore crescente associato ad ogni combattimento effettuato
    N_LANCIO      NUMBER(6) NOT NULL,  -- Valore numerico usato come chiave tecnica assieme a ID_TURNO, ID_PARTITA 
    ID_TURNO      NUMBER(6) NOT NULL,  -- Riferimento a ID_TURNO nella tabella TURNO
    ID_PARTITA    NUMBER(6) NOT NULL,  -- Riferimento a ID_PARTITA nella tabella TURNO->PARTITA
    
    /*Attributi*/
    DADO1_ATT     NUMBER(1) NOT NULL,  -- Dado 1 usato dall'attaccante (Not null prevede che ci debba essere almeno un dado da lanciare per poter essere in fase di combattimento/difesa)
    DADO2_ATT     NUMBER(1),           -- Dado 2 usato dall'attaccante
    DADO3_ATT     NUMBER(1),           -- Dado 3 usato dall'attaccante
    DADO1_DIFF    NUMBER(1) NOT NULL,  -- Dado 1 usato dall'difensore
    DADO2_DIFF    NUMBER(1),           -- Dado 2 usato dall'difensore
    DADO3_DIFF    NUMBER(1),           -- Dado 3 usato dall'difensore
	
    /* Vincoli */
    CONSTRAINT PK_Lancio_Dadi PRIMARY KEY (ID_PARTITA, ID_TURNO, ID_COMB, N_LANCIO) ENABLE,
    CONSTRAINT FK_Lancio_Dadi_Comabttimento FOREIGN KEY (ID_TURNO, ID_PARTITA,ID_COMB) REFERENCES COMBATTIMENTO(ID_TURNO, ID_PARTITA,ID_COMB) ON DELETE CASCADE ENABLE, -- Default No Action
    /* Viene fatto un controllo per il numero massimo e minimo di ogni dado */
    CONSTRAINT Val_Dadi CHECK((DADO1_ATT BETWEEN 1 AND 6) AND (DADO2_ATT BETWEEN 1 AND 6) AND (DADO3_ATT BETWEEN 1 AND 6) AND (DADO1_DIFF BETWEEN 1 AND 6) AND (DADO2_DIFF BETWEEN 1 AND 6) AND (DADO3_DIFF BETWEEN 1 AND 6))
);
   
/

/* SPOSTAMENTO: contiene informazioni relative alla terza fase di gioco per lo spostamento eventuale di armate  */
CREATE TABLE SPOSTAMENTO
(
    /* Attributi Chiave */
    ID_TURNO               NUMBER(6) NOT NULL,    -- Riferimento a ID_TURNO nella tabella TURNO
    ID_PARTITA             NUMBER(6) NOT NULL,    -- Riferimento a ID_PARTITA nella tabella TURNO->PARTITA

    /* Attributi */
    ID_TERRITORIO_PARTENZA NUMBER(2) NOT NULL,    -- Riferimento a ID_TERRITORIO nella tabella TERRITORIO
    ID_TERRITORIO_ARRIVO   NUMBER(2) NOT NULL,    -- Riferimento a ID_TERRITORIO nella tabella TERRITORIO
    TRUPPE_SPOSTATE        NUMBER(9) NOT NULL,
    
    /* Vincoli */
    CONSTRAINT PK_Spostamento PRIMARY KEY (ID_PARTITA, ID_TURNO) ENABLE,
    CONSTRAINT FK_Spostamento_Turno FOREIGN KEY (ID_TURNO, ID_PARTITA) REFERENCES TURNO(ID_TURNO, ID_PARTITA) ON DELETE CASCADE ENABLE, -- Default No Action
    CONSTRAINT FK_Terr_Partenza FOREIGN KEY (ID_TERRITORIO_PARTENZA) REFERENCES TERRITORIO(ID_TERRITORIO) ENABLE,     -- Default No Action
    CONSTRAINT FK_Terr_Arrivo FOREIGN KEY (ID_TERRITORIO_ARRIVO) REFERENCES TERRITORIO(ID_TERRITORIO) ENABLE         -- Default No Action
);
  
/

/* CONFINE: contiene informazioni relative ai confini presenti nel gioco */
CREATE TABLE CONFINE
(
    /* Attributi */
    ID_TERRITORIO NUMBER(2) NOT NULL, -- Riferimento a ID_TERRITORIO nella tabella TERRITORIO
    ID_CONFINANTE NUMBER(2) NOT NULL, -- Valore numerico associato ad ogni confine presente
   
    /* Vincoli */
    CONSTRAINT FK_ID_Territorio FOREIGN KEY (ID_TERRITORIO) REFERENCES TERRITORIO (ID_TERRITORIO) ENABLE, -- Default No Action
    CONSTRAINT FK_ID_Confinante FOREIGN KEY (ID_CONFINANTE) REFERENCES TERRITORIO (ID_TERRITORIO) ENABLE  -- Default No Action
);
  
/

/* CARTA TERRITORIO: contiene informazioni relative alle carte territorio presenti nel gioco */
CREATE TABLE CARTA_TERRITORIO
(
    /* Attributi Chiave */
    ID_CARTA      NUMBER(6) NOT NULL,   -- Valore numerico che identifica ogni carta associata a un territorio

    /* Attributi */
    TERRITORIO    VARCHAR2(400) UNIQUE, -- Nome di riferimento al territorio
    SIMBOLO_CARTA CHAR,                 -- Identifica l'attributo associato alla carta: J (Jolly), O (Obiettivo), F (Fanteria), C (Cavalleria), A (Artiglieria)

    /* Vincoli */
    CONSTRAINT PK_Carta_Territorio PRIMARY KEY(ID_CARTA) ENABLE,
    CONSTRAINT CartaType CHECK(SIMBOLO_CARTA IN('J', 'O', 'F', 'C', 'A')) ENABLE
);
  
/

/* ASS CARTA TERRITORIO GIOCATORE: contiene informazioni aggiuntive per la ricerca ottimale di ogni carta associata a un giocatore */
CREATE TABLE ASS_CARTA_TERRITORIO_GIOCATORE
(
    /* Attributi Chiave */
    ID_CARTA   NUMBER(6) NOT NULL, -- Riferimento a ID_CARTA nella tabella CARTA_TERRITORIO
    ID_GAMER   NUMBER(1) NOT NULL, -- Riferimento a ID_GAMER nella tabella GIOCATORE
    ID_PARTITA NUMBER(6) NOT NULL, -- RIFERIMENTO a ID_PARTITA nella tabella GIOCATORE->PARTITA

    /* Vincoli */
    CONSTRAINT PK_Ass_C_Terr_g PRIMARY KEY(ID_CARTA,ID_GAMER,ID_PARTITA) ENABLE,
    CONSTRAINT FK_Ass_Carta FOREIGN KEY (ID_GAMER,ID_PARTITA) REFERENCES GIOCATORE (ID_GAMER,ID_PARTITA) ON DELETE CASCADE ENABLE,
    CONSTRAINT FK_Ass_Gamer FOREIGN KEY (ID_CARTA) REFERENCES CARTA_TERRITORIO (ID_CARTA) ON DELETE CASCADE ENABLE
);
  
/

/* TERRITORIO OCCUPATO: contiene informazioni su i territori occupati dai giocatori di una partita */
CREATE TABLE TERRITORIO_OCCUPATO
(
    /* Attributi Chiave */
    ID_TERRITORIO       NUMBER(2) NOT NULL, -- Riferimento a ID_TERRITORIO nella tabella TERRITORIO
    GIOCATORE_OCCUPANTE NUMBER(1) NOT NULL, -- Giocatore che occupa il territorio
    ID_PARTITA          NUMBER(6) NOT NULL, -- Riferimento a ID_PARTITA nella tabella GIOCATORE->PARTITA

    /* Attributi */
    QUANTITA_TRUPPE     NUMBER(9) DEFAULT 1,

    /* Vincoli */
    CONSTRAINT PK_Giocatore_Territorio PRIMARY KEY (ID_TERRITORIO, GIOCATORE_OCCUPANTE, ID_PARTITA) ENABLE,
    CONSTRAINT FK_PK_Terr FOREIGN KEY(ID_TERRITORIO) REFERENCES TERRITORIO(ID_TERRITORIO) ENABLE,
    CONSTRAINT FK_PK_Giocatore FOREIGN KEY (GIOCATORE_OCCUPANTE, ID_PARTITA) REFERENCES GIOCATORE(ID_GAMER, ID_PARTITA) ON DELETE CASCADE ENABLE
);

/
  
--------------------------  --------------------------  [Definizione Obiettivi]  --------------------------  --------------------------  
  
 /* Dati relativi all'inserimento degli obiettivi all'interno della tabella CARTA_OBIETTIVO */

-- Ogni obiettivo dispone di un valore numerico usato per la verifica del raggiungimento dell'obiettivo stesso
Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (1, 'Conquistare 18 territori, presidiandoli con almeno 2 armate ciascuno');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (2, 'Conquistare 24 territori');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (3, 'Conquistare la totalità del Nord America e dell''Africa');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (4, 'Conquistare la totalità del Nord America e dell''Oceania');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (5, 'Conquistare la totalità dell''Asia e del Sud America');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (6, 'Conquistare la totalità dell''Asia e dell''Africa');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (7, 'Conquistare la totalità dell''Europa, del Sud America e di un terzo continente a scelta');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (8, 'Conquistare la totalità dell''Europa, dell''Oceania e di un terzo continente a scelta');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (9, 'Distruggere Completamente l''Armata NERA, se le armate non sono presenti o sono possedute dal giocatore che ha quest''obiettivo, l''obiettivo diventa conquistare 24 Territori');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (10, 'Distruggere Completamente l''Armata VERDE, se le armate non sono presenti o sono possedute dal giocatore che ha quest''obiettivo, l''obiettivo diventa conquistare 24 Territori');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (11, 'Distruggere Completamente l''Armata ROSSA, se le armate non sono presenti o sono possedute dal giocatore che ha quest''obiettivo, l''obiettivo diventa conquistare 24 Territori');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (12, 'Distruggere Completamente l''Armata GIALLO, se le armate non sono presenti o sono possedute dal giocatore che ha quest''obiettivo, l''obiettivo diventa conquistare 24 Territori');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (13, 'Distruggere Completamente l''Armata BLU, se le armate non sono presenti o sono possedute dal giocatore che ha quest''obiettivo, l''obiettivo diventa conquistare 24 Territori');

Insert into Carta_Obiettivo(ID_Carta, Descrizione)
Values (14, 'Distruggere Completamente l''Armata VIOLA, se le armate non sono presenti o sono possedute dal giocatore che ha quest''obiettivo, l''obiettivo diventa conquistare 24 Territori');


--------------------------  --------------------------  [Definizione Carte Territorio/Simbolo]  --------------------------  --------------------------  

/* Dati relativi all'inserimento delle informazioni sulle carte di tipo terriorio nella tabella CARTA_TERRITORIO */

-- Ogni carta territorio di spone di un valore numerico usato per l'identificazione del territorio stesso
-- Ad ogni carta sono associati valori: A (artiglieria), C (cavalleria), F (fanteria), J  (jolly)	
Insert into Carta_Territorio
values(1, 'Alaska', 'F');

Insert into Carta_Territorio
values(2, 'Territori Del Nord Ovest', 'A');

Insert into Carta_Territorio
values(3, 'Groelandia', 'C');

Insert into Carta_Territorio
values(4, 'Alberta', 'F');

Insert into Carta_Territorio
values(5, 'Ontario', 'C');

Insert into Carta_Territorio
values(6, 'Quebec', 'A');

Insert into Carta_Territorio
values(7, 'Stati Uniti Occidentali', 'F');

Insert into Carta_Territorio
values(8, 'Stati Uniti Orientali', 'A');

Insert into Carta_Territorio
values(9, 'America Centrale', 'C');

Insert into Carta_Territorio
values(10, 'Venezuela', 'A');

Insert into Carta_Territorio
values(11, 'Brasile', 'A');

Insert into Carta_Territorio
values(12, 'Perù', 'C');

Insert into Carta_Territorio
values(13, 'Argentina', 'F');

Insert into Carta_Territorio
values(14, 'Islanda', 'F');

Insert into Carta_Territorio
values(15, 'Scandinavia', 'A');

Insert into Carta_Territorio
values(16, 'Gran Bretagna', 'C');

Insert into Carta_Territorio
values(17, 'Ucraina', 'A');

Insert into Carta_Territorio
values(18, 'Europa Settentrionale', 'C');

Insert into Carta_Territorio
values(19, 'Europa Occidentale', 'F');

Insert into Carta_Territorio
values(20, 'Europa Meridionale', 'C');

Insert into Carta_Territorio
values(21, 'Africa Del Nord', 'F');

Insert into Carta_Territorio
values(22, 'Egitto', 'F');

Insert into Carta_Territorio
values(23, 'Congo', 'C');

Insert into Carta_Territorio
values(24, 'Africa Orientale', 'A');

Insert into Carta_Territorio
values(25, 'Africa Del Sud', 'A');

Insert into Carta_Territorio
values(26, 'Madacascar', 'F');

Insert into Carta_Territorio
values(27, 'Urali', 'C');

Insert into Carta_Territorio
values(28, 'Afghanistan', 'F');

Insert into Carta_Territorio
values(29, 'Medio Oriente', 'A');

Insert into Carta_Territorio
values(30, 'Siberia', 'A');

Insert into Carta_Territorio
values(31, 'Cina', 'C');

Insert into Carta_Territorio
values(32, 'Mongolia', 'A');

Insert into Carta_Territorio
values(33, 'Cìta', 'F');

Insert into Carta_Territorio
values(34, 'Jacuzia', 'C');

Insert into Carta_Territorio
values(35, 'Kamchatka', 'C');

Insert into Carta_Territorio
values(36, 'Giappone', 'F');

Insert into Carta_Territorio
values(37, 'India', 'F');

Insert into Carta_Territorio
values(38, 'Siam', 'A');

Insert into Carta_Territorio
values(39, 'Indonesia', 'C');

Insert into Carta_Territorio
values(40, 'Nuova Guinea', 'C');

Insert into Carta_Territorio
values(41, 'Australia Occidentale', 'A');

Insert into Carta_Territorio
values(42, 'Australia Orientale', 'F');

Insert into Carta_Territorio
values(43, 'Jolly', 'J');

Insert into Carta_Territorio
values(44, 'Jolly2', 'J');

--------------------------  --------------------------  [Definizione Territori]  --------------------------  --------------------------  

/* Dati relativi all'inserimento delle informazioni su ogni singolo terriorio nell'apposito continente */

-- Il valore numerico ID_TERRITORIO identifica univocamente ogni territorio. Medesimo con ID_CONTINENTE
insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(1, 'Alaska', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(2, 'Territori Del Nord Ovest', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(3, 'Groelandia', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(4,'Alberta', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(5, 'Ontario', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(6, 'Quebec', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(7, 'Stati Uniti Occidentali', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(8, 'Stati Uniti Orientali', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(9, 'America Centrale', 1, 'Nord America');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(10, 'Venezuela', 2, 'America del Sud');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(11, 'Brasile', 2, 'America del Sud');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(12, 'Perù', 2, 'America del Sud');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(13, 'Argentina', 2, 'America del Sud');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(14, 'Islanda', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(15, 'Scandinavia', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(16, 'Gran Bretagna', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(17, 'Ucraina', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(18,'Europa Settentrionale', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(19, 'Europa Occidentale', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(20, 'Europa Meridionale', 3, 'Europa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(21, 'Africa Del Nord', 4, 'Africa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(22, 'Egitto', 4, 'Africa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(23, 'Congo', 4, 'Africa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(24, 'Africa Orientale', 4, 'Africa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(25, 'Africa Del Sud', 4, 'Africa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(26, 'Madacascar', 4, 'Africa');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(27, 'Urali', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(28, 'Afghanistan', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(29, 'Medio Oriente', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(30, 'Siberia', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(31, 'Cina', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(32, 'Mongolia', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(33, 'Cìta', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(34, 'Jacuzia' , 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(35, 'Kamchatka', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(36, 'Giappone', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(37, 'India', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(38, 'Siam', 5, 'Asia');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(39, 'Indonesia', 6, 'Oceania');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(40, 'Nuova Guinea', 6, 'Oceania');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(41, 'Australia Occidentale', 6, 'Oceania');

insert into Territorio(ID_TERRITORIO, NOME_TERRITORIO, ID_CONTINENTE, NOME_CONTINENTE)
values(42, 'Australia Orientale', 6, 'Oceania');

--------------------------  --------------------------  [Definizione Confini dei territori]  --------------------------  --------------------------  

/* Dati reltivi all'inserimento delle informazioni sui confini di ogni territorio nella tabella CONFINE */

-- L'associazione dei rispettivi valori numerici possono essere consultati usando la tabella CARTA_TERRITORIO

/* Alaska */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(1, 4);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(1, 2);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(1, 35);

/* Territori Del Nord Ovest */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(2, 1);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(2, 4);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(2, 5);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(2, 3);

/* Greolandia */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(3, 2);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(3, 5);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(3, 14);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(3, 6);

/* Alberta */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(4, 1);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(4, 2);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(4, 5);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(4, 7);

/* Ontario */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(5, 2);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(5, 3);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(5, 4);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(5, 7);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(5, 8);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(5, 6);

/* Quebec */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(6, 5);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(6, 8);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(6, 3);

/* Stati Uniti Occidentali */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(7, 4);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(7, 5);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(7, 8);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(7, 9);

/* Stati Uniti Orientali */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(8, 5);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(8, 6);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(8, 7);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(8, 9);

/* America Centrale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(9, 7);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(9, 8);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(9, 10);

/* Venezuela */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(10, 9);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(10, 11);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(10, 12);

/* Brasile */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(11, 10);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(11, 12);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(11, 13);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(11, 21);

/* Peru' */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(12, 10);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(12, 11);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(12, 13);

/* Argentina */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(13, 11);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(13, 12);

/* Islanda */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(14, 3);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(14, 15);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(14, 16);

/* Scandinavia */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(15, 14);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(15, 16);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(15, 18);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(15, 17);

/* Gran Bretagna */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(16, 14);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(16, 15);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(16, 18);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(16, 19);

/* Ucraina */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(17, 15);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(17, 18);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(17, 20);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(17, 27);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(17, 28);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(17, 29);

/* Europa Settentrionale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(18, 15);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(18, 16);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(18, 19);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(18, 20);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(18, 17);

/* Europa Occidentale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(19, 16);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(19, 18);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(19, 20);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(19, 21);

/* Europa Meridionale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(20, 19);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(20, 18);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(20, 17);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(20, 29);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(20, 21);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(20, 22);

/* Africa Del Nord */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(21, 11);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(21, 19);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(21, 20);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(21, 22);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(21, 23);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(21, 24);

/* Egitto */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(22, 21);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(22, 24);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(22, 29);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(22, 20);

/* Congo */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(23, 21);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(23, 24);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(23, 25);

/* Africa Orientale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(24, 22);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(24, 23);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(24, 25);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(24, 26);

/* Africa Del Sud */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(25, 24);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(25, 23);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(25, 26);

/* Madacascar */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(26, 24);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(26, 25);

/* Urali */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(27, 17);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(27, 28);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(27, 30);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(27, 31);

/* Afghanistan */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(28, 17);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(28, 27);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(28, 31);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(28, 29);

/* Medio Oriente */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(29, 20);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(29, 22);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(29, 17);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(29, 28);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(29, 31);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(29, 37);

/* Siberia */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(30, 27);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(30, 34);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(30, 33);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(30, 32);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(30, 31);

/* Cina */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 32);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 38);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 37);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 29);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 28);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 27);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(31, 30);

/* Mongolia */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(32, 33);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(32, 35);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(32, 36);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(32, 31);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(32, 30);

/* Cìta */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(33, 30);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(33, 34);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(33, 35);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(33, 32);

/* Jacuzia */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(34, 33);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(34, 30);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(34, 35);

/* Kamchatka */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(35, 1);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(35, 36);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(35, 33);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(35, 34);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(35, 32);

/* Giappone */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(36, 35);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(36, 32);

/* India */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(37, 38);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(37, 31);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(37, 29);

/* Siam */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(38, 31);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(38, 37);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(38, 39);

/* indonesia */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(39, 38);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(39, 40);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(39, 41);

/*Nuova Guinea */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(40, 39);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(40, 41);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(40, 42);

/* Australia Occidentale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(41, 39);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(41, 40);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(41, 42);

/* Australia Orientale */
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(42, 40);
Insert into Confine(ID_TERRITORIO,ID_CONFINANTE)
Values(42, 41);

/

--------------------------  --------------------------  [Definizione Base Di Dati]  --------------------------  --------------------------  

/* 
    Tipo: Procedura
    Descrizione: assegna randomicamente l'obiettivo ai giocatori che partecipano alla partita.
    In:  ID_P -> id della partita che si prende in considerazione
    Out: /
    Attivazione: viene chiamata dal trigger INS_TURNO
*/
create or replace PROCEDURE ASSEGNAMENTO_OBIETTIVO(ID_P GIOCATORE.ID_PARTITA%Type)
IS
   CURSOR RND_C_Obiettivo  -- Cursore che si assicura la selezione randomica della carta obiettivo
   IS
    SELECT *
    FROM  (SELECT ID_CARTA FROM CARTA_OBIETTIVO where(ID_Carta between 1 and 14) ORDER BY dbms_random.value);

   /* Dichiarazione variabili */
   Turno_Gamer GIOCATORE.ID_Gamer%Type; 	-- Giocatore che deve ricevere la carta
   N_Gamer NUMBER := 0;						-- Numero dei giocatori presenti in partita
   Id_c_ob CARTA_OBIETTIVO.ID_CARTA%type; 	-- Elemento dove verrà salvata la carta selezionata
   
/* Inizio procedura */
BEGIN
  SELECT G.ID_Gamer INTO Turno_Gamer									-- Seleziona il primo giocatore
  FROM Giocatore G
  WHERE((G.ID_Partita   = ID_P) AND(G.Posizione_Turno = 1));
 
  SELECT COUNT(g.ID_Gamer) INTO N_Gamer									-- Conta i giocatori presenti nella partita
  FROM Giocatore G
  WHERE(G.ID_Partita = ID_P);
  
  /* Apertura del cursore */
  OPEN RND_C_Obiettivo;												 
  
  for i in 1..N_Gamer													-- Inizio Loop per l'assegnamento delle carte obiettivo. Il numero di ripetizioni viene definito da N_Gamer che è il numero di giocatori presenti in tale partita
  loop
   FETCH RND_C_Obiettivo INTO Id_c_ob;
   
   UPDATE Giocatore G													-- Aggiornamento del valore ID_Carta_Obiettivo nella Tabella GIOCATORE, per ogni giocatore appartenente alla partita.
        SET G.ID_CARTA_OBIETTIVO = ID_C_OB
        WHERE((G.ID_PARTITA = ID_P) AND (ID_Gamer = Turno_Gamer));
   
   Turno_Gamer := Turno_Gamer + 1;
    IF(Turno_Gamer > N_Gamer) 											-- Controllo necessario per rimanere nel range 1 a 6 degli ID_GAMER.
    THEN 
      Turno_Gamer := 1;
    END IF;
   
   END LOOP;
END;

/

/* 
    Tipo: Procedura
    Descrizione: controllo dell'unicità del colore e del nick scelto da ogni giocatore.
    In:  ID_P -> id della partita che si prende in considerazione. Nick -> nome scelto dal giocatore. Colore -> colore scelto dal giocatore.
    Out: /
    Attivazione: viene chiamata dal trigger INS_GAMER
*/
create or replace PROCEDURE Check_Color_Nick(ID_P Giocatore.ID_Partita%Type, Nick GIOCATORE.NICKNAME%Type, Colore GIOCATORE.COLORE%Type)
IS
  CURSOR Gamer									-- Cursore per la selezione dei giocatori presenti nella partita
  IS 
    SELECT *
    FROM Giocatore G
    WHERE(G.ID_PARTITa = ID_P);

    /* Dichicarazione variabili */
    GamerRow GIOCATORE%rowType;

    /* Dichiarazione eccezioni */
    err_Duplicate_Color EXCEPTION;
    err_Duplicate_Nick  EXCEPTION;

/* Inizio procedura */
BEGIN
  OPEN Gamer;
  LOOP
    FETCH Gamer INTO GamerRow;					-- Preleva l'intera riga inerente al giocatore da controllare
    EXIT
  WHEN Gamer%notfound;
    IF(GamerRow.Colore = Colore) THEN			-- Controllo sul colore selezionato affinché non sia già stato selezionato da un altro giocatore
      raise err_Duplicate_Color;                -- Catturato e lanciato dal trigger specificato in attivazione
    end if;
    IF(GamerRow.Nickname = Nick) then			-- Controllo sul nick selezionato affinché non sia già stato selezionato da un altro giocatore
      raise err_Duplicate_Nick;                 -- Catturato e lanciato dal trigger specificato in attivazione
    END IF;
  END LOOP;
  CLOSE Gamer;
END;

/

/* 
    Tipo: Procedura
    Descrizione: crea la vista che riassume il numero di territori posseduti da ogni giocatore in relazione al continente di appartenenza.
    In:  ID_P -> id della partita che si prende in considerazione.
    Out: /
    Attivazione: viene chiamata dal trigger INS_TURNO
*/
create or replace PROCEDURE Gamer_Recap_View_Creator(ID_P GIOCATORE.ID_PARTITA%Type)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;                -- Si specifica al compilatore di di eseguire la procedura in una sezione a parte
  view_Code VARCHAR2(500) := '';
BEGIN  											-- Stringa contenente il codice da usare nell'EXECUTE IMMEDIATE
  view_Code :='create or replace view Recap_Gamer_'||ID_P||' as
      Select TC.GIOCATORE_OCCUPANTE, T.ID_Continente, Count(TC.ID_TERRITORIO) as N_Terr  
      from Territorio_occupato TC join Territorio T on TC.ID_Territorio = T.ID_Territorio
      where TC.ID_Partita = '||ID_P||'
      Group by TC.Giocatore_occupante, T.ID_Continente';

EXECUTE IMMEDIATE view_Code; 					-- Esegue la stringa con il codice per creare la vista

END;

/

/* 
    Tipo: Procedura
    Descrizione: stabilisce randomicamente la sequenza di giocatori che si seguirà nel corso della partita. Ogni giocatore viene identificato da un codice 
                 numerico univoco (ad esempio il primo giocatore inserito "Simone" avrà identificativo 1, il secondo "Marco" avrà identificativo 2 e così via).
                 Siccome durante il gioco si stabilisce come impostare il giro che i giocatori devo eseguire, non è detto che il giocatore inserito per primo debba
                 giocare per primo. Si imposta quindi un ordine dei giocatori, dando a questi un ulteriore valore numerico del tutto randomico. Inizierà il giro
                 il giocatore con tale valore più piccolo, e poi seguiranno gli altri.
    In:  ID_P -> id della partita che si prende in considerazione. N_Gamer -> numero dei giocatori presenti in partita.
    Out: /
    Attivazione: viene chiamata dal trigger INS_TURNO
*/
create or replace procedure Ordine_Gamer(ID_P GIOCATORE.ID_PARTITA%Type, N_Gamer number)
IS 

    /* Dichiarazione variabili */
    F_Gamer NUMBER(8);                                          -- Usata per generare un valore casuale per prendere l'identificativo del giocatore di tale valore. 
    pos number := 1;                                            -- Usata per impostare il numero da associare al giocatore 

/* Inizio procvedura */
begin

F_Gamer := dbms_random.value(1,N_Gamer);						-- Seleziona un numero randomico tramite la funzione [dbms_random.value(1,N_Gamer)]. L'intervallo di selezione è tra 1 ed N_Gamer che è il numero di giocatori presenti nella partita
FOR i IN 1..N_GAMER LOOP										-- Inserisce nella colonna POSIZIONE_TURNO di GIOCATORE, il valore numerico che indica la posizione nel turno. Questo avrà un intervallo da 1 a N_Gamer
      UPDATE Giocatore G
        SET Posizione_turno = pos
        WHERE((G.ID_PARTITA = ID_P) AND (ID_Gamer = F_Gamer));
      pos := pos+1;
      F_Gamer := F_Gamer+1;
      if(F_Gamer>N_Gamer) then									-- Controlla che F_Gamer sia nell'intervallo da 1 a N_Gamer. Qualora l'incremento l'abbia fatto uscire da tale intervallo, viene reimpostato ad 1
        F_Gamer := 1;
      end if;
    END LOOP;

end;

/

/* 
    Tipo: Procedura
    Descrizione: Distribuisce i territori ai giocatori. Inoltre, nell'assegnazione inserisce un carro del giocatore selezionato assicurandosi
                 di sottrarlo al complessivo di carri a disposizione per il dispiegamento nella fase iniziale
    In:  ID_P -> id della partita che si prende in considerazione.
    Out: /
    Attivazione: viene chiamata dal trigger INS_TURNO
*/
create or replace PROCEDURE Spiegamento_Armata(ID_P GIOCATORE.ID_PARTITA%Type)
IS
  /* Dichiarazione Variabili */
  Turno_Gamer GIOCATORE.ID_Gamer%Type; 						-- In questa variabile viene memorizzato il giocatore a cui verrà assegnato il territorio
  N_Gamer NUMBER := 0;										-- Numero di giocatori presenti nella partita
  CURSOR RND_C_Terr											-- Cursore che seleziona randomicamente la carta del territorio corrispondente al territorio d'assegnare
  IS
    SELECT *
    FROM
      ( SELECT lower(ct.Territorio) FROM carta_Territorio ct where(ID_Carta between 1 and 42) ORDER BY dbms_random.value )
  WHERE rownum<=44;
  RND_C_T Carta_Territorio.territorio%TYPE;						-- Variabile in viene memorizzato il nome del territorio della carta territorio selezionata randomicamente
  ID_Terr Territorio.ID_Territorio%type;						-- ID del territorio corrispondente alla carta

/* Inizio procedura */
BEGIN
  SELECT G.ID_Gamer
  INTO Turno_Gamer
  FROM Giocatore G
  WHERE((G.ID_Partita   = ID_P)	
  AND(G.Posizione_Turno = 1));									-- Viene selezionato il primo giocatore in accordo all'ordine stabilito dal turno
  
  SELECT COUNT(g.ID_Gamer)
  INTO N_Gamer
  FROM Giocatore G
  WHERE(G.ID_Partita = ID_P);									-- Vengono contati i giocatori presenti nella partita ed inseriti in N_Gamer
	
  Open RND_C_Terr;
  
  Loop															-- Fetch del cursore che punta al territorio selezionato randomicamente in RND_C_T
    Fetch RND_C_Terr into RND_C_T;
    Exit when RND_C_Terr%NOTFound;								-- Il Ciclo viene interrotto quando verranno assegnate tutte le carte territorio
 
    Select T.ID_Territorio INTO ID_Terr 
	From Territorio T 
	where(lower(T.nome_Territorio) = RND_C_T);					-- Preleva l'ID_Territorio corrispondente alla carta territorio
    
    Insert into Territorio_Occupato(ID_Partita, Giocatore_Occupante, ID_Territorio, quantita_truppe)
      values(ID_P, Turno_Gamer, ID_Terr , 1);					-- Viene inserito in TERRITORIO_OCCUPATO, la riga in cui si assegna il territorio al giocatore di cui è il turno e viene messo un carro a presidiare
	  
	UPDATE Giocatore 
    SET n_armate_tot = n_armate_tot - 1
    WHERE ((ID_PARTITA = ID_P) AND (ID_GAMER = Turno_Gamer));  	-- Aggiornamento del numero di carri ancora a disposizione per il dispiegamento da parte del giocatore
	  
    
    Turno_Gamer := Turno_Gamer + 1;
    IF(Turno_Gamer > N_Gamer) then 								-- Viene assicurato che il valore del Turno_Gamer sia nel range dei valori validi
      Turno_Gamer := 1;
    end if;
    
  end loop;
  Close RND_C_Terr;
  
END;

/

/* 
    Tipo: Funzione
    Descrizione: Controlla che il giocatore passato dalla funzione chiamante abbia conquistato l'intero continente [RETURN 1]. Altrimenti [RETURN 0].
    In:  ID_P -> id della partita che si prende in considerazione, ID_G -> id del giocatore, ID_C -> id del continente.
    Out: valore se il contienente è stato conquistato o meno.
    Attivazione: viene chiamata dalla procedura CONTROLLO_OBIETTIVO
*/
create or replace FUNCTION Conquista_Cont(
    ID_G GIOCATORE.ID_GAMER%Type,			-- ID del giocatore
    ID_P PARTITA.ID_PARTITA%type,			-- ID della partita
    ID_C TERRITORIO.ID_CONTINENTE%type		-- ID del continente 
    )
  RETURN NUMBER                             -- 1 -> continenete conquistato, 0 -> continente non conquistato
  
IS
  /* Dichicarazione variabili */
  RG_code     VARCHAR2(700) :='';			-- Stringa in cui viene memorizzato il codice
  ID_C_max   NUMBER     := 0;				-- Numero dei territori che compongono il continente
  ID_C_gamer NUMBER(2)     := 0;  			-- Numero dei territori posseduti dal giocatore del continente ID_C

  t number:=0;
  
BEGIN

SELECT COUNT(*) INTO ID_C_max FROM territorio WHERE id_continente = ID_C;  		-- Viene contato il numero dei territori presenti nel continente

  RG_code   :='select N_TERR          										
from Recap_Gamer_'|| ID_P ||'          
where ID_Continente = '|| ID_C ||' and GIOCATORE_OCCUPANTE = '|| ID_G;			-- Codice per interpellare la vista sul possesso dei territori da parte dei giocatori per la partita ID_P che resistuisce il numero di territori posseduti dal giocatore ID_G, nel continente ID_C

EXECUTE IMMEDIATE RG_code INTO t;												-- Viene memorizzato il valore risultante della query nella variabile t

  if(t = ID_C_max)																-- Controllo sui territori posseduti t dal giocatore ed i territori che compongono il continente
  THEN
    return 1;																	-- Se il controllo è risultato positivo, viene restituito il valore 1
  END IF;
  
return 0;																		-- Altrimenti viene restituito 0
Exception
  when NO_DATA_FOUND then														-- Quest'eccezione viene lanciata se il giocatore non ha nessun territorio del continente ID_C ritornando quindi il valore 0
    Return 0;
END;

/

/* 
    Tipo: Funzione
    Descrizione: Controllo sul conseguimento dell'obiettivo da parte del giocatore in base alla sua carta obiettivo (vale solo per gli obiettivi da 9 a 14).
    In:  ID_P -> id della partita che si prende in considerazione, ID_G -> id del giocatore, C_Da_Elim -> colore che il giocatore deve eliminare scritto nel suo obiettivo, OLD_ID_P -> id del 
         territorio che il giocatore ha conquistato.
    Out: valore indicante se il giocatore ha perseguito l'obiettivo o meno.
    Attivazione: viene chiamata dalla procedura CONTROLLO_OBIETTIVO
*/
create or replace FUNCTION Destroy_army(
    ID_P TERRITORIO_OCCUPATO.ID_PARTITA%Type,								-- ID della partita
    ID_G TERRITORIO_OCCUPATO.GIOCATORE_OCCUPANTE%Type,						-- ID del giocatore
    C_Da_Elim GIOCATORE.COLORE%Type,										-- Colore del giocatore da controllare se ancora in gioco
    OLD_ID_P TERRITORIO_OCCUPATO.GIOCATORE_OCCUPANTE%Type)					-- ID del territorio occupato dal giocatore C_Da_Elim, prima dell'attacco
  RETURN number                                                             -- 0 -> il giocatore non ha conseguito l'obiettivo, 1 -> giocatore ha conseguito l'obiettivo, 2 -> il colore da conquistare appartiene al giocatore stesso, si passa alla verifica dei 24 territori
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  Gamer_K GIOCATORE.ID_GAMER%type;											-- Variabile d'appoggio in cui viene memorizzato l'ID del giocatore che deve esser eliminato assegnato dall'obiettivo 
  N_Terr   NUMBER(2):=0;													-- Numero di territori posseduti dal giocatore da eliminare
  Return_V NUMBER   :=0;													-- Variabile che verrà restituita alla fine della funzione. 

/* Inizio funzione */
BEGIN
  SELECT G.ID_GAMER															-- Viene selezionato l'id_Gamer del giocatore obiettivo
  INTO Gamer_K
  FROM Giocatore G
  WHERE (G.ID_PARTITA = ID_P)
  AND (G.COLORE       = C_DA_ELIM)
  AND (G.ID_Gamer    != ID_G);                                              -- Viene assicurato che sia escluso il giocatore stesso, nel controllo. Se il giocatore è il giocatore obiettivo, allora verrà lanciata un eccezione NO_DATA_FOUND che permetterà di restituire il valore giusto
  
  SELECT COUNT(TC.ID_TERRITORIO)											-- Viene prelevato l'ID_TERRITORIO del territorio occupato dal giocatore dell'obiettivo
  INTO N_Terr
  FROM Territorio_Occupato TC
  WHERE (TC.Giocatore_Occupante = Gamer_K)
  AND (TC.ID_Partita            = ID_P);
  
  IF(N_Terr                     = 0) THEN
    Return_v                   := 2;                                		-- 2 : è il valore che indica che si dovrà controllare l'obiettivo alternativo poichè il colore da eliminare, era si presente in partita, ma è già stato eliminato.
  ELSIF((N_Terr                 = 1) AND (GAMER_K = OLD_ID_P)) THEN 		-- La prima condizione controlla che il giocatore da eliminare sia al suo ultimo territorio e la seconda parte controlla che sia stato eliminato con l'ultimo attacco
    Return_V                   := 1;                                		-- 1 : è il valore che indica la vittoria poichè l'ultimo attacco ha eliminato il giocatore richiesto
  END IF;
RETURN Return_V;
EXCEPTION
WHEN no_data_found THEN
  RETURN 2; 																-- 2 : iL'obiettivo alternativo scatta poichè il colore non è stato scelto da nessun giocatore
END;

/

/* 
    Tipo: Funzione
    Descrizione: controllo sul conseguimento dell'obiettivo di possedere 18 territori con almeno due carri a presidiare.
    In:  ID_P -> id della partita che si prende in considerazione, ID_G -> id del giocatore.
    Out: valore indicante se il giocatore ha perseguito l'obiettivo o meno (1 -> obiettivo conseguito, 0 altrimenti).
    Attivazione: viene chiamata dalla procedura CONTROLLO_OBIETTIVO
*/
create or replace FUNCTION OB_18_Terr(
    ID_P GIOCATORE.ID_PARTITA%type,																-- ID della partita
    ID_G GIOCATORE.ID_GAMER%type)																-- ID del giocatore
  RETURN NUMBER
IS
  /* Dichiarazione variabili */
  return_v NUMBER :=0;																			-- Valore che verrà restituito dalla funzione
  n_Terr   NUMBER := 0;																			-- Numero di territori posseduti dal giocatore

/* Inizio funzione */
BEGIN
  SELECT COUNT(ID_Territorio) INTO n_Terr														-- Conteggio dei territori posseduti dal giocatore con almeno due carri a presidiarlo
  FROM Territorio_Occupato 
  WHERE((ID_Partita = ID_P) AND (GIOCATORE_OCCUPANTE = ID_G) AND (quantita_Truppe > 1));
  
  IF(n_Terr >=18) THEN																			-- Controllo sul conseguimento dell'obiettivo. 
    return_v := 1;																				-- 1 : Il giocatore ha soddisfatto l'obiettivo altrimenti resta 0
  END IF;
  return return_v;                                                                              
END;

/

/* 
    Tipo: Funzione
    Descrizione: controllo sul conseguimento dell'obiettivo di possedere 24 territori.
    In:  ID_P -> id della partita che si prende in considerazione, ID_G -> id del giocatore.
    Out: valore indicante se il giocatore ha perseguito l'obiettivo o meno (1 -> obiettivo conseguito, 0 altrimenti).
    Attivazione: viene chiamata dalla procedura CONTROLLO_OBIETTIVO
*/
create or replace FUNCTION OB_24_Terr(
    ID_P GIOCATORE.ID_PARTITA%type,   							-- ID della partita
    ID_G GIOCATORE.ID_GAMER%type)								-- ID del giocatore
  RETURN NUMBER
IS
  /* Dichiarazione variabili */
  return_v NUMBER :=0;											-- Valore restituito dalla funzione
  n_Terr   NUMBER := 0;											-- Numero dei territori posseduti dal giocatore

/* Inizio funzione */
BEGIN
  SELECT COUNT(ID_Territorio) INTO n_Terr
  FROM Territorio_Occupato
  WHERE(ID_Partita = ID_P) AND (GIOCATORE_OCCUPANTE = ID_G);	-- Conteggio dei territori posseduti dal giocatore
  
  IF(n_Terr >= 24) THEN											-- Controllo sul numero N_Terr
    return_v := 1;												-- 1 : Il giocatore ha soddisfatto l'obiettivo altrimenti resta 0
  END IF;
RETURN return_v;
END;

/

/* 
    Tipo: Procedura
    Descrizione: controllo sul conseguimento dell'obiettivo da parte del giocatore in base alla carta obittivo che è stata assegnata.
    In:  ID_P -> id della partita che si prende in considerazione, ID_G -> id del giocatore, ID_G_DI -> id del giocatore che deve essere eliminato (per gli obiettivi da 9 a 14).
    Out: valore indicante se il giocatore ha perseguito l'obiettivo o meno (1 -> obiettivo conseguito, 0 altrimenti).
    Attivazione: viene chiamata dalla procedura Aggiornamento_Terr_Occ_PA
*/
create or replace PROCEDURE Controllo_Obiettivo(
   ID_P PARTITA.ID_PARTITA%type,										-- ID della partita
   ID_G_OC GIOCATORE.ID_GAMER%type,										-- ID del giocatore
   ID_G_DI GIOCATORE.ID_GAMER%type										-- ID dell'eventuale giocatore da eliminare
    )
IS
  /* Dichiarazione variabili */
  ID_OB GIOCATORE.ID_CARTA_OBIETTIVO%type;								-- ID dell'obiettivo del giocatore
  ID_C1 TERRITORIO.ID_CONTINENTE%type := 0;								-- ID dell'eventuale continente da conquistare
  ID_C2 TERRITORIO.ID_CONTINENTE%type := 0;								-- ID dell'eventuale secondo continente da conquistare
  Check_V NUMBER:= 0;													-- Variabile di controllo
  Other_C NUMBER:= 1;													-- Variabile per il controllo dell'eventuale terzo continente da conquistare

/* Inizio procedura */
BEGIN
  SELECT ID_Carta_obiettivo 											-- Viene preso l'id della carta obiettivo del giocatore che ha effettuato con successo un attacco
    INTO ID_OB
    FROM Giocatore 
    WHERE (ID_PARTITA = ID_P)
    AND (ID_GAMER     = ID_G_OC);
  
   IF(ID_OB     = 1) THEN												-- In base all'ID dell'obiettivo ID_OB del giocatore, viene selezionata la procedura che controlla l'obiettivo
      Check_V   := OB_18_TERR(ID_P,ID_G_OC);							-- Chiamata alla funzione di controllo per l'obiettivo "controllo di 18 territori con almeno 2 carri a presidiarli"
    ELSIF(ID_OB  = 2) THEN
      Check_V   := OB_24_TERR(ID_P,ID_G_OC);							-- Chiamata alla funzione di controllo per l'obiettivo "controllo di 24 territori"
    elsif(ID_OB  = 3) THEN
      ID_C1     := 1;
      ID_C2     := 4;
       Check_V   := Conquista_Cont(ID_G_OC, ID_P, ID_C1);				-- Controllo sul primo continente da conquistare
      IF(Check_V = 1) THEN
         Check_V   := Conquista_Cont(ID_G_OC, ID_P, ID_C2);				-- Controllo effettuato solo se il primo controllo ha avuto successo. In tal caso, viene effettuato sul secondo continente
      END IF;
    elsif( ID_OB = 4) THEN
      ID_C1     := 1;
      ID_C2     := 6;
      Check_V   := Conquista_Cont(ID_G_OC, ID_P, ID_C1);
      IF(Check_V = 1)THEN
        Check_V := Conquista_Cont(ID_G_OC, ID_P, ID_C2);
      END IF;
    elsif( ID_OB = 5) THEN
      ID_C1     := 2;
      ID_C2     := 5;
      Check_V   := Conquista_Cont(ID_G_OC, ID_P, ID_C1);
      IF(Check_V = 1)THEN
        Check_V := Conquista_Cont(ID_G_OC, ID_P, ID_C2);
      END IF;
    elsif(ID_OB  = 6) THEN
      ID_C1     := 4;
      ID_C2     := 5;
      Check_V   := Conquista_Cont(ID_G_OC,ID_P, ID_C1);
      IF(Check_V = 1)THEN
        Check_V := Conquista_Cont(ID_G_OC, ID_P, ID_C2);
      END IF;
    elsif(ID_OB    = 7) THEN												-- Controllo sulla conquista di 3 continenti, con il terzo a libera scelta
      ID_C1       := 2;
      ID_C2       := 3;
      Check_V     := Conquista_Cont(ID_G_OC, ID_P, ID_C1);
      IF(Check_V   = 1)THEN
        Check_V   := Conquista_Cont(ID_G_OC, ID_P, ID_C2);
        IF(Check_V = 1) THEN												-- Il controllo viene eseguito sui continenti rimanenti escludendo i due già controllati
          FOR i IN 1..4
          LOOP
            Check_V   := Conquista_Cont(ID_G_OC,ID_P, Other_C);			
            Other_C   := Other_C + 1;
            IF(Other_C = 2) THEN
              Other_C := Other_C + 2; 
            END IF;
          END LOOP;
        END IF;
      END IF;
    elsif(ID_OB    = 8) THEN
      ID_C1       := 3;
      ID_C2       := 6;
      Check_V     := Conquista_Cont(ID_G_OC, ID_P, ID_C1);
      IF(Check_V   = 1)THEN
        Check_V   := Conquista_Cont(ID_G_OC, ID_P, ID_C2);
        IF(Check_V = 1) THEN
          FOR i IN 1..4
          LOOP
            Check_V   := Conquista_Cont(ID_G_OC, ID_P, Other_C);
            Other_C   := Other_C + 1;
            IF(Other_C = 3) THEN
              Other_C := Other_C + 1;
            END IF;
          END LOOP;
        END IF;
      END IF;
    elsif(ID_OB  = 9) THEN														-- Controllo sugli obiettivi riguardanti l'eliminazione di un altro giocatore
      Check_V   := Destroy_Army(ID_P, ID_G_OC, 'N', ID_G_DI);
      IF(Check_V = 2) THEN														-- Se non è possibile conseguirlo, viene controllato l'obiettivo alternativo di conquista di 24 territori
        Check_V := OB_24_TERR(ID_P,ID_G_OC);
      END IF;
    elsif(ID_OB  = 10)THEN
      Check_V   := Destroy_Army(ID_P, ID_G_OC, 'V', ID_G_DI);
      IF(Check_V = 2) THEN
        Check_V := OB_24_TERR(ID_P,ID_G_OC);
      END IF;
    elsif(ID_OB = 11)THEN
      Check_V   := Destroy_Army(ID_P, ID_G_OC, 'R', ID_G_DI);
      IF(Check_V = 2) THEN
        Check_V := OB_24_TERR(ID_P,ID_G_OC);
      END IF;
    elsif(ID_OB  = 12) THEN
      Check_V   := Destroy_Army(ID_P, ID_G_OC, 'G', ID_G_DI);
      IF(Check_V = 2) THEN
        Check_V := OB_24_TERR(ID_P,ID_G_OC);
      END IF;
    elsif(ID_OB  = 13) THEN
      Check_V   := Destroy_Army(ID_P, ID_G_OC, 'B', ID_G_DI);
      IF(Check_V = 2) THEN
        Check_V := OB_24_TERR(ID_P,ID_G_OC);
      END IF;
    elsif(ID_OB  = 14) THEN
      Check_V   := Destroy_Army(ID_P, ID_G_OC, 'U', ID_G_DI);
      IF(Check_V = 2) THEN
        Check_V := OB_24_TERR(ID_P,ID_G_OC);
      END IF;
    END IF;
  
   IF(Check_V = 1) THEN															-- Controllo sul conseguimento dell'obiettivo ed eventuale aggiornamento del parametro ID_GAMER_VINC della partita
      UPDATE PARTITA
      SET ID_GAMER_VINC = ID_G_OC
      WHERE ID_Partita  = ID_P;
    END IF;
  
END;

/

/* 
    Tipo: Trigger
    Descrizione: verifica che il giocatore inserito abbia tutti i parametri corretti. Si verifica che la partita non sia in corso e che non
                 sia stato raggiunto il numero di giocatori massimo. Se non vengono sollevate eccezzioni si passa alla verifica del nickname
                 e del colore.
    In:  /
    Out: /
    Attivazione: viene chiamato prima di inserire una riga nella tabella GIOCATORE
*/
create or replace TRIGGER Ins_Gamer before
  INSERT ON GIOCATORE FOR EACH row 
  DECLARE 

  /* Dichiarazione bariabili */
  id_p Partita.ID_Partita%type;                                                         -- Id della partita che si prende in considerazione
  id_g GIOCATORE.ID_GAMER%type;                                                         -- Id del giocatore che verrà eventualmente associato al nuovo giocatore inserito
  num_turno TURNO.ID_TURNO%type;                                                        -- Usata per la verifica della partita se è in corso oppure si può aggiungere il giocatore

  /* Dichiarazione eccezioni */
  nex_p               EXCEPTION;                                                        -- Scatta se la partita mon esiste
  err_id_g            EXCEPTION;                                                        -- Scatta se sono già presenti il numero massimo di giocatori nella partita
  err_in_corso        EXCEPTION;                                                        -- Scatta se la partita è in corso
  err_Duplicate_Color EXCEPTION;                                                        -- Scatta se esiste già un giocatore con il colore del giocatore che si vuole inserire
  err_Duplicate_Nick  EXCEPTION;                                                        -- Scatta se esista già un giocatore con lo stesso nickname del giocatore che si vuole inserire

  /* Inizio trigger */
  BEGIN
    SELECT MAX(ID_Partita)                                                              -- Controllo che ci sia almeno una partita in cui inserire i giocatori
    INTO id_p
    FROM partita;
    IF( id_p IS NULL) THEN
      raise nex_p;
    ELSE
      :new.id_partita := id_p;
    END IF;
    																					
    SELECT COUNT(t.ID_TURNO)                                                            -- Controllo che la Partita non sia in corso (se è in corso allora sono presenti delle righe nella tabella TURNO)
    INTO num_turno
    FROM turno t
    WHERE t.ID_PARTITA=id_p;
    
	IF(num_turno      =0) 																-- Se la partita non è già in corso si può aggiungere il giocatore a patto che non si sia raggiunto il numero massimo
      THEN
      SELECT MAX(g.ID_GAMER) INTO id_g FROM giocatore g WHERE g.ID_Partita = id_p;
      IF( (id_g       >= 0) AND (id_g < 6) ) THEN
        :new.ID_Gamer := id_g + 1;
      elsif(ID_g      IS NULL) THEN
        :new.ID_Gamer := 1;
      ELSE
        raise err_id_g;
      END IF;
    ELSE
      raise err_in_corso;
    END IF;
  CHECK_COLOR_NICK(id_p,:new.Nickname,:new.Colore);                                     -- Controllo, trammite apposita proceduta, che il Colore sia valido e che il nick inserito sia UNICO per quella partita.

  /* Gestione eccezioni */
  EXCEPTION
  WHEN nex_p THEN
    Raise_application_error(-20001,'Nessuna partita presente');
  WHEN err_id_g THEN
    Raise_application_error(-20002,'Limite massimo di giocatori superato. Bisogna creare prima una partita!');
  WHEN err_in_corso THEN
    Raise_application_error(-20003,'Partita gia'' in corso. Bisogna creare una nuova partita!' );
  WHEN err_Duplicate_Color THEN
    Raise_application_error(-20004,'Colore gia'' presente');
  WHEN err_Duplicate_Nick THEN
    Raise_application_error(-20005,'Nickname gia'' presente nella partita');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20006,'Ops! Errore generico in: trigger Ins_Gamer');
  END;

/

/* 
    Tipo: Trigger
    Descrizione: cntrollo sui valori inseriti per la nuova partita.
    In:  /
    Out: /
    Attivazione: viene chiamato prima di inserire una riga nella tabella PARTITA
*/
create or replace TRIGGER Ins_Partita
before insert on Partita
for each row
DECLARE

 /* Dichiarazione variabili */
 ID_P partita.ID_partita%type;										-- ID della partita
 
/* Inizio trigger */
Begin
  
  SELECT MAX(ID_PARTITA) INTO ID_P									-- Viene selezionato l'ID della partita più alto
  FROM PARTITA;  
  
  IF(ID_P IS NULL)													-- Controllo sulle partite già presenti nel database
  THEN
    :new.ID_PARTITA := 1;
  ELSE
     :new.ID_PARTITA := ID_P + 1;
  END IF;
  
  :new.Data := to_date(sysdate, 'DD-Mon-YYYY');			            -- Inserisco la data di creazione della partita			
  
  if(:new.Nome_Partita is null) then
    :new.Nome_Partita := :new.ID_Partita||'_'||:New.Data;			-- Se non viene inserito alcun nome da parte dell'utente, viene inserita la data in cui viene creata la partita
  end if;

/* Gestione eccezioni */
EXCEPTION
when others then
    Raise_application_error(-20007,'Ops! Errore genrrico in: trigger Ins_Partita');
end;


/

/* 
    Tipo: Trigger
    Descrizione: Blocco di qualsiasi modifica sui dati delle carte obiettivo. 
                 La scelta è dovuta per una maggiore sicurezza per evitare di modificare
                 parametri di gioco che devono restare invariati, 
                 pena il malfunzionamento del database stesso.
    In:  /
    Out: /
    Attivazione: quando si prova ad aggiornare o cancellare una carta obiettivo.
*/
create or replace trigger Lock_Carta_Obiettivo
before INSERT or UPDATE or DELETE on CARTA_OBIETTIVO
DECLARE

BEGIN

  Raise_application_error(-20008, 'Modifica NON CONSENTITA dei valori predefiniti della tabella CARTA_OBIETTIVO. Questa tabella dovrebbe esser solo referenziata');
  
END;

/

/* 
    Tipo: Trigger
    Descrizione: Blocco di qualsiasi modifica sui dati delle carte territorio. 
                 La scelta è dovuta per una maggiore sicurezza per evitare di modificare
                 parametri di gioco che devono restare invariati, 
                 pena il malfunzionamento del database stesso.
    In:  /
    Out: /
    Attivazione: quando si prova ad aggiornare o cancellare una carta territorio.
*/
create or replace trigger Lock_Carta_Territorio
before INSERT or UPDATE or DELETE on CARTA_TERRITORIO
DECLARE

BEGIN

  Raise_application_error(-20009, 'Modifica NON CONSENTITA dei valori predefiniti della tabella CARTA_TERRITORIO. Questa tabella dovrebbe esser solo referenziata');
  
END;

/

/* 
    Tipo: Trigger
    Descrizione: Blocco di qualsiasi modifica sui dati dei confini dei territori. 
                 La scelta è dovuta per una maggiore sicurezza per evitare di modificare
                 parametri di gioco che devono restare invariati, 
                 pena il malfunzionamento del database stesso.
    In:  /
    Out: /
    Attivazione: quando si prova ad aggiornare o cancellare un confine.
*/
create or replace trigger Lock_CONFINE
before INSERT or UPDATE or DELETE on CONFINE
DECLARE

BEGIN

  Raise_application_error(-20010, 'Modifica NON CONSENTITA dei valori predefiniti della tabella CONFINE. Questa tabella dovrebbe esser solo referenziata');
  
END;

/

/* 
    Tipo: Trigger
    Descrizione: Blocco di qualsiasi modifica sui dati dei territori del tabellone. 
                 La scelta è dovuta per una maggiore sicurezza per evitare di modificare
                 parametri di gioco che devono restare invariati, 
                 pena il malfunzionamento del database stesso.
    In:  /
    Out: /
    Attivazione: quando si prova ad aggiornare o cancellare un territorio.
*/
create or replace trigger LOCK_TERRITORIO
before INSERT or UPDATE or DELETE on TERRITORIO
DECLARE

BEGIN

  Raise_application_error(-20011, 'Modifica NON CONSENTITA dei valori predefiniti della tabella TERRITORIO. Questa tabella dovrebbe esser solo referenziata');
  
END;

/

/* 
    Tipo: Procedura
    Descrizione: assegna le armate disponibili nella fase Preliminare in relazione ai giocatori presenti in partita.
    In:  ID_P -> id della partita. N_Gamer -> numero dei giocatori presenti in partita.
    Out: /
    Attivazione: chiamata dal trigger INS_TURNO.
*/
create or replace PROCEDURE Calcolo_truppe_tot(ID_P GIOCATORE.ID_PARTITA%Type, N_Gamer number)
IS
  /* Dichiarazioen variabili */
  armate_totali number := 0;

/* Inizio procedura */
begin
  
  /* In base al numero dei giocatori vengono impostate le armate totali */
  if(N_Gamer = 3)
  then
    armate_totali := 35;
  end if;

  if(N_Gamer = 4)
  then
    armate_totali := 30;
  end if;
  
  if(N_Gamer = 5)
  then
    armate_totali := 25;
  end if;
  
  if(N_Gamer = 6)
  then
    armate_totali := 20;
  end if;

  FOR i IN 1..N_GAMER LOOP									-- Assegnamento del numero di armate disponibili ad ogni giocatore in partita
      UPDATE Giocatore 
        SET n_armate_tot = armate_totali
        WHERE((ID_PARTITA = ID_P) AND (ID_GAMER = i));
  end loop;


END;  
   
/

/* 
    Tipo: Procedura
    Descrizione: verifica che la partita sia conclusa o ancora in corso.
    In:  ID_P -> id della partita.
    Out: /
    Attivazione: chiamata dal trigger INS_TURNO.
*/
create or replace PROCEDURE CHECK_END_PARTITA(ID_P PARTITA.ID_PARTITA%type)
IS
	 /* Dichiarazione variabili */
	 controllo GIOCATORE.ID_GAMER%type;                                                            -- Usato per inserire all'interno l'id del giocatore vincente (Null se non presente)
     /* Dichiarazione eccezioni */
     err_fine_partita EXCEPTION;                                                                   -- Sollevato nel caso in cui la partita ha un giocatore vincitore
BEGIN
	  
	  SELECT ID_GAMER_VINC INTO controllo                                                          -- Se controllo e' pari a null allora non si sollevano eccezzione dato che la partita e' ancora in corso
	  FROM PARTITA                                                                                 -- Caso opposto significa che e' presente un giocatore vincente e quindi la partita e' considerata finita 
	  WHERE ID_P = ID_PARTITA;
																								  
																								  
	  if(controllo is not null)
	  then
	   raise err_fine_partita;
	  end if;
	  
    /* Gestione eccezioni */
	EXCEPTION
	WHEN no_data_found THEN
	   raise_application_Error(-20012, 'OPS! Non esiste una partita con questo ID_Partita');  	-- Eccezione lanciata se viene fatto l'inserimento di una partita che non e' presente nel database
	WHEN err_fine_partita THEN  
	  raise_application_Error(-20013, 'La partita e'' finita!');								-- Eccezione lanciata se la partita è stata conclusa

END;

/

/* 
    Tipo: Funzione
    Descrizione: controllo sull'eliminazione o meno del giocatore nella partita. 
                 Il controllo viene effettuato verificando il numero di territori che il giocatore
                 dispone nella partita (0 territori = giocatore sconfittao, <> 0 altrimenti).
    In:  ID_P -> id della partita. ID_G -> id del giocatore
    Out: valore numerico: 0 -> giocatore ha perso, si passa al giocatore successivo. 1 -> altrimenti
    Attivazione: chiamata dal trigger INS_TURNO.
*/
create or replace FUNCTION Check_Gamer_in_game(
	ID_P PARTITA.ID_PARTITA%type,						-- ID della partita
	ID_G Giocatore.ID_Gamer%type						-- ID del giocatore da controllare
	)
	RETURN NUMBER
IS

/* Dichiarazioni variabili */
check_diablo number:=0;	                                -- El diablo er senior! Entiende?!								
return_diablo number :=0;
code varchar2(300);

/* Inizio funzione */
begin
    /* Si procede a contare il numero di territori posseduti dal giocatore */ 
	code := 'select count(*) from recap_gamer_'||id_p||' where(Giocatore_Occupante = '||ID_G||')';

	execute immediate code into check_diablo;

	IF(check_diablo != 0)  -- Se != da 0 allora il giocatore ha ancora un territorio
	THEN
	  return_diablo:=1;
	END IF;

	RETURN return_diablo;
END;

/

/* 
    Tipo: Trigger
    Descrizione: imposta i valori delle chiavi di Turno e permette la fase preliminare qualora sia necessario.
                 Maggiori dettagli nel codice stesso.
    In:  /
    Out: /
    Attivazione: chiamato quando si procede ad inserire una riga nella tabella TURNO.
*/
  create or replace TRIGGER Ins_Turno before
  INSERT ON Turno FOR EACH row DECLARE

  /* Dichiarazione variabili */
  N_Gamer NUMBER:=0;													-- Numero di giocatori presenti in partita
  N_Turni   NUMBER:=0;													-- Numero di turni eseguiti nella partita
  prec_g    NUMBER:=0;											    	-- ID del giocatore precedente
  Check_Fine_Turno NUMBER:=0;											-- Variabile di controllo sulla fine del turno [Da eliminare]
  check_Loop number:= 0;												-- Variabile di controllo del ciclo
  id_ga number :=0;														-- ID del giocatore che deve eseguire il turno
  pos_g number :=0;														-- Posizione del giocatore nel turno
  ID_G giocatore.ID_Gamer%type;											-- ID del giocatore precedente
  last_T Turno.ID_Turno%type;											-- Ultimo turno eseguito
  
  /* Inizio trigger */
  BEGIN
    check_end_partita(:new.ID_Partita);
    
    SELECT COUNT(*) INTO N_Gamer
    FROM Giocatore
    WHERE (ID_PARTITA = :new.ID_Partita) ;                                      -- Conto i giocatori presenti nella partita
    
    SELECT COUNT(*)INTO N_Turni
    FROM Turno
    WHERE (ID_PARTITA = :new.ID_Partita); 										-- Conto i turni conclusi + 1
    
    :new.ID_Turno := N_Turni; 													-- Uso N_Turni per assegnare l'ID_Turno al nuovo turno da inserire

    IF(N_Turni > 1) THEN -- N_Turni > 1 : il turno sarà trattato come un turno normale
     
      SELECT MAX(ID_Turno) INTO last_T
      FROM Turno 
      WHERE (ID_Partita = :new.ID_Partita);
    
																				-- Seleziono il giocatore del turno precedente
      SELECT ID_GAMER INTO id_ga
      FROM TURNO
      WHERE ((ID_Partita = :new.ID_Partita) AND (ID_TURNO = last_T));

																				-- Seleziono la posizione del giocatore precedente nel turno
      SELECT POSIZIONE_TURNO INTO pos_g
      FROM GIOCATORE
      WHERE ((ID_Partita = :new.ID_Partita) AND (ID_GAMER = id_ga));
       
      pos_g := pos_g + 1; 														-- Incremento di uno per selezionare il giocatore successivo

      LOOP

      IF(pos_g > N_Gamer) THEN 													-- Viene controllato se non si è andato fuori il range del turno
        pos_g := 1;
      END IF;
 
      SELECT ID_Gamer INTO ID_G
      FROM giocatore
      WHERE ((ID_Partita = :new.ID_Partita) AND (Posizione_Turno = pos_g));
      
      check_loop:=check_gamer_in_game(:new.ID_PARTITA,ID_G);					-- Chiamata al funzione che controlla la presenza del giocatore nella partita
      
      IF(check_loop = 0)														-- viene controllato il giocatore selezionato in base al turno
      THEN
         pos_g := pos_g + 1 ;
      END IF;
      
      
      EXIT WHEN check_loop != 0;												-- Il loop viene interroto solo dopo che aver trovato l'ultimo giocatore che ha eseguito un turno
      END LOOP;
      
      :new.ID_Gamer := ID_G;													-- Selezione del giocatore che deve effettuare il turno
        
    elsif(N_Turni = 1) THEN	-- N_Turni = 1 : il primo turno dopo la fase preliminare quindi non si potrà effettuare nessun controllo sui giocatori che hanno eseguito i turni precedenti poiché non ci sono 
      
      SELECT ID_Gamer INTO ID_G  												-- Seleziona l'ID_Gamer del primo giocatore di turno
      FROM Giocatore
      WHERE ((ID_partita = :new.ID_Partita) AND (Posizione_Turno = 1));
      
      :new.ID_Gamer := ID_G;													-- Assegna Il giocatore al turno
   
    ELSE -- N_Turni = 0 : si sta eseguendo la fase preliminare su cui non vanno eseguiti i controlli, ma verranno eseguite le procedure per lo svolgimento di tale turno
      
      :new.ID_Gamer := 1;
      
     
      Ordine_Gamer(:new.ID_partita, N_Gamer);			-- Stabilisce l'ordine dei giocatori di turno
      ASSEGNAMENTO_OBIETTIVO(:new.ID_Partita);			-- Assegna l'ID_Carta_Obiettivo della carta obiettivo randomicamente ad ogni giocatore presente in partita
      Calcolo_truppe_tot(:new.ID_partita, N_Gamer);		-- Assegna ad ogni giocatore, il numero di armate totali da dispiegare
      SPIEGAMENTO_ARMATA(:new.ID_partita);				-- Assegna ad ogni giocatore i territori ed inserendoci su ognuno, un carro a presidiare
      Gamer_Recap_view_Creator(:new.ID_Partita);		-- Crea la vista che ricapitola il possesso dei territori di ogni giocatore, in relazione al continente
      
      
    END IF;

  END;
/	

/* 
    Tipo: Trigger
    Descrizione: gestisce la prima fase di un turno, ovvero il  numero di armate che il giocatore
                 ottiene in base alle regole del gioco. Queste vengono assegnate ad ogni turno e nel caso
                 in cui si utilizza una combinazione di carte.
    In:  ID_P -> id della partita presa in considerazione. ID_G -> id del giocatore.
    Out: numero di armate massimo che il giocatore può inserire
    Attivazione: chiamato dalla procedura CONTROLLO_CARTE e dal trigger INSERIMENTO_CARRI
*/
create or replace FUNCTION Inserimento_Classico(
    ID_P IN TURNO.ID_PARTITA%type,							-- ID della partita
    ID_G IN TURNO.ID_GAMER%type								-- ID del giocatore
    )			
        return number
IS
  /* Dichiarazione variabili */
  code          VARCHAR2(700);								
  N_Terr_poss   NUMBER:=0;									-- Numero di territori posseduti dal giocatore
  Lim_Carri     NUMBER:=0;									-- Limite di carri che il giocatore può inserire in quel turno
  Bonus         NUMBER:=0;									-- Eventuale bonus sul numero di carri da inserire in quel turno
  N_Carri_ins   NUMBER:=0;									-- Numero di carri finora inseriti nei precedenti inserimenti, in quel turno
  N_Carri_ins_T NUMBER:=0;									-- Numero di carri inseriti
  i number :=0;
  
  /* Dichiarazione eccezioni */
  exc_lim exception;
  
/* Inizio funzione */
BEGIN

  code := 'select sum(N_Terr)                               
from Recap_Gamer_'||ID_P||'          
where (Giocatore_occupante = '||ID_G||')';					-- Codice necessario per interpellare la vista
  EXECUTE immediate code INTO N_Terr_poss;					-- Query alla vista
  Lim_Carri := N_Terr_Poss / 3;								
  Lim_Carri := FLOOR(Lim_Carri);							-- Calcolo del limite di carri inseribili ed approssimazione tramite la funzione FLOOR
 
  FOR i                   IN 1..6							-- Controllo sulla conquista della totalità di uno o più continenti e quindi asssegnazione del bonus
  LOOP
  
    Bonus := CONQUISTA_CONT(ID_G, ID_P, i);					-- La procedura che restituirà 1 SE si ha diritto ad un bonus. 
    IF((Bonus = 1) AND (i = 1) )THEN 						-- Controllo su quale continente fa scattare il bonus
      Lim_Carri := Lim_Carri + 5;
    elsif((Bonus = 1) AND (i = 2)) THEN
      Lim_Carri := Lim_Carri + 2; 
    elsif((Bonus = 1) AND (i = 3)) THEN
      Lim_Carri := Lim_Carri + 5;
    elsif((Bonus = 1) AND (i = 4)) THEN
      Lim_Carri := Lim_Carri + 3;
    elsif((Bonus = 1) AND (i = 5)) THEN
      Lim_Carri := Lim_Carri + 7;
    elsif((Bonus = 1) AND (i = 6)) THEN
      Lim_Carri := Lim_Carri + 2;
    END IF;
  END LOOP;
  
  return Lim_carri;
END;

/

/* 
    Tipo: Trigger
    Descrizione: controllo sui dati inseriti nella tabella COMBATTIMENTO. Maggiore dettagli nel codice stesso.
    In:  /
    Out: /
    Attivazione: chiamato quando viene inserita una riga nella tabella COMBATTIMENTO.
*/
create or replace TRIGGER INS_COMBATTIMENTO BEFORE
  INSERT ON COMBATTIMENTO FOR EACH ROW 
  DECLARE 
  /* Dichiarazione variabili */
  controllo_turno TURNO.ID_TURNO%type;                                                                  -- Usato per inserire il valore del turno corrente (l'ultimo turno)
  ID_G_Attaccante TURNO.ID_GAMER%type;																	-- ID del giocatore che effettua l'attacco
  ID_Terr_Attaccante TURNO.ID_GAMER%type;																-- ID del territorio da dove parte l'attacco
  check_g_terr_att TURNO.ID_GAMER%type;																	-- Variabile di controllo
  controllo_terr_confinante CONFINE.ID_CONFINANTE%type;													-- Variabile di controllo sul confine dei territori
  controllo_id_comb COMBATTIMENTO.ID_COMB%type;															-- Variabile di controllo sull'ID del combattimento
  controllo_truppe TERRITORIO_OCCUPATO.QUANTITA_TRUPPE%type;											-- Variabile di controllo sul numero di truppe
  Check_Pos posizionamento_armata.ID_Posizionamento%type;												-- Variabile di controllo
  ID_G Giocatore.ID_Gamer%type;																			-- ID del giocatore che difende
  Check_P                   NUMBER := 0;                                                                -- Usato per verificare che il giocatore dei territori presei sia lo stesso che è stato inserito

  /* Gestione eccezioni */
  err_controllo_turno       EXCEPTION;                                                                  -- Sollevato se la partita inserita non esiste
  err_id_turno              EXCEPTION;                                                                  -- Sollevato se il turno inserito sia sbagliato
  err_territorio_giocatore  EXCEPTION;                                                                  -- Sollevato se il giocatore non possiede il territorio            
  err_terr_confinante       EXCEPTION;                                                                  -- Sollevato se i territori scelti per l'attacco non confinano
  err_poche_truppe          EXCEPTION;                                                                  -- Sollevato se il territorio d'attacco ha 1 armata 
  err_giocatore_uguale      EXCEPTION;                                                                  --  Sollevato se il giocatore prova ad attaccare se stesso

  /* Inizio trigger */
  BEGIN

    SELECT MAX(ID_TURNO)
    INTO controllo_turno
    FROM TURNO
    WHERE ID_PARTITA    = :new.ID_PARTITA;
    IF(controllo_turno IS NULL) THEN																	-- Viene controllata l'esistenza di un turno e preso l'ID dell'ultimo giocato
      raise err_controllo_turno;
    END IF;
      :new.ID_Turno := Controllo_Turno; 																--Viene assegnata automaticamente l'ID dell'ultimo turno iniziato.
    
																										
    SELECT ID_GAMER                                                                                     -- Seleziona l'id del giocatore dal Turno, così da sapere chi è il GIOCATORE che SVOLGE l'ATTACCO
    INTO ID_G_Attaccante
    FROM TURNO
    WHERE ((ID_PARTITA = :new.ID_PARTITA)
    AND (ID_TURNO      = :new.ID_TURNO));
    
																										
    SELECT GIOCATORE_OCCUPANTE INTO ID_Terr_Attaccante                                                  -- Seleziona il giocatore che si trova in quel territorio di id id_territorio_attacante
    FROM TERRITORIO_OCCUPATO
    WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TERRITORIO = :new.ID_TERRITORIO_ATTACCANTE));
   
    IF(ID_G_Attaccante != ID_Terr_Attaccante)                                                           -- Significa che il giocatore non ha quel territorio
      THEN
      raise err_territorio_giocatore;
    END IF;

																										
    SELECT GIOCATORE_OCCUPANTE                                                                          -- Verifica che i territori presi siano dei giocatori inseriti
    INTO check_p
    FROM TERRITORIO_OCCUPATO
    WHERE ((ID_PARTITA = :new.ID_PARTITA)
    AND (ID_TERRITORIO = :new.ID_Territorio_Attaccato));
    
																										
    IF(ID_G_Attaccante = check_p) THEN                                                                  -- Verifica che il giocatore non attacchi se stesso
      raise err_giocatore_uguale;
    END IF;
    
																										
    SELECT ID_CONFINANTE                                                                                -- Verificache i territori siano confinanti 
    INTO controllo_terr_confinante                                                                      -- Questa select da no data foud o la riga scelta
    FROM CONFINE
    WHERE (((ID_TERRITORIO = :new.ID_TERRITORIO_ATTACCANTE) AND (ID_CONFINANTE    = :new.ID_TERRITORIO_ATTACCATO)) 
    OR ((ID_TERRITORIO = :new.ID_TERRITORIO_ATTACCATO) AND (ID_CONFINANTE    = :new.ID_TERRITORIO_ATTACCANTE))) and (rownum = 1);
    
																										
    SELECT QUANTITA_TRUPPE                                                                              -- Verifica che non ci sia solo un'armata altrimenti non si puo' attaccare
    INTO controllo_truppe
    FROM TERRITORIO_OCCUPATO
    WHERE ((ID_PARTITA  = :new.ID_PARTITA)
    AND (ID_TERRITORIO  = :new.ID_TERRITORIO_ATTACCANTE));
    IF(controllo_truppe = 1) THEN
      raise err_poche_truppe;
    END IF;
    
																										
    SELECT MAX(ID_COMB)                                                                                 -- Inserisce il coretto id_comb
    INTO controllo_id_comb
    FROM COMBATTIMENTO
    WHERE (ID_PARTITA      = :new.ID_PARTITA) and (ID_Turno = Controllo_Turno);
    IF(controllo_id_comb IS NULL) THEN
      :new.ID_COMB       := 1;
    ELSE
      :new.ID_COMB := controllo_id_comb + 1;
    END IF;
  
  /* Gestione eccezioni */
  EXCEPTION
  WHEN err_controllo_turno THEN
    Raise_application_error(-20014, 'Nessuna partita presente!');
  WHEN err_id_turno THEN
    Raise_application_error(-20015, 'Non e'' il tuo turno!');
  WHEN err_territorio_giocatore THEN
    Raise_application_error(-20016, 'Il territorio non e'' il tuo!');
  WHEN NO_DATA_FOUND THEN
    Raise_application_error(-20017, 'I territori non confinano o non sono dei giocatori inseriti');
  WHEN err_poche_truppe THEN
    Raise_application_error(-20018, 'Disponi di una sola armata, non puoi attaccare!');
  WHEN err_giocatore_uguale THEN
    Raise_application_error(-20019, 'Non puoi attaccare te stesso, biricchino!');
  END;
  
  
/

/* 
    Tipo: Procedura
    Descrizione: determina l'esito di un lancio di dadi ed il numero di carri persi dai giocatori coinvolti. In accordo al regolamento.
    In:  DADON_ATT -> valore dei dadi del giocatore attaccante. DADON_DIFF -> valore dei dadi del giocatore che si difende (Il valore dei dadi non lanciati è pari a NULL).
    Out: ritorna il numero esatto di dadi lanciati dal giocatore attaccante. Tale valore viene conservato in quanto nel caso in cui il giocatore attaccante conquista il 
         territorio verranno spostate numero di armate pari al numero dei dadi da lui lanciati.
    Attivazione: chiamata dal trigger INS_LANCIO_DADI.
*/
create or replace PROCEDURE Controllo_Vittoria_Dadi(
    DADO1_ATT  IN OUT LANCIO_DADI.DADO1_ATT%Type,									-- Valore numerico del dado. ATT : Giocatore attaccante DIFF : Giocatore difensore
    DADO2_ATT  IN OUT LANCIO_DADI.DADO1_ATT%Type,
    DADO3_ATT  IN OUT LANCIO_DADI.DADO1_ATT%Type,
    DADO1_DIFF IN OUT LANCIO_DADI.DADO1_ATT%Type,
    DADO2_DIFF IN OUT LANCIO_DADI.DADO1_ATT%Type,
    DADO3_DIFF IN OUT LANCIO_DADI.DADO1_ATT%Type,
    N_DADI_A OUT NUMBER)															-- Numero di dadi lanciati dal giocatore attaccante che determina le armate che avanzano se l'attacco è fruttuoso
IS
  /* Dichiarazione variabili */
  max_dado_att LANCIO_DADI.DADO1_ATT%type;											-- Variabili che rappresentano il dado più alto, quello medio e quello più basso. ATT : Giocatore attaccante DIF : Giocatore difensore
  med_dado_att LANCIO_DADI.DADO1_ATT%type;
  min_dado_att LANCIO_DADI.DADO1_ATT%type;
  max_dado_dif LANCIO_DADI.DADO1_ATT%type;
  med_dado_dif LANCIO_DADI.DADO1_ATT%type;
  min_dado_dif LANCIO_DADI.DADO1_ATT%type;

/* Inizio procedura */
BEGIN																				
  IF((DADO2_ATT IS NULL) AND (DADO3_ATT IS NULL)) -- C'è un solo dado
    THEN
    max_dado_att  := DADO1_ATT;
    N_Dadi_a := 1;
  ELSIF(DADO2_ATT IS NULL) -- Ci sono due dadi (1,3)								In base alla presenza o meno dei valori dei dadi, vengono riordinati i loro valori in modo che siano nelle variabili giuste
    THEN
    IF(DADO1_ATT   >= DADO3_ATT) THEN
      max_dado_att := DADO1_ATT;
      med_dado_att := DADO3_ATT;
      N_Dadi_a := 2;
    ELSE
      max_dado_att := DADO3_ATT;
      med_dado_att := DADO1_ATT;
      N_Dadi_a := 2;
    END IF;
  ELSIF (DADO3_ATT IS NULL) THEN
    IF(DADO1_ATT   >= DADO2_ATT) -- Ci sono due dadi (1,2)
      THEN
      max_dado_att := DADO1_ATT;
      med_dado_att := DADO2_ATT;
      N_Dadi_a := 2;
    ELSE
      max_dado_att := DADO2_ATT;
      med_dado_att := DADO1_ATT;
      N_Dadi_a := 2;
    END IF;
  ELSE -- Tutti e tre i dadi non sono null
    N_Dadi_a := 3;
    IF((DADO1_ATT     >= DADO2_ATT) AND (DADO1_ATT >= DADO3_ATT)) THEN
      max_dado_att   := DADO1_ATT;
      IF(DADO2_ATT    > DADO3_ATT) THEN
        med_dado_att := DADO2_ATT;
        min_dado_att := DADO3_ATT;
      ELSE
        med_dado_att := DADO3_ATT;
        min_dado_att := DADO2_ATT;
      END IF;
    ELSIF((DADO2_ATT  >= DADO1_ATT) AND (DADO2_ATT >= DADO3_ATT)) THEN
      max_dado_att   := DADO2_ATT;
      IF(DADO1_ATT    > DADO3_ATT) THEN
        med_dado_att := DADO1_ATT;
        min_dado_att := DADO3_ATT;
      ELSE
        med_dado_att := DADO3_ATT;
        min_dado_att := DADO1_ATT;
      END IF;
    ELSE
      max_dado_att   := DADO3_ATT;
      IF(DADO1_ATT    > DADO2_ATT) THEN
        med_dado_att := DADO1_ATT;
        min_dado_att := DADO2_ATT;
      ELSE
        med_dado_att := DADO2_ATT;
        min_dado_att := DADO1_ATT;
      END IF;
    END IF;
  END IF;
  --------
  IF((DADO2_DIFF IS NULL) AND (DADO3_DIFF IS NULL)) -- C'è un solo dado
    THEN
    max_dado_dif   := DADO1_DIFF;
  ELSIF(DADO2_DIFF IS NULL) -- Ci sono due dadi (1,3)
    THEN
    IF(DADO1_DIFF  >= DADO3_DIFF) THEN
      max_dado_dif := DADO1_DIFF;
      med_dado_dif := DADO3_DIFF;
    ELSE
      max_dado_dif := DADO3_DIFF;
      med_dado_dif := DADO1_DIFF;
    END IF;
  ELSIF (DADO3_DIFF IS NULL) THEN
    IF(DADO1_DIFF   >= DADO2_DIFF) -- Ci sono due dadi (1,2)
      THEN
      max_dado_dif := DADO1_DIFF;
      med_dado_dif := DADO2_DIFF;
    ELSE
      max_dado_dif := DADO2_DIFF;
      med_dado_dif := DADO1_DIFF;
    END IF;
  ELSE -- Tutti e tre i dadi non sono null
    IF((DADO1_DIFF    >= DADO2_DIFF) AND (DADO1_DIFF >= DADO3_DIFF)) THEN
      max_dado_dif   := DADO1_DIFF;
      IF(DADO2_DIFF   > DADO3_DIFF) THEN
        med_dado_dif := DADO2_DIFF;
        min_dado_dif := DADO3_DIFF;
      ELSE
        med_dado_dif := DADO3_DIFF;
        min_dado_dif := DADO2_DIFF;
      END IF;
    ELSIF((DADO2_DIFF >= DADO1_DIFF) AND (DADO2_DIFF >= DADO3_DIFF)) THEN
      max_dado_dif   := DADO2_DIFF;
      IF(DADO1_DIFF   > DADO3_DIFF) THEN
        med_dado_dif := DADO1_DIFF;
        min_dado_dif := DADO3_DIFF;
      ELSE
        med_dado_dif := DADO3_DIFF;
        min_dado_dif := DADO1_DIFF;
      END IF;
    ELSE
      max_dado_dif   := DADO3_DIFF;
      IF(DADO1_DIFF   > DADO2_DIFF) THEN
        med_dado_dif := DADO1_DIFF;
        min_dado_dif := DADO2_DIFF;
      ELSE
        med_dado_dif := DADO2_DIFF;
        min_dado_dif := DADO1_DIFF;
      END IF;
    END IF;
  END IF;
  
  -- Controllo dei valori MAX MED e MIN    IL VALORE 1 INDICA CHE SI E' PERSO UN CARRO
  
  IF(max_dado_dif >= max_dado_att) THEN
    DADO1_ATT     := 1;
    DADO1_DIFF    := 0;
  ELSE
    DADO1_ATT  := 0;
    DADO1_DIFF := 1;
  END IF;
  IF((med_dado_att  IS NOT NULL) AND (med_dado_dif IS NOT NULL)) THEN
    IF(med_dado_dif >= med_dado_att) THEN
      DADO2_ATT     := 1;
      DADO2_DIFF    := 0;
    ELSE
      DADO2_ATT  := 0;
      DADO2_DIFF := 1;
    END IF;
    IF((min_dado_att  IS NOT NULL) AND (min_dado_dif IS NOT NULL)) THEN
      IF(min_dado_dif >= min_dado_att) THEN
        DADO3_ATT     := 1;
        DADO3_DIFF    := 0;
      ELSE
        DADO3_ATT  := 0;
        DADO3_DIFF := 1;
      END IF;
    ELSE
      DADO3_ATT  := 0;
      DADO3_DIFF := 0;
    END IF;
  ELSE
    DADO2_ATT  := 0;
    DADO2_DIFF := 0;
    DADO3_ATT  := 0;
    DADO3_DIFF := 0;
  END IF;
END;

/

/* 
    Tipo: Procedura
    Descrizione: svolge la funzione di aggiornamento dei dati della tabella TERRITORIO_OCCUPATO dopo un attacco. Aggiornando i dati sui carri che lo occupano e 
                 in caso di conquista, anche del giocatore che possiede il territorio. Inoltre, in tal caso, controlla anche l'avanzamento.
    In:  Dettagli in basso.
    Out: /
    Attivazione: chiamata dal trigger INS_LANCIO_DADI.
*/
create or replace PROCEDURE Aggiornamento_Terr_Occ_PA(
    ID_P PARTITA.ID_PARTITA%type, 																	-- ID della partita
    ID_Terr TERRITORIO.ID_TERRITORIO%type, 															-- ID del territorio attaccante
    ID_Terr_Att TERRITORIO.ID_TERRITORIO%type,														-- ID del territorio attaccato
    ID_G_Att GIOCATORE.ID_GAMER%type,																-- ID del giocatore attaccato
    N_Carri_persi   NUMBER,																			-- Numero di eventuali carri persi dal giocatore attaccante
    N_Carri_persi_att number,																		-- Numero di eventuali carri persi dal giocatore attaccato
    N_dadi_Lanciati NUMBER,																			-- Numero di dadi lanciati dal giocatore attaccante
    ID_T TURNO.ID_TURNO%type, 																		--ID del turno
    ID_Co Combattimento.ID_Comb%type 																--ID del combatimento
    )
IS
  CURSOR Carte_Libere																				-- Cursore che seleziona l'eventuale carta libera da assegnare randomicamente al giocatore che ha vinto il primo scontro
  IS
    SELECT ID_CARTA
    FROM CARTA_TERRITORIO
    WHERE ID_CARTA NOT IN (SELECT ID_CARTA
                          FROM ASS_CARTA_TERRITORIO_GIOCATORE
                          WHERE ID_PARTITA = ID_P);
                          
  /* Dichiarazione bariabili */
  Carta_Libera CARTA_TERRITORIO.ID_CARTA%type;      												                  
  N_Carri_Terr NUMBER :=0; 																			-- Numero carri presenti nel territorio
  N_Carri_Terr_att Number :=0; 																		-- Numero carri presenti nel territorio attaccante
  N_Carri_Att number:=0;                                                                            -- Numero di carri pari al numero di dadi lanciati
  Controllo_primo_turno number := 0;																-- Variabile di controllo
  ID_g_difensore GIOCATORE.ID_GAMER%type;                                                           -- Identificativo del giocatore difensore
  Controllo_terr_diff number := 0;                                                                  -- Usata per la verifica che il territorio attaccato sia l'ultimo del giocatore difensore. Se vero vengono prese tutte le sue carte

/* Inizio procedura */
BEGIN
  
  N_Carri_Att := N_Dadi_Lanciati ;																	-- Il numero dei carri attaccati è uguale ai dadi lanciati nell'effettuare l'attacco stesso
  
  Select quantita_truppe into N_Carri_Terr                                                          -- Prendo il numero di armate del territorio attaccato
  from TERRITORIO_OCCUPATO
  where((ID_Partita = ID_P) and (ID_Territorio = ID_Terr));
  
  N_Carri_Terr := N_Carri_Terr - N_Carri_Persi;                                                     -- Verifico se il combattimento ha portato a una conquista o meno
  
  IF(N_Carri_Terr > 0 ) then																		-- Controllo sull'esito dello scontro
	-- Non c'è stata conquista del territorio. Questo è sia il caso che sia fallito un assalto che è un attacco fallito e quindi con una perdita di carri
    Update Territorio_Occupato
      set Quantita_Truppe = QUANTITA_TRUPPE - N_Carri_persi
      where((ID_Partita = ID_P) and (ID_Territorio = ID_Terr));
      
    Update Territorio_Occupato
      set Quantita_Truppe = QUANTITA_TRUPPE - N_Carri_Persi_att
      where((ID_Partita = ID_P) and (ID_Territorio = ID_Terr_Att));
      
    
      
  elsif(N_Carri_Terr <= 0) then
    -- C'è la conquista del territorio. Questo caso è usato solo per aggiornare i dati del territorio conquistato
    
    OPEN Carte_Libere;
    FETCH Carte_Libere INTO Carta_Libera;
	
    SELECT count(*) INTO controllo_primo_turno														-- Verifico che sia il primo territorio conquistato
    FROM Combattimento
    WHERE((ID_PARTITA = ID_P) AND (ID_TURNO = ID_T) AND (Vincente = 1));
        																							
    IF(controllo_primo_turno = 0) -- il trigger è before quindi mi aspetto che questo sia il primo valore ad avere un 1					-- Controllo se è la prima conquista del turno
    THEN
      INSERT INTO ASS_CARTA_TERRITORIO_GIOCATORE(ID_CARTA,ID_GAMER,ID_PARTITA)
      VALUES (Carta_Libera,ID_G_ATT,ID_P);
    END IF;
    
    Update Combattimento 																			-- Viene segnato 1 nell'apposita colonna della riga in COMBATTIMENTO per segnalare uno scontro vincente
      set VINCENTE = 1
      where(ID_Partita = ID_P) and (ID_Turno = ID_T) and (ID_Comb = ID_Co);
    
    CLOSE Carte_Libere;
    
    
	-- Se il difensore ha perso la partita do tutte le sue carte
    
    -- Prendo l'id del giocatore difensore
    SELECT GIOCATORE_OCCUPANTE INTO ID_g_difensore
    FROM TERRITORIO_OCCUPATO
    WHERE ((ID_PARTITA = ID_P) AND (ID_TERRITORIO = ID_TERR));
    
    -- Conto i territori del difentore per vedere che ha un solo territorio (che è quello conquistato)
    SELECT count(*) INTO Controllo_terr_diff
    FROM TERRITORIO_OCCUPATO
    WHERE ((ID_PARTITA = ID_P) AND (GIOCATORE_OCCUPANTE = ID_g_difensore ));
    
    -- Se è 1 prendo tutte le carte del giocatore difensore e le do al vincitore
    IF(Controllo_terr_diff = 1)
    THEN
      UPDATE ASS_CARTA_TERRITORIO_GIOCATORE
      SET ID_GAMER = ID_G_ATT
      WHERE ((ID_PARTITA = ID_P) AND (ID_GAMER = ID_g_difensore));
    END IF;
    
    --Controllo che rimanga un carro a presidiare il territorio da cui è partito l'attacco
    Select quantita_truppe into N_Carri_Terr_att
    from TERRITORIO_OCCUPATO
    where((ID_Partita = ID_P) and (ID_Territorio = ID_Terr_Att));
        
    if((N_Carri_Terr_Att - N_Carri_Att)<=0) then
      N_Carri_Att := N_Carri_Att - 1;
    end if;
    
    Update Territorio_Occupato  -- Aggiorno i dati del territorio con l'id del giocatore che lo ha conquistato ed gli inserisco il numero di carri pari al numero di dadi lanciati, eventualmente meno uno [Vedi Sopra]
      set Quantita_Truppe = N_Carri_Att,
          Giocatore_Occupante = ID_G_Att
      where((ID_Partita = ID_P) and (ID_Territorio = ID_Terr));
    
    Update Territorio_Occupato
      set Quantita_Truppe = Quantita_Truppe - N_Carri_Att
      where((ID_Partita = ID_P) and (ID_Territorio = ID_Terr_Att));
  end if;
  
    Controllo_obiettivo(ID_P,ID_G_Att,ID_g_difensore); -- verifico che il giocatore abbia raggiunto il proprio obiettivo
  
  
END ;
    

/

/*
    Tipo: Trigger
    Descrizione: Controlla i valori inseriti nella tabella LANCIO_DADI. Maggiori dettagli nel codice stesso.
    In:  /
    Out: /
    Attivazione: chiamato quando si inserisce una riga nella tabella LANCIO_DADI.
*/
create or replace TRIGGER INS_LANCIO_DADI BEFORE
  INSERT ON LANCIO_DADI FOR EACH ROW 
  DECLARE 
  /* Dichiarazioni variabili */
  controllo_id_comb COMBATTIMENTO.ID_COMB%type;                             -- Usata per la verifica della correttezza dell'id del combattimento inserito
  controllo_turno TURNO.ID_TURNO%type;                                      -- Usata per la verifica della correttezza dell'id del turno inserito
  N_L NUMBER:=0;                                                            -- Identifica il numero lancio effettuato (il giocatore può lanciare i dadi più volte in un solo turno)
  ID_G_Attaccante GIOCATORE.ID_GAMER%type;                                  -- Identificativo del giocatore attaccante
  ID_T_Attaccato Combattimento.ID_Territorio_ATTACCATO%type;                -- Identificativo del territorio che è stato attaccato
  ID_T_Attaccante Combattimento.ID_Territorio_Attaccante%type;              -- Identificativo del territorio da cui è stato fatto partire l'attacco
  armate_perse1 GIOCATORE.N_ARMATE_TOT%type;                                -- Numero di armate perse del giocatore attaccante
  armate_perse2 GIOCATORE.N_ARMATE_TOT%type;                                -- Numero di armate perse del giocatore difensore
  
  N_Dadi                     NUMBER := 0;                                   -- Numero di dadi lanciati dal giocatore attaccante (serve nel caso in cui conquisti il territorio)
  Att1                       NUMBER := 0;                                   -- AttN e DiffN vengono assegnati i valori dei dadi che sono presi
  Att2                       NUMBER := 0;                                   
  Att3                       NUMBER := 0;                                   
  Diff1                      NUMBER := 0;                                   
  Diff2                      NUMBER := 0;                                   
  Diff3                      NUMBER := 0;                                   
  ID_G_Difensore number :=0;                                                -- Identificativo del giocatore difensore
  armate_tot number :=0;                                                    -- Usata per prendere il numero di armate totali in un territorio
  
  /* Dichiarazione eccezioni */
  err_controllo_turno        EXCEPTION;                                     -- Sollevata nel caso in cui la partita presa non esiste oppure si è inserito un valore in combattimento errato
  err_nex_comb               EXCEPTION;                                     -- Sollevata se non è stato inserito nessun combattimento

  /* Inizio procedura */
  BEGIN
  --CONTROLLI SULLA CHIAVE DI 4 VARIABILI :
  
    --CONTROLLO ID_TURNO
    SELECT MAX(ID_Turno) --Prendo l'ultimo turno inserito della partita.
    INTO Controllo_Turno
    FROM Turno
    WHERE (ID_PARTITA = :new.ID_PARTITA);
    
    -- SE NON ESISTE ALCUN TURNO, LA PARTITA ANCORA DEVE INZIARE QUINDI LANCIO UN ERRORE
    IF(controllo_turno IS NULL) THEN
      raise err_controllo_turno;
    ELSE
      :new.id_turno := controllo_turno ; --ALTRIMENTI INSERISCO AUTOMATICAMENTE L'ID_TURNO.
    END IF;
    
    -- CONTROLLO ID_COMB
    SELECT MAX(ID_COMB)
    INTO controllo_id_comb
    FROM COMBATTIMENTO
    WHERE (ID_PARTITA = :new.ID_PARTITA) and (ID_Turno = Controllo_Turno) ;
    
    -- Anche se sbagliato viene assegnato l'ultimo id_comb
    if(CONTROLLO_ID_COMB IS NOT NULL) THEN
      :new.ID_COMB := controllo_id_comb ;     -- Assegno a N_Lancio il valore giusto automaticamente [IL MASSIMO GIA' INSERITO + 1]
    ELSE
      RAISE err_nex_comb;                        -- se non c'è nessun combattimento inserito per quel turno e partita, allora lancio un errore.
    end if;
    
    -- CONTROLLO N_LANCIO
    SELECT MAX(N_Lancio)
    INTO N_L
    FROM Lancio_Dadi
    WHERE((ID_Partita = :new.ID_Partita)
    AND (ID_Turno     = :new.ID_Turno)
    AND (ID_Comb      = :new.ID_Comb));
    
    IF(N_L           IS NULL) THEN -- Vuol dire che è il primo che si effettua per quel particolare combattimento
      :new.N_Lancio  := 1;
    ELSE
      :new.N_Lancio := N_L + 1;    -- NON è il primo e quindi incremento di uno.
    END IF;
    
  -- FINE CONTROLLO CHIAVE PRIMARIA DI 4 VARIABILI  
      
    -- Chiamo la funzione per verificare chi ha vinto
    Att1  := :new.DADO1_ATT; -- FACCIO QUESTO TRAVASO POICHE' IN TALI DATI LA FUNZIONE RESTITUISCE 1 SE QUEL DATO E' PERDENTE ALTRIMENTI 0
    Att2  := :new.DADO2_ATT;
    Att3  := :new.DADO3_ATT;
    Diff1 := :new.DADO1_DIFF;
    Diff2 := :new.DADO2_DIFF;
    Diff3 := :new.DADO3_DIFF;
    CONTROLLO_VITTORIA_DADI(Att1,Att2,Att3,Diff1,Diff2,Diff3,N_DADI);
    armate_perse1 := (Att1  + Att2 + Att3);
    armate_perse2 := (Diff1 + Diff2 + Diff3);
   
    -- Aggiorno i dati in Territorio
    SELECT ID_GAMER  INTO ID_G_Attaccante
    FROM TURNO
    WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TURNO = :new.ID_TURNO));
    
    -- Prendo l'id del territorio del giocatore difensore
    SELECT ID_Territorio_Attaccato  into ID_T_Attaccato
    from  Combattimento 
    where(ID_Partita = :new.ID_Partita) and (ID_Turno = Controllo_Turno) and (ID_Comb = controllo_id_comb);
    
    -- Prendo l'id del territorio del giocatore attaccante
    SELECT ID_Territorio_Attaccante into ID_T_Attaccante
    from  Combattimento 
    where(ID_Partita = :new.ID_Partita) and (ID_Turno = Controllo_Turno) and (ID_Comb = controllo_id_comb);
    
    -- Prendo l'id del giocatore difensore
    SELECT GIOCATORE_OCCUPANTE INTO ID_G_Difensore
    FROM TERRITORIO_OCCUPATO
    WHERE ((ID_PARTITA = :new.ID_PARTITA) and (ID_TERRITORIO = ID_T_Attaccato));
    
      
    -- Aggiorno le truppe totali
      SELECT sum(QUANTITA_TRUPPE) into armate_tot
      FROM TERRITORIO_OCCUPATO
      WHERE ((ID_partita = :new.ID_Partita) and (GIOCATORE_OCCUPANTE = ID_G_Attaccante));
      
      UPDATE GIOCATORE
      SET N_ARMATE_TOT = armate_tot - armate_perse1
      WHERE ((ID_partita = :new.ID_Partita) and (ID_GAMER = ID_G_Attaccante));
    
      SELECT sum(QUANTITA_TRUPPE) into armate_tot
      FROM TERRITORIO_OCCUPATO
      WHERE ((ID_partita = :new.ID_Partita) and (GIOCATORE_OCCUPANTE = ID_G_Difensore));
      
      UPDATE GIOCATORE
      SET N_ARMATE_TOT = armate_tot - armate_perse2
      WHERE ((ID_partita = :new.ID_Partita) and (ID_GAMER = ID_G_Difensore));
    
    -- Chiamo la procedura che verifica se il territorio è stato conquistato o meno effettuando opportuni spostamenti. Vengono assegnate eventalmente anche le carte
    AGGIORNAMENTO_TERR_OCC_PA(:new.ID_Partita, ID_T_Attaccato, ID_T_Attaccante, ID_G_Attaccante, armate_perse2, armate_perse1,N_DADI,:new.ID_TURNO, :new.ID_Comb);
  
  /* Gestione eccezioni */
  EXCEPTION
  WHEN err_controllo_turno THEN
    Raise_application_error(-20020, 'Nessuna partita presente o devi inserire prima in combattimento!');
  WHEN err_nex_comb THEN
    Raise_application_error(-20021, 'Non è stato inserito alcun combattimento');
  WHEN OTHERS THEN
  Raise_application_error(-20022, 'Ops! Errore generico nel trigger: INS_LANCIO_DADI');

  END;

/

/*
    Tipo: Trigger
    Descrizione: controlla i dati inseriti nella tabella SPOSTAMENTO. Maggiori dettagli nel codice.
    In:  /
    Out: /
    Attivazione: chiamato quando si inserisce una riga nella tabella SPOSTAMENTO.
*/
create or replace TRIGGER INS_SPOSTAMENTO
BEFORE INSERT ON SPOSTAMENTO
FOR EACH ROW
DECLARE

 /* Dichiarazione variabili */
 controllo_turno TURNO.ID_TURNO%type;														-- Variabile di controllo per la verifica dell'esistenza della partita 
 controllo_gamer TURNO.ID_GAMER%type;														-- Variabile di controllo per prelevare l'id del giocatore dell'ultimo turno
 controllo_gamer_territorio TURNO.ID_GAMER%type;											-- Variabile di controllo per verificare che il giocatore abbia il territorio che è stato inserito
 controllo_terr_confinante CONFINE.ID_CONFINANTE%type;										-- Variabile di controllo per verificare che i territori epr lo spostamento siano confinanti
 controllo_truppe TERRITORIO_OCCUPATO.QUANTITA_TRUPPE%type;									-- Variabile di controllo per verificare che il numero di armate non lasci il territorio senza CarriAgg
 
 /* Dichiarazione eccezioni */
 err_controllo_turno EXCEPTION;                                                             -- Sollevata nel caso in cui non esiste il turno specificato e quindi la partita
 err_territorio_giocatore EXCEPTION;                                                        -- Sollevata nel caso in cui i territori non confinano
 err_controllo_truppe EXCEPTION;                                                            -- Sollevata nel caso in cui lo spostamento porta a lasciare indifeso il territorio d'attacco
  
/* Inizio trigger */
BEGIN
  -- Controllo turno e partita
  SELECT max(ID_TURNO) INTO controllo_turno
  FROM TURNO
  WHERE ID_PARTITA = :new.ID_PARTITA;
  
  IF(controllo_turno IS NULL)
  THEN
    raise err_controllo_turno;
  END IF;
  
  :new.ID_Turno := controllo_turno;                                                         -- Viene assegnato l'ID del turno dal controllo sostituendo eventuali dati inseriti manualmente

  -- Seleziono l'id del giocatore del turno
  SELECT ID_GAMER INTO controllo_gamer
  FROM TURNO
  WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TURNO = :new.ID_TURNO));

  -- Controllo che i territori appartengono allo stesso giocatore
  SELECT GIOCATORE_OCCUPANTE INTO controllo_gamer_territorio
  FROM TERRITORIO_OCCUPATO
  WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TERRITORIO = :new.ID_TERRITORIO_PARTENZA));

  IF(controllo_gamer != controllo_gamer_territorio) --  il giocatore non ha quel territorio
  THEN
    raise err_territorio_giocatore;
  END IF;

  SELECT GIOCATORE_OCCUPANTE INTO controllo_gamer_territorio
  FROM TERRITORIO_OCCUPATO
  WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TERRITORIO = :new.ID_TERRITORIO_ARRIVO));

  IF(controllo_gamer != controllo_gamer_territorio) -- il giocatore non ha quel territorio
  THEN
    raise err_territorio_giocatore;
  END IF;
  
  -- Verifico che i territori siano confinanti
  -- Questa select da no data foud o la riga scelta
  SELECT  ID_CONFINANTE INTO controllo_terr_confinante
  FROM CONFINE
  WHERE ((ID_TERRITORIO = :new.ID_TERRITORIO_PARTENZA) AND (ID_CONFINANTE = :new.ID_TERRITORIO_ARRIVO));
  
  
  -- Verifico che lo spostamento non lasci il territorio di partenza senza carri
  SELECT QUANTITA_TRUPPE INTO controllo_truppe
  FROM TERRITORIO_OCCUPATO
  WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TERRITORIO = :new.ID_TERRITORIO_PARTENZA));
  
  controllo_truppe := (controllo_truppe - :new.TRUPPE_SPOSTATE);
  
  IF(controllo_truppe <= 0) 
  THEN
    raise err_controllo_truppe;
  END IF;
  
  -- Effettuo lo spostamento
    UPDATE TERRITORIO_OCCUPATO
    SET QUANTITA_TRUPPE = (QUANTITA_TRUPPE + :new.TRUPPE_SPOSTATE)
    WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TERRITORIO = :new.ID_TERRITORIO_ARRIVO));
    
  -- Aggiorno le truppe del territorio di partenza
    UPDATE TERRITORIO_OCCUPATO
    SET QUANTITA_TRUPPE = (QUANTITA_TRUPPE - :new.TRUPPE_SPOSTATE)
    WHERE ((ID_PARTITA = :new.ID_PARTITA) AND (ID_TERRITORIO = :new.ID_TERRITORIO_PARTENZA));
  
/* Gestione eccezioni */
EXCEPTION
  WHEN err_controllo_turno THEN
   Raise_application_error(-20023, 'Nessuna partita presente!');
  WHEN err_territorio_giocatore THEN
   Raise_application_error(-20024, 'Uno dei territori non ti appartiene!');
  WHEN NO_DATA_FOUND THEN
   Raise_application_error(-20025, 'I territori non confinano');
  WHEN err_controllo_truppe THEN
   Raise_application_error(-20026, 'Non puoi spostare tutte queste trueppe, lasceresti il territorio di partenza non presidiato!');
  WHEN OTHERS THEN
  Raise_application_error(-20027, 'Ops! Errore generico nel trigger: ISN_SPOSTAMENTO');
END;

/

/*
    Tipo: Procedura
    Descrizione: Verifica in base alla combinazione di carte data in ingresso, se i giocatore dispone di tale 
                 combinazione. La ricerca viene effettuata ogni carta alla volta cercando di prendere l'id della carta
                 che fa parte delle combinazione e che il territorio ad esso associato appartenga al giocatore.
    In:  /
    Out: /
    Attivazione: chiamato dalla funzione COMBINAZIONE.
*/
create or replace PROCEDURE Controllo_carte(
    ID_P IN TURNO.ID_PARTITA%type,  -- ID della partita a cui si fa riferimento
    ID_G IN TURNO.ID_GAMER%type,    -- ID del giocatore a cui si fa riferimento
    Simbolo1  IN  CHAR,             -- SimboloN contiene la combinazione di carte che deve essere verificata
    Simbolo2  IN  CHAR,
    Simbolo3  IN  CHAR,
    IDcarta1  OUT NUMBER,        	-- Ritornando nella funzione chiamante se uno di questi tre id carta è zero allora il giocatore non ha tutte le carte con i simboli scelti
    IDcarta2  OUT NUMBER,        	
    IDcarta3  OUT NUMBER,  			
    CarriAgg  IN OUT NUMBER         -- Numero di carri massimi ottenuti dalla combinazione + il turno classico
    )
    
IS

/* Dichiarazione variabili */
Check_carte  NUMBER :=0;            -- Usata per verificare che il giocatore abbia almeno 3 carte
Simbolo CHAR:='X';                  -- Usata per prendere il simbolo delle carte che ha in mano il giocatore
IDcarta NUMBER := 0;                -- Usata per prendere l'id della carta selezionata
Gocc NUMBER :=0;                    -- Usata per verificare che il giocatore possieda anche il territorio della carta scelta
CartaNoTerr NUMBER := 0;            -- Usata per conservare l'id della carta a cui il il giocatore non è associato il territorio
CarriTurno NUMBER :=0;              -- Usata per mantenere il numero di carri massimi che si possono inserire

CURSOR curidcarta                   -- Seleziona le carte che il giocatore ha in mano
IS
  SELECT ID_CARTA
  FROM ASS_CARTA_TERRITORIO_GIOCATORE
  WHERE ((ID_PARTITA = ID_P) AND (ID_GAMER = ID_G));

/* Inizio procedura */
BEGIN
  IDcarta1 := 0;                   -- Conterrano gli id delle carte da conservare per poi, se c'è una combinazione, eliminarle
  IDcarta2 := 0;                   
  IDcarta3 := 0;                   
  
  -- Conto le carte del giocatore
  SELECT COUNT(*) INTO Check_carte
  FROM ASS_CARTA_TERRITORIO_GIOCATORE
  WHERE ((ID_PARTITA = ID_P) AND (ID_GAMER = ID_G));
 
   IF(Check_carte >= 3) 												-- Il giocatore ha almeno 3 carte
  THEN
    OPEN curidcarta;
    LOOP
    FETCH curidcarta INTO IDcarta;
    EXIT WHEN curidcarta%NOTFOUND;
    
    SELECT SIMBOLO_CARTA INTO Simbolo
    FROM CARTA_TERRITORIO
    WHERE ID_CARTA = IDcarta;
    
    IF(Simbolo1 = Simbolo) 												-- Controllo del possesso di una carta territorio da parte del giocatore in cui il territorio raffigurato è di suo possesso. Questo gli da accesso ad un bonus di +2 carri sul valore totale della combinazione
    THEN
     
       IF(Simbolo != 'J')
       THEN
			-- Controllo sul possesso del territorio
            SELECT GIOCATORE_OCCUPANTE INTO Gocc
            FROM TERRITORIO_OCCUPATO
            WHERE ((ID_PARTITA = ID_P) AND (ID_TERRITORIO = IDcarta));
            
              IF(Gocc = ID_G) 											-- Controllo sul possesso del territorio, se positivo verrà aggiunto il bonus
              THEN
                IDcarta1 := IDcarta; 									-- Viene salvato l'ID della carta in modo da eliminarla dalle carte possedute dal giocatore una volta inserita la combinazione
                CarriAgg := CarriAgg + 2; 								-- Aggiorno i carri della combinazione
                EXIT; 
              ELSE
                CartaNoTerr := IDcarta; -- Altrimenti viene salvata in questa variabile, se non posseduto il territorio
              END IF;
      ELSE
       IDcarta1 := IDcarta;
      END IF;
   END IF;
  END LOOP;
  CLOSE curidcarta;
 
  -- Viene selezionata la carta che da accesso il bonus se presente, altrimenti viene presa una carta col simbolo necessario
  -- Nel caso in cui il giocatore non possiede alcuna carta col quel simbolo, entrambi valori rimarranno NULL

  IF(IDcarta1 != 0 OR CartaNoTerr != 0) 								-- Nel caso in cui sono entrambi zero, il giocatore non ha la carta per la combinazione e viene annullata l'operazione
  THEN
    IF(IDcarta1 = 0)  
    THEN
      IDcarta1 := CartaNoTerr;  										-- Il giocatore ha quella carta ma non il territorio, allora la carta si trova in carta no terr
    END IF; 															-- Altrimenti sono già state selezionate sia la carta che l'eventuale bonus

    CartaNoTerr := 0;
  -- Stesso procedimento per le altre due carte
    OPEN curidcarta;
    LOOP
    FETCH curidcarta INTO IDcarta;
    EXIT WHEN curidcarta%NOTFOUND;
    
    SELECT SIMBOLO_CARTA INTO Simbolo
    FROM CARTA_TERRITORIO
    WHERE ID_CARTA = IDcarta;
    
     IF(Simbolo2 = Simbolo) 											-- Controllo sul possesso di più carte e non la ripetizione del controllo sulla precedenter carta
     THEN
        IF(IDcarta != IDcarta1)-- Ho una nuova carta su cui valutare se il giocatore ha il territorio
        THEN
        IF(Simbolo != 'J')
        THEN
            -- Controllo sul possesso del territorio
           SELECT GIOCATORE_OCCUPANTE INTO Gocc
           FROM TERRITORIO_OCCUPATO
           WHERE ((ID_PARTITA = ID_P) AND (ID_TERRITORIO = IDcarta));
          
              IF(Gocc = ID_G) -- Il giocatore possiede il territorio
              THEN
                IDcarta2 := IDcarta; -- Viene salvato l'ID della carta. Verrà eliminata al termine dell'inserimento del bonus
                CarriAgg := CarriAgg + 2; -- Viene aggiornato il complessivo del bonus
                EXIT;
               ELSE
                CartaNoTerr := IDcarta; -- Viene inserito l'ID del giocatore se non possiede quel territorio
               END IF;
        ELSE 
           IDcarta2 := IDcarta; 
        END IF;
        END IF; -- Se non si è entrato nell'if vuol dire che le due carte erano uguali e quindi si scorrono le altre eventuali carte
    
     END IF; -- Se non si è entrato nell'if, vuol dire che i simboli erano diversi e quindi si deve continuare a scorrere le carte
  
    END LOOP;
    CLOSE curidcarta;
    
    IF(IDcarta2 != 0 OR CartaNoTerr != 0) 								-- Controllo sul possesso delle carte necessarie per applicare una combinazione. Se entrambi 0, non sarà possibile applicarla
    THEN
      IF(IDcarta2 = 0)  
      THEN
        IDcarta2 := CartaNoTerr;  -- Il giocatore ha quella carta ma non il territorio, allora la carta si trova in carta no terr
      END IF; -- Se non si entra nell'if si è già memorizzato l'ID della carta
      
       CartaNoTerr := 0;
																		-- Si procede a controllare se si ha la terza carta
        OPEN curidcarta;
        LOOP
        FETCH curidcarta INTO IDcarta;
        EXIT WHEN curidcarta%NOTFOUND;

         SELECT SIMBOLO_CARTA INTO Simbolo
         FROM CARTA_TERRITORIO
         WHERE ID_CARTA = IDcarta;
         
          IF(Simbolo3 = Simbolo) -- il giocatore possiede anche la terza carta, si procede controllando che non sia la stessa che si è controllato come prima carta
          THEN
             IF(IDcarta != IDcarta1 AND IDcarta != IDcarta2) -- In tal caso, si ha una nuova carta da controllare
              THEN
              IF(Simbolo != 'J')
              THEN
																		-- Si controlla se il giocatore ha quel territorio
               SELECT GIOCATORE_OCCUPANTE INTO Gocc
               FROM TERRITORIO_OCCUPATO
               WHERE ((ID_PARTITA = ID_P) AND (ID_TERRITORIO = IDcarta));
        
              IF(Gocc = ID_G) 										-- Il giocatore possiede quel territorio
              THEN
                IDcarta3 := IDcarta; 								-- Viene salvato l'ID della carta. Verrà eliminata al termine dell'inserimento del bonus
                CarriAgg := CarriAgg + 2; -- Aggiorno i carri che deve avere il giocatore dalla combinazione
                EXIT; -- Esco perchè ho trovato la carta migliore
              ELSE
                CartaNoTerr := IDcarta; -- Se il giocatore non ha quel territorio metto l'id qui dentro
               END IF;
            ELSE -- Significa che la carta trovata è il jolly che non ha territori assegnati
              IDcarta3 := IDcarta;
              EXIT;
            END IF;
           END IF; -- else significa che id carta = id carta 1 oppure al id carta 2 non devo fare niente e continuare a scorrere le carte
    
         END IF; -- else significa che i simboli delle carte non sono uguali, continuo a scorrere
 
       END LOOP;
      CLOSE curidcarta;
      
   IF(IDcarta3 != 0 OR CartaNoTerr != 0) -- Se sono entrambi zero allora il giocatore non ha la carta per la combinazione e non si fa niente
   THEN
     IF(IDcarta3 = 0)  
      THEN
        IDcarta3 := CartaNoTerr;  -- Il giocatore ha quella carta ma non il territorio, allora la carta si trova in carta no terr
      END IF; -- altrimenti già tenfo in id carta l'id della carta
   END IF; 
      
    END IF; -- if secondo controllo id ca carta no terr
  END IF; -- if controllo carte id ca carta no terr

   -- Prendo anche le armate in base ai territori
   CarriTurno := Inserimento_classico(ID_P, ID_G); 
   
   CarriAgg := CarriAgg + CarriTurno;     
              
  END IF; -- If delle carte >= 3
END;


/

/*
    Tipo: Funzione
    Descrizione: Controlla l'inserimento di eventuali combinazioni.
    In:  ID_P -> id della partita, ID_G -> id del giocatore, ID_COMB -> valore numerico della combinazione scelta.
    Out: /
    Attivazione: chiamata dal trigger INSERIMENTO_CARRI
*/
create or replace FUNCTION Combinazione(
    ID_P IN TURNO.ID_PARTITA%type,												-- ID della partita
    ID_G IN TURNO.ID_GAMER%type,												-- ID del giocatore
    ID_COMB POSIZIONAMENTO_ARMATA.TIPO_POSIZIONAMENTO%type						-- ID della combinazione (valore numerico da 2 a 8)
    )
        return number                                                           -- Ritorna il numero di armate massimo che il giocatore può inserire
        
IS
/* Dichiarazione variabili */
Lim_Carri NUMBER:=0;															-- Limite di carri inseribili con la combinazione														
CarriTemp NUMBER := 0;															-- Carri temporanei ottenuti dalla gunzione Controllo_carte, si sommano a Lim_carri
IDcarta1 NUMBER := 0;															-- ID delle carte usate per la combinazione
IDcarta2 NUMBER := 0;
IDcarta3 NUMBER := 0;
/* Dichiarazione eccezioni */
err_no_comb EXCEPTION;                                                          -- Sollevata nel caso in cui il giocatore non dispone della combinazione da lui scelta

/* Inizio funzione */
BEGIN
  -- Controllo sulla combinazione 
  -- CCC
  IF(ID_COMB = 2) 
  THEN
    Lim_Carri := 4;
    Controllo_carte(ID_P,ID_G,'C','C','C',IDcarta1,IDcarta2,IDcarta3,CarriTemp); -- In base all'ID_Comb vengono passati determinati valori in accordo alle combinazioni ammesse dal regolamento
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  -- FFF
  IF(ID_COMB = 3)
  THEN
    Lim_Carri := 6;
    Controllo_carte(ID_P,ID_G,'F','F','F',IDcarta1,IDcarta2,IDcarta3,CarriTemp);
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  -- AAA
  IF(ID_COMB = 4)
  THEN
    Lim_Carri := 8;
    Controllo_carte(ID_P,ID_G,'A','A','A',IDcarta1,IDcarta2,IDcarta3,CarriTemp);
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  -- FCA
  IF(ID_COMB = 5)
  THEN
    Lim_Carri := 10;
    Controllo_carte(ID_P,ID_G,'F','C','A',IDcarta1,IDcarta2,IDcarta3,CarriTemp);
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  -- JCC
  IF(ID_COMB = 6)
  THEN
    Lim_Carri := 12;
    Controllo_carte(ID_P,ID_G,'J','C','C',IDcarta1,IDcarta2,IDcarta3,CarriTemp);
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  -- JFF
  IF(ID_COMB = 7)
  THEN
    Lim_Carri := 12;
    Controllo_carte(ID_P,ID_G,'J','F','F',IDcarta1,IDcarta2,IDcarta3,CarriTemp);
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  -- JAA
  IF(ID_COMB = 8)
  THEN
    Lim_Carri := 12;
    Controllo_carte(ID_P,ID_G,'J','A','A',IDcarta1,IDcarta2,IDcarta3,CarriTemp);
    Lim_Carri := Lim_carri + CarriTemp;
  END IF;
  
  IF(IDcarta1 != 0 AND IDcarta2 != 0 AND IDcarta3 != 0)     -- Se un id carta è zero allora il giocatore non possiede la combinazione
  THEN
	-- Eliminazione delle carte usate per invocare la combinazione
    DELETE FROM ASS_CARTA_TERRITORIO_GIOCATORE
    WHERE ((ID_PARTITA = ID_P) AND (ID_CARTA = IDcarta1));
    
    DELETE FROM ASS_CARTA_TERRITORIO_GIOCATORE
    WHERE ((ID_PARTITA = ID_P) AND (ID_CARTA = IDcarta2));
    
    DELETE FROM ASS_CARTA_TERRITORIO_GIOCATORE
    WHERE ((ID_PARTITA = ID_P) AND (ID_CARTA = IDcarta3));
    
  ELSE
    Lim_carri := 0;
  END IF;
 
  return Lim_carri;
  
  
  EXCEPTION
  WHEN err_no_comb THEN
    Raise_application_error(-20028, 'Non hai le carte per poter usare questa combinazione!');
  WHEN OTHERS THEN
   Raise_application_error(-20029, 'Ops! Errore generico nella funzione: COMBINAZIONE');
END;

/

/*
    Tipo: Trigger
    Descrizione: Effettua gli aggionamenti sulla tabella Territorio_Occupato inerenti all'avanzamento dei carri dopo un attacco, in accordo alla decisione del giocatore.
    In:  /
    Out: /
    Attivazione: chiamato quando si procede ad un update dell'attributo Tipo_avanzamento nella tabella COMBATTIMENTO.
*/
CREATE OR REPLACE TRIGGER Avanzamento_Combattimento AFTER
  UPDATE OF Tipo_Avanzamento ON Combattimento 
  FOR EACH ROW 
  WHEN( new.Tipo_Avanzamento = 2) 
  DECLARE 
  /* Dichiarazioe variabili */
  N_armate number:=0;           -- Numero di armate che dovranno essere spostare eccetto 1

  /* Inizio trigger */
  BEGIN
    
    SELECT Quantita_truppe
    INTO N_Armate
    FROM Territorio_Occupato
    WHERE((ID_Partita  = :new.ID_Partita)
    AND (ID_Territorio = :new.ID_Territorio_Attaccante)); 					-- Controllo sui valori dell'ID_Gamer e sul possesso di questo territorio e della validità complessiva dei dati inseriti in Combattimento e Lancio_Dadi, viene valutata al momento dell'inserimento dei dadi nelle rispettive tabelle.
    
    N_Armate          := N_Armate - 1; -- Un'armata deve rimanere SEMPRE a presidiare il territorio
    
    
    IF(N_Armate        > 0) THEN											-- Aggiornamento dei valori dei carri presenti nel territorio Attaccante e del territorio conquistato in accordo alla scelta del giocatore
      UPDATE Territorio_Occupato
      SET quantita_truppe = quantita_truppe + N_Armate
      WHERE (ID_Partita   = :new.ID_Partita)
      AND (ID_Territorio  = :new.ID_Territorio_Attaccato);
      UPDATE Territorio_Occupato
      SET quantita_Truppe = quantita_Truppe - N_Armate
      WHERE (ID_Partita   = :new.ID_Partita)
      AND (ID_Territorio  = :new.ID_Territorio_Attaccante);
    END IF;
  END;
  
/

/*
    Tipo: Trigger
    Descrizione: Controllo sulle righe inserite nella tabella INSERIMENTO_CARRI.
    In:  /
    Out: /
    Attivazione: chiamato quando si procede all'inserimento di una riga in POSIZIONAMENTO_ARMATA.
*/
create or replace TRIGGER Inserimento_Carri
before insert on Posizionamento_armata
for each row
DECLARE

/* Dichiarazione variabili */
Last_T TURNO.ID_TURNO%type;                         -- Valore del turno corrente (l'ultimo turno)
ID_Pos number:=0;                                   -- Valore numerico indicante il numero di posizionamenti fatti (il giocatore può effettuare più posizionamenti nello stesso turno)
terr_temp Territorio_Occupato.ID_Territorio%type;   -- Conserva il valore dle territorio del giocatore specificato. Se il giocatore non ha il territorio si solleva il no data found
ID_G Giocatore.ID_Gamer%type;                       -- Id del giocatore
tot_carri number:=0;                                -- Numero di carri massimo inseribile
old_ins number := 0;                                -- Usato per verificare se sono presenti precedenti inserimenti
n_truppe number :=0;                                -- Numero di truppe già presenti nel territorio scelto
old_truppe number :=0;                              -- Numero di truppe inserire nei precedenti inserimenti

/* Dichiarazione eccezioni */
err_truppe EXCEPTION;                               -- Sollevata se il giocatore inserisce un numero di carri maggiore di quelli che può avere

/* Inizio trigger */
begin
  
  select max(ID_Turno) into Last_T 		-- Non vi è alcuna eccezione a catturare un eventuale NO_DATA_FOUND poiché verrebbe bloccata prima l'inserimento della riga in seguito ad una violazione dei vincoli sulla variabile
  from Turno
  where(ID_Partita = :new.ID_Partita);
  
  :new.ID_Turno := Last_T;                                                               	-- Viene inserito automaticamente il valore giusto dell'ultimo Turno iniziato
  
  SELECT count(ID_POSIZIONAMENTO) INTO ID_POS
  FROM POSIZIONAMENTO_ARMATA
  WHERE (ID_Partita = :new.ID_Partita) and (ID_Turno = Last_T);
					
																							-- Controllo sul numero di posizionamenti già eseguiti
  IF(ID_Pos = 0) then 																		-- Quando la riga inserita è la prima per quel turno, vengono inseriti i valori di default
    :new.ID_Posizionamento := 1;
    ID_Pos := 1;
  Else 																						-- altrimenti è presente almeno un valore e quindi gli assegno quello massimo + 1
    :new.ID_Posizionamento := ID_Pos + 1;
  end if;
  
  IF(Last_T = 0) then
    :new.ID_Territorio_Pos := 1;
    :new.Tipo_posizionamento := 0;
    :new.Rinforzi_Truppe := 0;
  else
    
    select T.ID_Gamer into ID_G     -- Prelevo l'id del giocatore
    from Turno T 
    where (ID_Partita = :new.ID_Partita) AND (T.ID_Turno = :new.ID_Turno);
    
    Select ID_Territorio into terr_temp -- solleva un eccezione se il giocatore inserito non ha il territorio poiché non esisterà quella combinazione di ID_Territorio e ID_Gamer
    from Territorio_Occupato
    where((ID_Territorio = :new.ID_Territorio_pos) and ( Giocatore_Occupante = ID_G) AND (ID_PARTITA = :new.ID_PARTITA));
    
    
    IF(:new.Tipo_Posizionamento != 0)  -- Se 0 non si esegue nulla in quanto considerato preliminare
    THEN
        IF(:new.Tipo_Posizionamento = 1)  -- Posizionamento classico
        then
          tot_carri := Inserimento_classico(:new.ID_Partita, ID_G); -- Prendo il numero di carri che il giocatore deve inserire
          
         -- Verifico che il giocatore non abbia già fatto altri inserimenti
         SELECT COUNT(*) into old_ins
          FROM POSIZIONAMENTO_ARMATA
          WHERE ((ID_Partita = :new.ID_Partita) and ( ID_Turno = :new.ID_Turno));
         -- Questo è il primo inserimento
         IF(old_ins = 0) 
          THEN
              if(:new.RINFORZI_TRUPPE > tot_carri) -- Verifico che non voglia inserire un numero di armate maggiore
             THEN
                raise err_truppe;
             ELSE                                  -- Caso contrario le aggiungo
            UPDATE TERRITORIO_OCCUPATO 
              SET Quantita_Truppe = quantita_Truppe + :new.Rinforzi_Truppe
              where(ID_partita = :new.ID_Partita) and (ID_Territorio = :new.ID_Territorio_Pos);
            END IF;
          ELSE -- Ci sono stati altri inserimenti
          
          -- Prendo il numero di armate dei vecchi inserimenti, li sommo, e verifico che non superino il numero di armate massimo espresso da tot carri
          SELECT sum(RINFORZI_TRUPPE) into n_truppe
            FROM POSIZIONAMENTO_ARMATA
            WHERE ((ID_Partita = :new.ID_Partita) and ( ID_Turno = :new.ID_Turno));
            
             old_truppe := :new.Rinforzi_Truppe + n_truppe;
            
             if(old_truppe > tot_carri) 
             THEN
                raise err_truppe;
             ELSE   
            UPDATE TERRITORIO_OCCUPATO 
              SET Quantita_Truppe = quantita_Truppe + :new.Rinforzi_Truppe
              where(ID_partita = :new.ID_Partita) and (ID_Territorio = :new.ID_Territorio_Pos);
            END IF; 
          END IF;
          
        elsif(:new.Tipo_Posizionamento > 1) then -- Inserimento tramite combinazione di carte
           tot_carri := Combinazione(:new.ID_Partita, ID_G, :new.Tipo_posizionamento);
          -- Se il giocatore non ha la combinazione tot carri è 0
          UPDATE TERRITORIO_OCCUPATO 
            SET Quantita_Truppe = quantita_Truppe + :new.Rinforzi_Truppe
            where(ID_partita = :new.ID_Partita) and (ID_Territorio = :new.ID_Territorio_Pos);
        end if;
      end if;
  END IF;
  
  /* Gestione eccezioni */
  exception
    WHEN err_truppe THEN
     Raise_application_error(-20030,'Hai inserito un numero di carri maggiore di quelli che puoi avere!');
    when no_data_Found then 
      Raise_application_error(-20031,'OPS! Il territorio non è il tuo');
    when others then
      raise_application_error(-20032, 'Errore generico di: INSERIMENTO_CARRI');
end;

/

--------------------------  --------------------------  [Fine Script]  --------------------------  --------------------------  