-- Analitycs 1 --

-- Procedura utilizzabile da un tecnico per memorizzare un nuovo guasto nel database 
DROP PROCEDURE IF EXISTS NuovoGuasto;
DELIMITER $$
CREATE PROCEDURE NuovoGuasto(IN _ProdottoElettronico int , IN _Sintomo1 int, IN _Sintomo2 int, IN _Sintomo3 int, IN _Sintomo4 int, IN _Sintomo5 int, IN _Sintomo6 int,
							 IN _Rimedio1 int, IN _Rimedio2 int, IN _Rimedio3 int, IN _Rimedio4 int, IN _Rimedio5 int, IN _Rimedio6 int)

BEGIN

DECLARE CodGuasto_ int DEFAULT NULL;

INSERT INTO Guasto(ProdottoElettronico) VALUES (_ProdottoElettronico);
SET CodGuasto_ = last_insert_id(); -- Ricava il codice del guasto appena creato 

-- Mette in relazione il guasto con i propri sintomi e rimedi 
INSERT IGNORE INTO Sintomatologia VALUES (CodGuasto_, _Sintomo1), (CodGuasto_, _Sintomo2), (CodGuasto_, _Sintomo3), 
										 (CodGuasto_, _Sintomo4), (CodGuasto_, _Sintomo5), (CodGuasto_, _Sintomo6);

INSERT IGNORE INTO Risoluzione VALUES (CodGuasto_, _Rimedio1, '1'), (CodGuasto_, _Rimedio2, '1'), (CodGuasto_, _Rimedio3, '1'),
									  (CodGuasto_, _Rimedio4, '1'), (CodGuasto_, _Rimedio5, '1'), (CodGuasto_, _Rimedio6, '1');

END $$
DELIMITER ;

-- Procedura utilizzabile da un tecnico per aggiungere nuovi rimedi che possono risolvere un determinato guasto 
-- e memorizzare il numero di volte che uno stesso rimedio ha risolto quel guasto.
DROP PROCEDURE IF EXISTS GuastoRisolto;
DELIMITER $$
CREATE PROCEDURE GuastoRisolto(IN _CodGuasto int, IN _Rimedio1 int, IN _Rimedio2 int, IN _Rimedio3 int, IN _Rimedio4 int, IN _Rimedio5 int, IN _Rimedio6 int)

BEGIN

INSERT IGNORE INTO Risoluzione(Guasto, Rimedio) VALUES (_CodGuasto, _Rimedio1), (_CodGuasto, _Rimedio2), (_CodGuasto, _Rimedio3), 
													   (_CodGuasto, _Rimedio4), (_CodGuasto, _Rimedio5), (_CodGuasto, _Rimedio6);

UPDATE Risoluzione
SET NumRisolto = NumRisolto + 1
WHERE Guasto = _CodGuasto AND (Rimedio = _Rimedio1 OR Rimedio = _Rimedio2 OR Rimedio = _Rimedio3 OR
							   Rimedio = _Rimedio4 OR Rimedio = _Rimedio5 OR Rimedio = _Rimedio6);

END $$
DELIMITER ;

-- Procedura che restituisce in base ai sintomi dati in ingresso una classifica dei rimedi piu' adatti a risolvere quel determinato guasto 
DROP PROCEDURE IF EXISTS CercaRimedi;
DELIMITER $$
CREATE PROCEDURE CercaRimedi(IN _ProdottoElettronico int, IN _Sintomo1 int, IN _Sintomo2 int, IN _Sintomo3 int, IN _Sintomo4 int, IN _Sintomo5 int, IN _Sintomo6 int)

BEGIN

-- Query che restituisce i guasti che presentano i sintomi dati in ingresso e il numero di sintomi in comune
WITH GuastiSimili AS
(
	SELECT ST.Guasto, Count(*) AS SintomiInComune
	FROM Sintomatologia ST NATURAL JOIN Guasto G
	WHERE (ST.Sintomo = _Sintomo1 OR ST.Sintomo = _Sintomo2 OR ST.Sintomo = _Sintomo3 OR 
		  ST.Sintomo = _Sintomo4 OR ST.Sintomo = _Sintomo5 OR ST.Sintomo = _Sintomo6) AND G.ProdottoElettronico = _ProdottoElettronico
	GROUP BY ST.Guasto
)

