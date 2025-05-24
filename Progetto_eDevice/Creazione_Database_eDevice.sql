BEGIN;
DROP DATABASE IF EXISTS eDevice;
CREATE DATABASE IF NOT EXISTS eDevice;
COMMIT;

USE eDevice;

DROP TABLE IF EXISTS Categoria;
CREATE TABLE Categoria(
Nome char(50) NOT NULL,
PRIMARY KEY (Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS InfoProdotto;
CREATE TABLE InfoProdotto(
Marca char(50) NOT NULL,
Modello char(50) NOT NULL,
Categoria char(50) NOT NULL,
Nome char(50),
NumFacce int NOT NULL,
PRIMARY KEY (Marca, Modello),
FOREIGN KEY (Categoria) REFERENCES Categoria(Nome),
INDEX MarcaModelloX (Marca, Modello)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS ProdottoElettronico;
CREATE TABLE ProdottoElettronico(
CodProdotto int NOT NULL AUTO_INCREMENT,
Marca char(50) NOT NULL,
Modello char(50) NOT NULL,
Colore char(50) NOT NULL,
Prezzo float NOT NULL,
SogliaResi int NOT NULL,
DataUscita date NOT NULL,
NumVenduti int NOT NULL DEFAULT 0,
NumVoti int NOT NULL DEFAULT 0,
TotVoti int NOT NULL DEFAULT 0,
PRIMARY KEY (CodProdotto),
FOREIGN KEY (Marca, Modello) REFERENCES InfoProdotto(Marca, Modello)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS CaratteristicaProdotto;
CREATE TABLE CaratteristicaProdotto(
Nome char(50) NOT NULL,
UnitaDiMisura char(50),
PRIMARY KEY (Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Variazione;
CREATE TABLE Variazione(
ProdottoElettronico int NOT NULL,
Caratteristica char(50) NOT NULL,
Variante int NOT NULL,
PRIMARY KEY (ProdottoElettronico, Caratteristica),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto),
FOREIGN KEY (Caratteristica) REFERENCES CaratteristicaProdotto(Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Lotto;
CREATE TABLE Lotto(
CodLotto int NOT NULL AUTO_INCREMENT,
NumProdotti int NOT NULL,
PRIMARY KEY (CodLotto)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS SequenzaMontaggio;
CREATE TABLE SequenzaMontaggio(
CodSequenza int NOT NULL AUTO_INCREMENT,
ProdottoElettronico int NOT NULL,
Tempo int NOT NULL,
PRIMARY KEY (CodSequenza),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS LottoProduzione;
CREATE TABLE LottoProduzione(
CodLotto int NOT NULL,
SequenzaMontaggio int NOT NULL,
Sede char(50) NOT NULL,
DataProduzione Date NOT NULL,
DurataPreventiva int NOT NULL,
DurataEffettiva int NOT NULL,
PRIMARY KEY (CodLotto),
FOREIGN KEY (CodLotto) REFERENCES Lotto(CodLotto),
FOREIGN KEY (SequenzaMontaggio) REFERENCES SequenzaMontaggio(CodSequenza)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS ProdottoSpecifico;
CREATE TABLE ProdottoSpecifico(
CodSeriale int(10) ZEROFILL NOT NULL AUTO_INCREMENT,
ProdottoElettronico int NOT NULL,
Lotto int,
AnnoProduzione int NOT NULL,
MeseProduzione int(2) ZEROFILL NOT NULL,
Ricondizionato enum("Si", "No") NOT NULL DEFAULT "No",
PRIMARY KEY (CodSeriale),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto),
FOREIGN KEY (Lotto) REFERENCES LottoProduzione(CodLotto)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Parte;
CREATE TABLE Parte(
CodParte int NOT NULL AUTO_INCREMENT,
Nome char(50) NOT NULL,
Peso int NOT NULL,
Prezzo int NOT NULL,
CoeffSvalutazione int NOT NULL,
PRIMARY KEY (CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Costituito;
CREATE TABLE Costituito(
ProdottoElettronico int NOT NULL,
Parte int NOT NULL,
Numero int NOT NULL DEFAULT 1,
PRIMARY KEY (ProdottoElettronico, Parte),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Materiale;
CREATE TABLE Materiale(
Nome char(50) NOT NULL,
Valore int NOT NULL,
PRIMARY KEY (Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Composizione;
CREATE TABLE Composizione(
Parte int NOT NULL,
Materiale char(50) NOT NULL,
Quantitativo int NOT NULL,
PRIMARY KEY (Parte, Materiale),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte),
FOREIGN KEY (Materiale) REFERENCES Materiale(Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Giunzione;
CREATE TABLE Giunzione(
CodGiunzione int NOT NULL AUTO_INCREMENT,
Tipo char(50) NOT NULL,
PRIMARY KEY (CodGiunzione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS CaratteristicaGiunzione;
CREATE TABLE CaratteristicaGiunzione(
Nome char(50) NOT NULL,
PRIMARY KEY (Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Catalogazione;
CREATE TABLE Catalogazione(
Giunzione int NOT NULL,
Caratteristica char(50) NOT NULL,
Variante int NOT NULL,
PRIMARY KEY (Giunzione, Caratteristica),
FOREIGN KEY (Giunzione) REFERENCES Giunzione(CodGiunzione),
FOREIGN KEY (Caratteristica) REFERENCES CaratteristicaGiunzione(Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS OperazioneMontaggio;
CREATE TABLE OperazioneMontaggio(
CodOperazione int NOT NULL AUTO_INCREMENT,
Nome char(50) NOT NULL,
Faccia int NOT NULL,
PRIMARY KEY (CodOperazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Utensile;
CREATE TABLE Utensile(
Nome char(50) NOT NULL,
PRIMARY KEY (Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS UtilizzoMontaggio;
CREATE TABLE UtilizzoMontaggio(
OperazioneMontaggio int NOT NULL,
Utensile char(50) NOT NULL,
PRIMARY KEY (OperazioneMontaggio, Utensile),
FOREIGN KEY (OperazioneMontaggio) REFERENCES OperazioneMontaggio(CodOperazione),
FOREIGN KEY (Utensile) REFERENCES Utensile(Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Montata;
CREATE TABLE Montata(
Operazione int NOT NULL,
Parte int NOT NULL,
PRIMARY KEY (Operazione, Parte),
FOREIGN KEY (Operazione) REFERENCES OperazioneMontaggio(CodOperazione),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Fissaggio;
CREATE TABLE Fissaggio(
Operazione int NOT NULL,
Giunzione int NOT NULL,
Quantita int NOT NULL,
PRIMARY KEY (Operazione, Giunzione),
FOREIGN KEY (Operazione) REFERENCES OperazioneMontaggio(CodOperazione),
FOREIGN KEY (Giunzione) REFERENCES Giunzione(CodGiunzione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Assemblaggio;
CREATE TABLE Assemblaggio(
OperazionePrecedente int NOT NULL,
OperazioneSuccessiva int NOT NULL,
PRIMARY KEY (OperazionePrecedente, OperazioneSuccessiva),
FOREIGN KEY (OperazionePrecedente) REFERENCES OperazioneMontaggio(CodOperazione),
FOREIGN KEY (OperazioneSuccessiva) REFERENCES OperazioneMontaggio(CodOperazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Operatore;
CREATE TABLE Operatore(
CodOperatore int(5) ZEROFILL NOT NULL AUTO_INCREMENT,
PRIMARY KEY (CodOperatore)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS StazioneMontaggio;
CREATE TABLE StazioneMontaggio(
CodStazione int NOT NULL AUTO_INCREMENT,
Operatore int(5) ZEROFILL NOT NULL,
OrientazioneProdotto int NOT NULL,
PRIMARY KEY (CodStazione),
FOREIGN KEY (Operatore) REFERENCES Operatore(CodOperatore)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS AzioneM;
CREATE TABLE AzioneM(
Stazione int NOT NULL,
Operazione int NOT NULL,
NumOperazione int NOT NULL,
PRIMARY KEY (Stazione, Operazione),
FOREIGN KEY (Operazione) REFERENCES OperazioneMontaggio(CodOperazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS UnitaPersa;
CREATE TABLE UnitaPersa(
CodPersa int NOT NULL AUTO_INCREMENT,
Lotto int NOT NULL,
Stazione int NOT NULL,
OperazioniStazione int NOT NULL,
PRIMARY KEY (CodPersa),
FOREIGN KEY (Lotto) REFERENCES LottoProduzione(CodLotto),
FOREIGN KEY (Stazione) REFERENCES StazioneMontaggio(CodStazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS OperazioneCampione;
CREATE TABLE OperazioneCampione(
CodCampione int NOT NULL AUTO_INCREMENT,
Nome char(50) NOT NULL,
PRIMARY KEY (CodCampione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Specializzazione;
CREATE TABLE Specializzazione(
Operatore int(5) ZEROFILL NOT NULL,
OperazioneCampione int NOT NULL,
Tempo int NOT NULL,
Varianza int NOT NULL,
PRIMARY KEY (Operatore, OperazioneCampione),
FOREIGN KEY (Operatore) REFERENCES Operatore(CodOperatore),
FOREIGN KEY (OperazioneCampione) REFERENCES OperazioneCampione(CodCampione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS OrganizzazioneM;
CREATE TABLE OrganizzazioneM(
Sequenza int NOT NULL,
Stazione int NOT NULL,
NumStazione int NOT NULL,
PRIMARY KEY (Sequenza, Stazione),
FOREIGN KEY (Sequenza) REFERENCES SequenzaMontaggio(CodSequenza),
FOREIGN KEY (Stazione) REFERENCES StazioneMontaggio(CodStazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Magazzino;
CREATE TABLE Magazzino(
CodMagazzino int NOT NULL AUTO_INCREMENT,
Predisposizione char(50) NOT NULL,
Capienza int NOT NULL,
NumeroAree int NOT NULL,
PRIMARY KEY (CodMagazzino)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS StoccaggioLotto;
CREATE TABLE StoccaggioLotto(
Lotto int NOT NULL,
Magazzino int NOT NULL,
DataImmagazzinamento Date NOT NULL,
DataRimozione Date DEFAULT NULL,
NumArea int NOT NULL,
PRIMARY KEY (Lotto, Magazzino),
FOREIGN KEY (Lotto) REFERENCES Lotto(CodLotto),
FOREIGN KEY (Magazzino) REFERENCES Magazzino(CodMagazzino)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS CodicePostale;
CREATE TABLE CodicePostale(
CAP int(5) ZEROFILL NOT NULL,
Citta char(50) NOT NULL,
Provincia char(50) NOT NULL,
PRIMARY KEY (CAP)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Indirizzo;
CREATE TABLE Indirizzo(
CodIndirizzo int NOT NULL AUTO_INCREMENT,
CAP int(5) ZEROFILL NOT NULL,
Via char(50) NOT NULL,
Numero char(50) NOT NULL,
PRIMARY KEY (CodIndirizzo),
FOREIGN KEY (CAP) REFERENCES CodicePostale(CAP),
UNIQUE(CAP, Via, Numero)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Documento;
CREATE TABLE Documento(
Tipo char(50) NOT NULL,
NumDocumento char(50) NOT NULL,
EnteRilascio char(50) NOT NULL,
Scadenza Date NOT NULL,
PRIMARY KEY (Tipo, NumDocumento),
INDEX TipoNumDocumentoX(Tipo, NumDocumento)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Account;
CREATE TABLE Account(
Username char(50) NOT NULL,
Password char(50) NOT NULL,
DomandaSicurezza char(50) NOT NULL,
RispostaSicurezza char(50) NOT NULL,
DataIscrizione Date NOT NULL,
PRIMARY KEY (Username)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Persona;
CREATE TABLE Persona(
CodFiscale char(50) NOT NULL,
Nome char(50) NOT NULL,
Cognome char(50) NOT NULL,
NumTelefono char(50),
Account char(50) NOT NULL,
TipoDocumento char(50) NOT NULL,
NumDocumento char(50) NOT NULL,
Indirizzo int NOT NULL,
PRIMARY KEY (CodFiscale),
FOREIGN KEY (Account) REFERENCES Account(Username),
FOREIGN KEY (TipoDocumento, NumDocumento) REFERENCES Documento(Tipo, NumDocumento),
FOREIGN KEY (Indirizzo) REFERENCES Indirizzo(CodIndirizzo)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Ordine;
CREATE TABLE Ordine(
CodOrdine int(10) ZEROFILL NOT NULL AUTO_INCREMENT,
Account char(50) NOT NULL,
DataOrdine Date DEFAULT NULL,
Stato enum("Carrello", "In processazione", "In preparazione", "Spedito", "Evaso", "Pendente") NOT NULL DEFAULT "Carrello",
NumProdotti int NOT NULL DEFAULT 0,
PRIMARY KEY (CodOrdine),
FOREIGN KEY (Account) REFERENCES Account(Username)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Selezionato;
CREATE TABLE Selezionato(
Ordine int(10) ZEROFILL NOT NULL,
ProdottoElettronico int(10) NOT NULL,
Quantita int NOT NULL,
PrezzoPagato float DEFAULT NULL,
PRIMARY KEY (Ordine, ProdottoElettronico),
FOREIGN KEY (Ordine) REFERENCES Ordine(CodOrdine),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto)
) ENGINE=InnoDB DEFAULT CHARSET = latin1;

-- Trigger che aggiorna la ridondanza del numero dei prodotti all'interno di un ordine non ancora completato quando ne viene aggiunto uno
DROP TRIGGER IF EXISTS AggiungiProdotto;
DELIMITER $$
CREATE TRIGGER AggiungiProdotto
AFTER INSERT ON Selezionato
FOR EACH ROW

BEGIN
UPDATE Ordine
SET NumProdotti = NumProdotti + NEW.Quantita
WHERE CodOrdine = NEW.Ordine;

END $$
DELIMITER ;

-- Trigger che aggiorna la ridondanza del numero dei prodotti all'interno di un ordine non ancora completato quando ne viene rimosso uno
DROP TRIGGER IF EXISTS RimuoviProdotto;
DELIMITER $$
CREATE TRIGGER RimuoviProdotto
BEFORE DELETE ON Selezionato
FOR EACH ROW

BEGIN
UPDATE Ordine
SET NumProdotti = NumProdotti - OLD.Quantita
WHERE CodOrdine = OLD.Ordine;

END $$
DELIMITER ;

DROP TABLE IF EXISTS Ordinazione;
CREATE TABLE Ordinazione(
Ordine int(10) ZEROFILL NOT NULL,
ProdottoSpecifico int(10) ZEROFILL NOT NULL,
PRIMARY KEY (ProdottoSpecifico),
FOREIGN KEY (Ordine) REFERENCES Ordine(CodOrdine),
FOREIGN KEY (ProdottoSpecifico) REFERENCES ProdottoSpecifico(CodSeriale)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Trigger che incrementa il dato che memorizza il numero di volte che un prodotto è stato venduto 
DROP TRIGGER IF EXISTS AggiungiVenduto;
DELIMITER $$
CREATE TRIGGER AggiungiVenduto 
AFTER INSERT ON Ordinazione
FOR EACH ROW

BEGIN
UPDATE ProdottoElettronico
SET NumVenduti = NumVenduti + 1
WHERE CodProdotto = ( 
						SELECT *
						FROM
							(
							SELECT PE.CodProdotto
							FROM ProdottoElettronico PE INNER JOIN ProdottoSpecifico PS ON PE.CodProdotto = PS.ProdottoElettronico
							WHERE PS.CodSeriale = NEW.ProdottoSpecifico
                            ) AS D
					);
END $$
DELIMITER ;

DROP TABLE IF EXISTS CartaPagamento;
CREATE TABLE CartaPagamento(
Tipo char(50) NOT NULL,
Numero char(50) NOT NULL,
Nome char(50) NOT NULL,
Cognome char(50) NOT NULL,
AnnoScadenza int(4) NOT NULL,
MeseScadenza int(2) ZEROFILL NOT NULL,
PRIMARY KEY (Tipo, Numero)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Spedizione;
CREATE TABLE Spedizione(
CodSpedizione int NOT NULL AUTO_INCREMENT,
Ordine int(10) ZEROFILL NOT NULL,
DataPrevista Date NOT NULL,
DataCosegna Date,
Stato enum("Non ancora spedita", "Spedita", "In transito", "In consegna", "Consegnata")  NOT NULL,
HubTotali int,
IndirizzoAlternativo int,
Costo float,
PRIMARY KEY (CodSpedizione),
FOREIGN KEY (Ordine) REFERENCES Ordine(CodOrdine),
FOREIGN KEY (IndirizzoAlternativo) REFERENCES Indirizzo(CodIndirizzo)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Hub;
CREATE TABLE Hub(
NomeHub char(50) NOT NULL,
Indirizzo int NOT NULL,
PRIMARY KEY (NomeHub),
FOREIGN KEY (Indirizzo) REFERENCES Indirizzo(CodIndirizzo)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Tragitto;
CREATE TABLE Tragitto(
Spedizione int NOT NULL,
Hub char(50) NOT NULL,
NumeroHub int NOT NULL,
DataArrivo Date,
DataPartenza Date,
PRIMARY KEY (Spedizione, Hub),
FOREIGN KEY (Spedizione) REFERENCES Spedizione(CodSpedizione),
FOREIGN KEY (Hub) REFERENCES Hub(NomeHub)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Garanzia;
CREATE TABLE Garanzia(
CodGaranzia int NOT NULL AUTO_INCREMENT,
ClasseGuasti char(50) NOT NULL,
EstensioneMesi int NOT NULL,
Costo float NOT NULL,
PRIMARY KEY (CodGaranzia)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Estensione;
CREATE TABLE Estensione(
ProdottoSpecifico int(10) ZEROFILL NOT NULL,
Garanzia int NOT NULL,
ScadenzaGaranzia date NOT NULL,
PRIMARY KEY (ProdottoSpecifico, Garanzia),
FOREIGN KEY (ProdottoSpecifico) REFERENCES ProdottoSpecifico(CodSeriale),
FOREIGN KEY (Garanzia) REFERENCES Garanzia(CodGaranzia)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Trigger che aggiorna la data di scadenza al seguito di una estensione di garanzia nel momento in cui un prodotto viene acquistato
DROP TRIGGER IF EXISTS AggiornaScadenza; 
DELIMITER $$
CREATE TRIGGER AggiornaScadenza
BEFORE INSERT ON Estensione
FOR EACH ROW 

BEGIN
DECLARE DataOrdine date DEFAULT NULL;
DECLARE Mesi int DEFAULT 0;

SET DataOrdine = (
				 SELECT OD.DataOrdine
				 FROM ProdottoSpecifico PS INNER JOIN Ordinazione OZ INNER JOIN Ordine OD
						ON PS.CodSeriale = OZ.ProdottoSpecifico AND OZ.Ordine = OD.CodOrdine
                 WHERE PS.CodSeriale = NEW.ProdottoSpecifico
                 );
                 
SET Mesi = (
			SELECT G.EstensioneMesi
            FROM Garanzia G
            WHERE G.CodGaranzia = NEW.Garanzia
            );
            
SET NEW.ScadenzaGaranzia = DataOrdine + INTERVAL Mesi MONTH;

END $$
DELIMITER ;

DROP TABLE IF EXISTS Motivazione;
CREATE TABLE Motivazione(
CodMotivazione int NOT NULL AUTO_INCREMENT,
Nome char(50) NOT NULL,
Descrizione char(50) DEFAULT NULL,
PRIMARY KEY (CodMotivazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS LottoResi;
CREATE TABLE LottoResi(
CodLotto int NOT NULL,
DataCreazione Date NOT NULL,
DataTest Date,
PRIMARY KEY (CodLotto),
FOREIGN KEY (CodLotto) REFERENCES Lotto(CodLotto)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Reso;
CREATE TABLE Reso(
CodReso int NOT NULL AUTO_INCREMENT,
ProdottoSpecifico int(10) ZEROFILL NOT NULL,
Motivazione int NOT NULL,
Difettato enum("Si", "No") NOT NULL,
DataReso Date NOT NULL,
LottoResi int DEFAULT NULL,
PRIMARY KEY (CodReso),
FOREIGN KEY (ProdottoSpecifico) REFERENCES ProdottoSpecifico(CodSeriale),
FOREIGN KEY (Motivazione) REFERENCES Motivazione(CodMotivazione),
FOREIGN KEY (LottoResi) REFERENCES LottoResi(CodLotto)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS StoccaggioReso;
CREATE TABLE StoccaggioReso(
Reso int NOT NULL,
Magazzino int NOT NULL,
DataImmagazzinamento Date NOT NULL,
DataRimozione Date,
NumArea int NOT NULL,
PRIMARY KEY (Reso, Magazzino),
FOREIGN KEY (Reso) REFERENCES Reso(CodReso),
FOREIGN KEY (Magazzino) REFERENCES Magazzino(CodMagazzino)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Recensione;
CREATE TABLE Recensione(
ProdottoSpecifico int(10) ZEROFILL NOT NULL,
Voto int(1) NOT NULL CHECK(Voto>0 AND Voto<6),
Descrizione text DEFAULT NULL,
PRIMARY KEY (ProdottoSpecifico),
FOREIGN KEY (ProdottoSpecifico) REFERENCES ProdottoSpecifico(CodSeriale)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Trigger che aggiorna il numero di recensioni effettuate per un determinato prodotto quando ne viene inserita una nuova
-- Inoltre somma il nuovo voto al totale dei voti per permettere di calcolare la media dividendo il totale dei voti per il numero di essi.
DROP TRIGGER IF EXISTS MediaVoti;
DELIMITER $$
CREATE TRIGGER MediaVoti
AFTER INSERT ON Recensione
FOR EACH ROW

BEGIN

UPDATE ProdottoElettronico
SET NumVoti = NumVoti + 1, TotVoti = TotVoti + NEW.Voto
WHERE CodProdotto = (
                        SELECT *
                        FROM (
                                SELECT DISTINCT PE.CodProdotto
                                FROM Recensione R
                                    INNER JOIN 
                                    ProdottoSpecifico PS
                                    INNER JOIN 
                                    ProdottoElettronico PE
                                    ON R.ProdottoSpecifico = PS.CodSeriale
                                    AND PS.ProdottoElettronico = PE.CodProdotto
                                WHERE R.ProdottoSpecifico = NEW.ProdottoSpecifico
                                ) AS D
                            );
                        
END $$
DELIMITER ;

DROP TABLE IF EXISTS Sintomo;
CREATE TABLE Sintomo(
CodSintomo int NOT NULL AUTO_INCREMENT,
Nome char(50),
Descrizione char(50),
PRIMARY KEY (CodSintomo)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Errore;
CREATE TABLE Errore(
ProdottoElettronico int NOT NULL,
Sintomo int NOT NULL,
CodErrore int NOT NULL,
PRIMARY KEY (ProdottoElettronico, Sintomo),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto),
FOREIGN KEY (Sintomo) REFERENCES Sintomo(CodSintomo)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Rimedio;
CREATE TABLE Rimedio(
CodRimedio int NOT NULL AUTO_INCREMENT,
Descrizione char(50), 
PRIMARY KEY (CodRimedio)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Soluzione;
CREATE TABLE Soluzione(
Sintomo int NOT NULL,
Rimedio int NOT NULL,
PRIMARY KEY (Sintomo, Rimedio),
FOREIGN KEY (Sintomo) REFERENCES Sintomo(CodSintomo),
FOREIGN KEY (Rimedio) REFERENCES Rimedio(CodRimedio)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Domanda;
CREATE TABLE Domanda(
CodDomanda int NOT NULL AUTO_INCREMENT,
Questione char(50) NOT NULL,
Rimedio int NOT NULL,
PRIMARY KEY (CodDomanda),
FOREIGN KEY (Rimedio) REFERENCES Rimedio(CodRimedio)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Assistenza;
CREATE TABLE Assistenza(
ProdottoElettronico int NOT NULL,
Domanda int NOT NULL,
NumDomanda int NOT NULL,
PRIMARY KEY (ProdottoElettronico, Domanda),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto),
FOREIGN KEY (Domanda) REFERENCES Domanda(CodDomanda)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Guasto;
CREATE TABLE Guasto(
CodGuasto int NOT NULL AUTO_INCREMENT,
ProdottoElettronico int NOT NULL,
PRIMARY KEY(CodGuasto),
FOREIGN KEY(ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto)
) Engine=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Sintomatologia;
CREATE TABLE Sintomatologia(
Guasto int NOT NULL,
Sintomo int NOT NULL,
PRIMARY KEY(Guasto, Sintomo),
FOREIGN KEY (Guasto) REFERENCES Guasto(CodGuasto),
FOREIGN KEY (Sintomo) REFERENCES Sintomo(CodSintomo)
) Engine=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Risoluzione;
CREATE TABLE Risoluzione(
Guasto int NOT NULL,
Rimedio int NOT NULL,
NumRisolto int NOT NULL DEFAULT 0,
PRIMARY KEY(Guasto, Rimedio),
FOREIGN KEY (Guasto) REFERENCES Guasto(CodGuasto),
FOREIGN KEY (Rimedio) REFERENCES Rimedio(CodRimedio)
) Engine=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Tecnico;
CREATE TABLE Tecnico(
CodTecnico int(5) ZEROFILL NOT NULL AUTO_INCREMENT,
Provincia char(50) NOT NULL,
PRIMARY KEY (CodTecnico)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Orario;
CREATE TABLE Orario(
Data Date NOT NULL,
FasciaOraria enum("8", "9", "10", "11", "12", "15", "16", "17") NOT NULL,
PRIMARY KEY (Data, FasciaOraria)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Ticket;
CREATE TABLE Ticket(
Ticket int NOT NULL AUTO_INCREMENT,
Data Date NOT NULL,
Orario enum("8", "9", "10", "11", "12", "15", "16", "17") NOT NULL,
Account char(50) NOT NULL,
Tecnico int(5) ZEROFILL NOT NULL,
PRIMARY KEY (Ticket),
FOREIGN KEY (Data, Orario) REFERENCES Orario(Data, FasciaOraria),
FOREIGN KEY (Account) REFERENCES Account(Username),
FOREIGN KEY (Tecnico) REFERENCES Tecnico(CodTecnico)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Disponibilita;
CREATE TABLE Disponibilita(
Tecnico int(5) ZEROFILL NOT NULL,
Data Date NOT NULL,
FasciaOraria enum("8", "9", "10", "11", "12", "15", "16", "17") NOT NULL,
Disponibile char(50) NOT NULL,
PRIMARY KEY (Tecnico, Data, FasciaOraria),
FOREIGN KEY (Tecnico) REFERENCES Tecnico(CodTecnico),
FOREIGN KEY (Data, FasciaOraria) REFERENCES Orario(Data, FasciaOraria)
)  ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Preventivo;
CREATE TABLE Preventivo(
Ticket int NOT NULL,
DataAccettazione Date,
Prezzo float NOT NULL,
PRIMARY KEY (Ticket),
FOREIGN KEY (Ticket) REFERENCES Ticket(Ticket)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS RicevutaFiscale;
CREATE TABLE RicevutaFiscale(
CodRicevuta int NOT NULL AUTO_INCREMENT,
Ordine int(10) ZEROFILL,
Preventivo int DEFAULT NULL,
TipoCarta char(50) NOT NULL,
NumeroCarta char(50) NOT NULL,
PRIMARY KEY (CodRicevuta),
FOREIGN KEY (Ordine) REFERENCES Ordine(CodOrdine),
FOREIGN KEY (Preventivo) REFERENCES Preventivo(Ticket),
FOREIGN KEY (TipoCarta, NumeroCarta) REFERENCES CartaPagamento(Tipo, Numero)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS OrdinePezzi;
CREATE TABLE OrdinePezzi(
CodOrdine int NOT NULL AUTO_INCREMENT,
Preventivo int NOT NULL,
DataOrdine Date NOT NULL,
DataPrevista Date NOT NULL,
DataArrivo Date,
PRIMARY KEY (CodOrdine),
FOREIGN KEY (Preventivo) REFERENCES Preventivo(Ticket)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Ordinata;
CREATE TABLE Ordinata(
OrdinePezzi int NOT NULL,
Parte int NOT NULL,
PRIMARY KEY (OrdinePezzi, Parte),
FOREIGN KEY (OrdinePezzi) REFERENCES OrdinePezzi(CodOrdine),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Test;
CREATE TABLE Test(
CodTest int NOT NULL AUTO_INCREMENT,
ProdottoElettronico int NOT NULL,
Nome char(50) NOT NULL,
TotaleSottotest int NOT NULL,
TestPrecedente int,
PRIMARY KEY (CodTest),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto),
FOREIGN KEY (TestPrecedente) REFERENCES Test(CodTest)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Verifica;
CREATE TABLE Verifica(
Test int NOT NULL,
Parte int NOT NULL,
PRIMARY KEY (Test),
FOREIGN KEY (Test) REFERENCES Test(CodTest),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS TestSuperato;
CREATE TABLE TestSuperato(
Reso int NOT NULL,
Test int NOT NULL,
Superato enum("Si", "No") NOT NULL,
NumSottotestFalliti int,
PRIMARY KEY (Reso, Test),
FOREIGN KEY (Reso) REFERENCES Reso(CodReso),
FOREIGN KEY (Test) REFERENCES Test(CodTest)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Ricondizionamento;
CREATE TABLE Ricondizionamento(
ProdottoRicondizionato int(10) ZEROFILL NOT NULL,
ProdottoOriginale int(10) ZEROFILL NOT NULL,
PRIMARY KEY (ProdottoRicondizionato, ProdottoOriginale),
FOREIGN KEY (ProdottoRicondizionato) REFERENCES ProdottoSpecifico(CodSeriale),
FOREIGN KEY (ProdottoOriginale) REFERENCES ProdottoSpecifico(CodSeriale)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS StazioneSmontaggio;
CREATE TABLE StazioneSmontaggio(
CodStazione int NOT NULL AUTO_INCREMENT,
Operatore int(5) ZEROFILL NOT NULL,
OrientazioneProdotto int NOT NULL,
PRIMARY KEY (CodStazione),
FOREIGN KEY (Operatore) REFERENCES Operatore(CodOperatore) 
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS SequenzaSmontaggio;
CREATE TABLE SequenzaSmontaggio(
CodSequenza int NOT NULL AUTO_INCREMENT,
ProdottoElettronico int NOT NULL,
Tempo int NOT NULL,
PRIMARY KEY (CodSequenza),
FOREIGN KEY (ProdottoElettronico) REFERENCES ProdottoElettronico(CodProdotto)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS LottoEndOfLife;
CREATE TABLE LottoEndOfLife(
CodLotto int NOT NULL AUTO_INCREMENT,
SequenzaSmontaggio int NOT NULL,
SedeSmontaggio int NOT NULL,
DataSmontaggio Date,
DuaratPreventiva int,
DurataEffettiva int,
PRIMARY KEY (CodLotto),
FOREIGN KEY (CodLotto) REFERENCES Lotto(CodLotto),
FOREIGN KEY (SequenzaSmontaggio) REFERENCES SequenzaSmontaggio(CodSequenza)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Smaltimento;
CREATE TABLE Smaltimento(
LottoEndOfLife int NOT NULL,
ProdottoSpecifico int(10) ZEROFILL NOT NULL,
PRIMARY KEY (LottoEndOfLife, ProdottoSpecifico),
FOREIGN KEY (LottoEndOfLife) REFERENCES LottoEndOfLife(CodLotto),
FOREIGN KEY (ProdottoSpecifico) REFERENCES ProdottoSpecifico(CodSeriale)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS OrganizzazioneS;
CREATE TABLE OrganizzazoneS(
Sequenza int NOT NULL, 
Stazione int NOT NULL,
NumStazione int NOT NULL,
PRIMARY KEY (Sequenza, Stazione),
FOREIGN KEY (Sequenza) REFERENCES SequenzaSmontaggio(CodSequenza),
FOREIGN KEY (Stazione) REFERENCES StazioneSmontaggio(CodStazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS OperazioneSmontaggio;
CREATE TABLE OperazioneSmontaggio(
CodOperazione int NOT NULL AUTO_INCREMENT,
Nome char(50) NOT NULL,
Faccia int NOT NULL,
PRIMARY KEY (CodOperazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS UtilizzoSmontaggio;
CREATE TABLE UtilizzoSmontaggio(
OperazioneSmontaggio int NOT NULL,
Utensile char(50) NOT NULL,
PRIMARY KEY (OperazioneSmontaggio),
FOREIGN KEY (OperazioneSmontaggio) REFERENCES OperazioneSmontaggio(CodOperazione),
FOREIGN KEY (Utensile) REFERENCES Utensile(Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Smontaggio;
CREATE TABLE Smontaggio(
OperazionePrecedente int NOT NULL,
OperazioneSuccessiva int NOT NULL,
PRIMARY KEY (OperazionePrecedente, OperazioneSuccessiva),
FOREIGN KEY (OperazionePrecedente) REFERENCES OperazioneSmontaggio(CodOperazione),
FOREIGN KEY (OperazioneSuccessiva) REFERENCES OperazioneSmontaggio(CodOperazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Smontata;
CREATE TABLE Smontata(
Operazione int NOT NULL,
Parte int NOT NULL,
PRIMARY KEY (Operazione, Parte),
FOREIGN KEY (Operazione) REFERENCES OperazioneSmontaggio(CodOperazione),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS AzioneS;
CREATE TABLE AzioneS(
Stazione int NOT NULL,
Operazione int NOT NULL,
NumOperazione int NOT NULL,
PRIMARY KEY (Stazione, Operazione),
FOREIGN KEY (Stazione) REFERENCES StazioneSmontaggio(CodStazione),
FOREIGN KEY (Operazione) REFERENCES OperazioneSmontaggio(CodOperazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS UnitaScartata;
CREATE TABLE UnitaScartata(
CodScartata int NOT NULL AUTO_INCREMENT,
Lotto int NOT NULL,
Stazione int NOT NULL,
OperazioniStazione int NOT NULL,
PRIMARY KEY (CodScartata),
FOREIGN KEY (Lotto) REFERENCES LottoEndOfLife(CodLotto),
FOREIGN KEY (Stazione) REFERENCES StazioneSmontaggio(CodStazione)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS MaterialeRecuperato;
CREATE TABLE MaterialeRecuperato(
ProdottoSpecifico int(10) ZEROFILL NOT NULL,
Materiale char(50) NOT NULL,
Quantita int NOT NULL,
PRIMARY KEY (ProdottoSpecifico, Materiale),
FOREIGN KEY (ProdottoSpecifico) REFERENCES ProdottoSpecifico(CodSeriale),
FOREIGN KEY (Materiale) REFERENCES Materiale(Nome)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS ParteRecuperata;
CREATE TABLE ParteRecuperata(
ProdottoSpecifico int NOT NULL,
Parte int NOT NULL,
Numero int NOT NULL DEFAULT 1,
PRIMARY KEY (ProdottoSpecifico, Parte),
FOREIGN KEY (Parte) REFERENCES Parte(CodParte)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;