
-- QUERY 1: Prodotto di categoria tra prezzoMin e prezzoMax

DROP PROCEDURE IF EXISTS SelezionaProdotto;
DELIMITER $$
CREATE PROCEDURE SelezionaProdotto (
									IN _categoria CHAR(50),
									IN _prezzoMin INT,
									IN _prezzoMax INT
									)
BEGIN

	SELECT PE.CodProdotto, IP.Nome, PE.Marca, PE.Modello, PE.Prezzo
	FROM prodottoelettronico PE INNER JOIN infoprodotto IP ON PE.Marca = IP.Marca AND PE.Modello = IP.Modello
	WHERE IP.Categoria = _categoria AND (PE.Prezzo BETWEEN _prezzoMin AND _prezzoMax);

END $$
DELIMITER ;

CALL SelezionaProdotto ('Smartphone', '300', '500');


-- QUERY 2: Media di unita perse di una sequenza montaggio

DROP PROCEDURE IF EXISTS MediaUnitaPerseSeqMontaggio;
DELIMITER $$
CREATE PROCEDURE MediaUnitaPerseSeqMontaggio (IN _sequenza INT)
BEGIN

	WITH LottiSeq AS
	(
	SELECT LP.CodLotto
	FROM LottoProduzione LP INNER JOIN SequenzaMontaggio SM ON LP.SequenzaMontaggio = SM.CodSequenza
	WHERE SM.CodSequenza = _sequenza
	),
	TotPerse AS (
	SELECT LS.CodLotto, Count(*) as NumPerse 
	FROM LottiSeq LS INNER JOIN UnitaPersa UP ON LS.CodLotto = UP.Lotto
	GROUP BY LS.CodLotto
	)

	SELECT Avg(NumPerse) as MediaPerse
	FROM TotPerse TP;

END $$
DELIMITER ;

CALL MediaUnitaPerseSeqMontaggio ('24');


 -- QUERY 3: Nuova unita persa
 
DROP PROCEDURE IF EXISTS NuovaPersa;
DELIMITER $$
CREATE PROCEDURE NuovaPersa (
							 IN _lotto INT,
                             IN _codStazione INT,
                             IN _operazioniStazione INT
                             )
BEGIN

	INSERT INTO UnitaPersa(Lotto, Stazione, OperazioniStazione) VALUES (_lotto, _codStazione, _operazioniStazione);

END $$
DELIMITER ;

CALL NuovaPersa('64', '96', '5');


-- QUERY 4: Cronologia prodotto acquistati

DROP PROCEDURE IF EXISTS Cronologia;
DELIMITER $$
CREATE PROCEDURE Cronologia (IN _utente CHAR(50))
BEGIN

	SELECT IP.Nome, IP.Marca, IP.Modello, SZ.PrezzoPagato, OD.DataOrdine
	FROM Ordine OD INNER JOIN Selezionato SZ INNER JOIN ProdottoElettronico PE INNER JOIN InfoProdotto IP
		ON OD.CodOrdine = SZ.Ordine AND SZ.ProdottoElettronico = PE.CodProdotto AND
		PE.Marca = IP.Marca AND PE.Modello = IP.Modello 
	WHERE OD.Account = _utente AND OD.Stato <> 'Carrello'
	ORDER BY DataOrdine DESC;

END $$
DELIMITER ;

CALL Cronologia('AttaLu');


-- QUERY 5: Operatori che hanno perso piu di una unita nello stesso lotto durante una determinata sequenza montaggio

DROP PROCEDURE IF EXISTS OperatoriUnitaPerse;
DELIMITER $$
CREATE PROCEDURE OperatoriUnitaPerse (IN _sequenza INT)
BEGIN

	WITH LottiSeq AS
	(
	SELECT LP.CodLotto
	FROM LottoProduzione LP INNER JOIN SequenzaMontaggio SM ON LP.SequenzaMontaggio = SM.CodSequenza
	WHERE SM.CodSequenza = _sequenza
	),
	StazioniPerse AS
	(
	SELECT UP.Stazione
	FROM LottiSeq LS INNER JOIN UnitaPersa UP ON LS.CodLotto = UP.Lotto
	GROUP BY UP.Lotto, UP.Stazione
	HAVING COUNT(*) > 1
	)

	SELECT Operatore
	FROM StazioniPerse SP INNER JOIN StazioneMontaggio SM ON SP.Stazione = SM.CodStazione;