-- Query che assegna ad ogni rimedio un punteggio in base a quanti sintomi in comune ha il guasto con i sintomi
-- dati in ingresso e il numero di volte che quel determinato rimedio ha portato alla risoluzione del guasto 
	SELECT RS.Rimedio, SUM(GS.SintomiInComune*RS.NumRisolto) AS Punteggio
    FROM GuastiSimili GS NATURAL JOIN Risoluzione RS
    GROUP BY RS.Rimedio
    ORDER BY Punteggio DESC;

END $$
DELIMITER ;

CALL NuovoGuasto( '1',   '2', '6', '23', NULL, NULL, NULL,   '32', '12', NULL, '18', '2', NULL);
CALL NuovoGuasto( '1',   '8', '17', '30', '4', NULL, NULL,   '2', '22', NULL, '1', '6', NULL);
CALL NuovoGuasto( '1',   '7', '17', NULL, NULL, NULL, NULL,   '15', '12', '3', '28', '40', NULL);
CALL NuovoGuasto( '1',   '22', '20', '10', '19', NULL, NULL,   '19', '34', '6', NULL, NULL, NULL);
CALL GuastoRisolto('2',  '2', '6', '15', NULL, NULL, NULL);

CALL CercaRimedi('1', '17', '4', '8', '23', NULL, NULL);

-- Analitycs 2 --


-- Procedura che stila una classifica delle sequenze piu' efficienti relative ad un determinato prodotto elettronico in base a indicatori di performance
DROP PROCEDURE IF EXISTS EfficienzaSequenze;
DELIMITER $$
CREATE PROCEDURE EfficienzaSequenze(IN _ProdottoElettronico INT)
BEGIN

	-- Media unità perse 
    WITH SequenzaProdotto AS
    (
		SELECT CodSequenza
        FROM SequenzaMontaggio
        WHERE ProdottoElettronico = _ProdottoElettronico
    ),
	LottiSeq AS
	(
	 SELECT LP.CodLotto, SP.CodSequenza
	 FROM LottoProduzione LP INNER JOIN SequenzaProdotto SP ON LP.SequenzaMontaggio = SP.CodSequenza
	),
	TotPerse AS 
    (
	 SELECT LS.CodLotto, LS.CodSequenza, Count(*) as NumPerse 
	 FROM LottiSeq LS INNER JOIN UnitaPersa UP ON LS.CodLotto = UP.Lotto
	 GROUP BY LS.CodLotto, LS.CodSequenza
	),
    MediaPerseSQ AS
    (
     SELECT TP.CodSequenza, Avg(NumPerse) as MediaPerse
	 FROM TotPerse TP
     GROUP BY TP.CodSequenza
    ),
    
    -- Operatori necessari
    NumOperatoriSQ AS
    (
     SELECT SP1.CodSequenza, Count(*) AS NumOperatori
     FROM OrganizzazioneM OM
		 INNER JOIN 
         SequenzaProdotto SP1
         ON OM.Sequenza = SP1.CodSequenza
     GROUP BY SP1.CodSequenza
     ),
    
    -- Media tempo previsto
    MadiaTempoPrevistoSQ AS
    (
     SELECT SP2.CodSequenza, AVG(LP.DurataPreventiva/L1.NumProdotti) AS MediaTempoPrevisto
     FROM SequenzaProdotto SP2
		 INNER JOIN 
         LottoProduzione LP ON SP2.CodSequenza = LP.SequenzaMontaggio
         NATURAL JOIN 
         Lotto L1 
	 GROUP BY SP2.CodSequenza
     ),
    
    -- Media tempo effettivo
    MadiaTempoEffettivoSQ AS
    (
	 SELECT SP3.CodSequenza, AVG(LP.DurataEffettiva/L2.NumProdotti) AS MediaTempoEffettivo
     FROM SequenzaProdotto SP3
		 INNER JOIN 
         LottoProduzione LP ON SP3.CodSequenza = LP.SequenzaMontaggio
         NATURAL JOIN
         Lotto L2
	 GROUP BY SP3.CodSequenza
     )
     
	
    SELECT O1.CodSequenza, ((O1.MediaPerse*3) + (O2.NumOperatori*4) + (O3.MediaTempoPrevisto*16) + ((O4.MediaTempoEffettivo - O3.MediaTempoPrevisto)*40)) AS Punteggio
    FROM MediaPerseSQ O1
		NATURAL JOIN
        NumOperatoriSQ O2 
        NATURAL JOIN
        MadiaTempoPrevistoSQ O3 
        NATURAL JOIN
        MadiaTempoEffettivoSQ O4
	ORDER BY Punteggio;
    
END $$
DELIMITER ;

 CALL EfficienzaSequenze('10'); 