END $$
DELIMITER ;

CALL OperatoriUnitaPerse('26');


-- QUERY 6: Ranking prodotti di categoria piu venduti

DROP PROCEDURE IF EXISTS ProdottiPiuVenduti;
DELIMITER $$
CREATE PROCEDURE ProdottiPiuVenduti (IN _categoria CHAR(50))
BEGIN

	SELECT IP.Nome, IP.Marca, IP.Modello, PE.Prezzo, PE.NumVenduti, Rank() OVER (Order By PE.NumVenduti DESC) as Ranking
	FROM ProdottoElettronico PE INNER JOIN InfoProdotto IP ON PE.Marca = IP.Marca AND PE.Modello = IP.Modello 
	WHERE IP.Categoria = _categoria;

END $$
DELIMITER ;

CALL ProdottiPiuVenduti('Smartphone');


-- QUERY 7: Nuovo ordine (carrello)

DROP PROCEDURE IF EXISTS NuovoOrdine;
DELIMITER $$
CREATE PROCEDURE NuovoOrdine (IN _utente CHAR(50))
BEGIN 

	INSERT INTO Ordine(Account) VALUES (_utente);

END $$
DELIMITER ;

CALL NuovoOrdine('Seba30');


-- QUERY 8: Nuovo prodotto nel carrello

DROP PROCEDURE IF EXISTS AggiungiProdotto;
DELIMITER $$
CREATE PROCEDURE AggiungiProdotto (
								   IN _ordine INT,
                                   IN _prodottoElettronico INT,
                                   IN _quantita INT
                                   )
BEGIN

	INSERT INTO Selezionato(Ordine, ProdottoElettronico, Quantita) VALUES (_ordine, _prodottoElettronico, _quantita);

END $$
DELIMITER ;

CALL AggiungiProdotto('26', '2', '1');

-- QUERY 9: Completamento di un ordine con indirizzo alternativo

DROP PROCEDURE IF EXISTS OrdineCompletato;

DELIMITER $$
CREATE PROCEDURE OrdineCompletato(IN _CodOrdine int(10), 
								  IN _NumeroCarta char(50),
                                  IN _TipoCarta char(50),
                                  IN _Nome char(50),
                                  IN _Cognome char(50),
                                  IN _AnnoScadenza int(4),
                                  IN _MeseScadenza int(2),
                                  IN _DataPrevista date,
                                  IN _CostoSpedizione int(10),
                                  IN _Provincia char(50),
                                  IN _Citta char(50),
                                  IN _CAP int,
                                  IN _Via char(50),
                                  IN _NumeroCivico char(50),
                                  OUT CodSpedizione_ int
                                  )

BEGIN
	
    DECLARE _CodiceIndirizzo int DEFAULT NULL;
    DECLARE Trovato int DEFAULT 1;
    DECLARE Finito int DEFAULT 0;
    DECLARE _ProdottoElettronico int(10) DEFAULT NULL;
    DECLARE _Quantita int DEFAULT 0;
    DECLARE _ProdottoDisponibile int(10) DEFAULT NULL;
    DECLARE ScorriProdotti CURSOR FOR (
										SELECT S.ProdottoElettronico, S.Quantita
                                        FROM Selezionato S
                                        WHERE S.Ordine = _CodOrdine
                                        );
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET Finito = 1;
     
     
 IF _CodOrdine IN (SELECT O.CodOrdine
					   FROM Ordine O 
                       WHERE O.Stato = 'Carrello') THEN
    -- Inserimento in CartaPagamento
    INSERT IGNORE INTO CartaPagamento VALUES (_TipoCarta, _NumeroCarta, _Nome, _Cognome, _AnnoScadenza, _MeseScadenza);
    
    -- Inserimento in RicevutaFiscale
    INSERT INTO RicevutaFiscale(Ordine, TipoCarta, NumeroCarta)
    VALUES (_CodOrdine, _TipoCarta, _NumeroCarta);
    
    -- Inserimento, se non è già presente, del CAP
    INSERT IGNORE INTO CodicePostale VALUES (_CAP, _Citta, _Provincia);
    
    -- Inserimento, se non è già presente, dell'Indirizzo
    INSERT IGNORE INTO Indirizzo(CAP, Via, Numero)
    VALUES (_CAP, _Via, _NumeroCivico);
    
    -- Trovo il codice dell'indirizzo 
    SET _CodiceIndirizzo = (
							SELECT I.CodIndirizzo
                            FROM Indirizzo I
                            WHERE I.CAP = _CAP AND I.Via = _Via AND I.Numero = _NumeroCivico
                            );
    
    -- Inserimento in Spedizione 
    INSERT INTO Spedizione(Ordine, DataPrevista, Stato, IndirizzoAlternativo, Costo) 
    VALUES (_CodOrdine, _DataPrevista, "Non ancora spedita", _CodiceIndirizzo, _CostoSpedizione);
    
    SET CodSpedizione_ = last_insert_id();
                            
    -- Selezione prodotti e inserimento in Ordinazione
    OPEN ScorriProdotti;
    Scan: LOOP
    FETCH ScorriProdotti INTO _ProdottoElettronico, _Quantita;
    
    -- Inserimento del prezzo pagato per ogni prodotto
    UPDATE Selezionato
    SET PrezzoPagato = (SELECT PE.Prezzo
						FROM ProdottoElettronico PE
                        WHERE PE.CodProdotto = _ProdottoElettronico
                        )
	WHERE Ordine = _CodOrdine AND ProdottoElettronico = _ProdottoElettronico;
    
    SelezionaProdotto: LOOP 
    
    SET _Quantita = _Quantita - 1;
    IF (_Quantita < 0) THEN 
		LEAVE SelezionaProdotto;
    END IF;
    
    SET _ProdottoDisponibile = (
    SELECT MIN(PS.CodSeriale) AS PrimoDisponibile
    FROM ProdottoSpecifico PS LEFT OUTER JOIN Ordinazione OZ ON PS.CodSeriale = OZ.ProdottoSpecifico
    WHERE PS.ProdottoElettronico = _ProdottoElettronico AND OZ.Ordine IS NULL
    );
    
    IF _ProdottoDisponibile IS NULL THEN
     SET Trovato = 0;
	ELSE 
     INSERT INTO Ordinazione(Ordine, ProdottoSpecifico) VALUES (_CodOrdine, _ProdottoDisponibile);
	END IF;
    
    END LOOP SelezionaProdotto;
    
    IF Finito = 1 THEN 
		LEAVE Scan;
	END IF;
    END LOOP Scan;
    CLOSE ScorriProdotti;
    
	-- Aggiornamento dello stato dell'ordine: NON è più un carrello
    UPDATE Ordine
    SET Stato = IF(Trovato = 0, "Pendente", "In processazione")
    WHERE CodOrdine = _CodOrdine;

ELSE 
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'L\'ordine e\' gia\' stato completato';
        
END IF;
END $$
DELIMITER ;


CALL OrdineCompletato('6', '7285 9405 7182 9304', 'American Express', 'Mario', 'Rossi', '2022', '11', '2020-12-07', '7.50', 'Roma', 'Roma', '00101', 'Via Roma', '1', @MiaSpedizione);
SELECT @MiaSpedizione; 


-- QUERY 10: Incassi del mese dell'anno richiesto derivanti da ordini

DROP PROCEDURE IF EXISTS IncassiMeseAnno;
DELIMITER $$
CREATE PROCEDURE IncassiMeseAnno(
								 IN _anno INT,
                                 IN _mese INT 
                                 )
BEGIN

	SELECT SUM(S.PrezzoPagato*S.Quantita) AS IncassoTotale
	FROM Ordine OD INNER JOIN Selezionato S ON OD.CodOrdine = S.Ordine
	WHERE OD.Stato <> 'Carrello' AND (YEAR(OD.DataOrdine) = _anno AND MONTH(OD.DataOrdine) = _mese);

END $$
DELIMITER ;

CALL IncassiMeseAnno('2020', '10');


-- QUERY 11: Media voti di un prodotto

DROP PROCEDURE IF EXISTS MediaVotiProdotto;
DELIMITER $$
CREATE PROCEDURE MediaVotiProdotto (IN _prodotto INT)
BEGIN

	SELECT Avg(RS.Voto) AS MediaVoti
	FROM ProdottoElettronico PE INNER JOIN ProdottoSpecifico PS INNER JOIN Recensione RS 
		ON PE.CodProdotto = PS.ProdottoElettronico AND PS.CodSeriale = RS.ProdottoSpecifico
	WHERE PE.CodProdotto = _prodotto;

END $$
DELIMITER ;

CALL MediaVotiProdotto('1');


-- QUERY 12: Nuova recensione effettuata

DROP PROCEDURE IF EXISTS NuovaRecensione;
DELIMITER $$
CREATE PROCEDURE NuovaRecensione (
								  IN _voto INT,
                                  IN _descrizione CHAR(50),
                                  IN _prodotto INT
                                  )
BEGIN

	INSERT INTO Recensione VALUES (_prodotto, _voto, _descrizione);

END $$
DELIMITER ;

CALL NuovaRecensione('5', 'Ottimo prodotto', '204');


-- QUERY 13: Nuovo reso

DROP PROCEDURE IF EXISTS NuovoReso;
DELIMITER $$
CREATE PROCEDURE NuovoReso (
							IN _prodotto INT,
                            IN _motivazione INT,
                            IN _difettato CHAR(50)
                            )
BEGIN

	INSERT INTO Reso(ProdottoSpecifico, Motivazione, Difettato, DataReso)
	VALUES (_prodotto, _motivazione, _difettato, CURRENT_DATE());

END $$
DELIMITER ;

CALL NuovoReso('17', '4', 'Si');


-- QUERY 14: Classifica dei primi 5 prodotti più presenti negli ordini pendenti

DROP PROCEDURE IF EXISTS ProdottiOrdiniPendenti;
DELIMITER $$
CREATE PROCEDURE ProdottiOrdiniPendenti()
BEGIN

	WITH OrdiniPendenti AS
	(
		SELECT O1.CodOrdine
		FROM Ordine O1
		WHERE O1.Stato = 'Pendente'
	),
	ProdottiInOrdiniPendenti AS
	(
		SELECT PE.CodProdotto, COUNT(*) AS Quantita
		FROM OrdiniPendenti OP
			INNER JOIN
			Selezionato SZ
			INNER JOIN
			ProdottoElettronico PE
			ON SZ.Ordine = OP.CodOrdine
			AND SZ.ProdottoElettronico = PE.CodProdotto
		GROUP BY PE.CodProdotto
	)
	SELECT *
	FROM (
			SELECT RANK() OVER(ORDER BY Quantita DESC) AS Posizione, POP.CodProdotto, IP.Nome, PE2.Marca, PE2.Modello, POP.Quantita
			FROM ProdottiInOrdiniPendenti POP
				NATURAL JOIN
				ProdottoElettronico PE2
				INNER JOIN
				InfoProdotto IP
				ON PE2.Marca = IP.Marca
				AND PE2.Modello = IP.Modello
		) AS D
	WHERE D.Posizione <= 5;

END $$
DELIMITER ;

CALL ProdottiOrdiniPendenti();

-- QUERY 15: Scadenza delle garanzie di un prodotto con un'estensione della garanzia

DROP PROCEDURE IF EXISTS ScadenzaGaranzie;
DELIMITER $$
CREATE PROCEDURE ScadenzaGaranzie (IN _prodotto INT)
BEGIN

	SELECT G.CodGaranzia, G.ClasseGuasti, E.ScadenzaGaranzia
	FROM Estensione E
		INNER JOIN
		Garanzia G 
		ON E.Garanzia = G.CodGaranzia
	WHERE E.ProdottoSpecifico = _prodotto;

END $$
DELIMITER ;

CALL ScadenzaGaranzie('51');