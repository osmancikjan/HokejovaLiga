/*1;1;5;Vypis aktualniho umisteni v tabulce*/
SELECT t.nazev, u.zapasy, u.vstrelene_goly, u.obdrzene_goly, u.body 
	FROM Umisteni u 
	JOIN Tymy t ON t.kod = u.kod 
ORDER BY u.body DESC
/*1;2;5;Vypíše hráèe, kteøí mají vštøelých více gólù, než je prùmìr*/
SELECT c.jmeno, c.prijimeni, c.tym, s.goly, s.asistence 
	FROM Statistiky s 
	LEFT JOIN Clenove c on c.cID = s.cID 
	WHERE goly > (SELECT AVG(goly) FROM Statistiky)
ORDER BY goly DESC
/*1;3;2;Vrací název týmu a poèet zápasù, odehraných na hostujícím høišti (tzv. "venku"), kdy tým hrál venku alespoò 2x*/
SELECT t.nazev, COUNT(r.zID) AS Pocet_zapasu_venku FROM Vysledky v 
	JOIN Rozpis r on r.zID = v.zID
		JOIN Tymy t on t.kod = r.hoste
GROUP BY t.nazev
HAVING COUNT(r.zID) > 1
/*1;4;3;Vypíše týmy, které hrály alespoò jednou v prodloužení*/
SELECT t.nazev, COUNT(r.zID) AS Pocet_zapasu_prodlouzeni FROM Vysledky v 
	JOIN Rozpis r on r.zID = v.zID
		JOIN Tymy t on 
			(t.kod = r.hoste OR t.kod = r.domaci) 
			AND v.prodlouzeni = 1
	GROUP BY t.nazev
HAVING COUNT(r.zID) > 0
ORDER BY COUNT(r.zID) DESC
/*2;1;16;Vypíše hráèe, kteøí nemají zápis ve statistice*/
SELECT c.jmeno, c.prijimeni FROM Clenove c
	LEFT JOIN Statistiky s ON s.cID  = c.cID
	WHERE c.cID NOT IN (SELECT cID FROM Statistiky)
/*2;2;6;Vypíše jména útoèníkù, kteøí jsou v tabulce statistika (tedy skórovali nebo mìli asistenci)*/
SELECT c.cID, c.jmeno, c.prijimeni FROM Clenove c
	JOIN Statistiky s ON s.cID  = c.cID
	WHERE s.pozice LIKE 'Ú'
/*2;3;1;Vypíše obránce, kteøí buïto neskórovali nebo nepøihrávali a jejich pøíjmení zaèíná na P*/
SELECT c.jmeno, c.prijimeni, s.goly, s.asistence FROM Clenove c
	JOIN Statistiky s ON s.cID = c.cID
	WHERE s.pozice LIKE 'O' AND (s.goly = 0 OR s.asistence = 0) AND c.prijimeni LIKE 'p%'
/*2;4;2;Vypíše zápasy, ve kterých byl souèin gólù domácího a hostujícího týmu alespoò 5*/
SELECT v.domaci_goly, v.hoste_goly, v.prodlouzeni FROM Vysledky v 
	WHERE v.domaci_goly * v.hoste_goly > 4

/*3;1;11;Vypíše id hráèù, kteøí jsou ve statistice pomocí EXISTS*/
SELECT cID FROM Clenove
	WHERE EXISTS (SELECT cID FROM Statistiky WHERE Statistiky.cID = Clenove.cID)
/*3;2;11;Vypíše id hráèù, kteøí jsou ve statistice pomocí INTERSECT*/
SELECT cID FROM Clenove
	INTERSECT
SELECT cID FROM Statistiky
/*3;3;11;Vypíše id hráèù, kteøí jsou ve statistice pomocí IN*/
SELECT cID FROM Clenove
	WHERE cID IN (SELECT cID FROM Statistiky WHERE Statistiky.cID = Clenove.cID)
/*3;4;11;Vypíše id hráèù, kteøí jsou ve statistice pomocí EXCEPT*/
SELECT cID FROM Clenove
EXCEPT
(SELECT cID FROM Clenove 
	EXCEPT 
	SELECT cID FROM Statistiky)
/*4;1;;*/

/*4;2;;*/

/*4;3;;*/

/*4;4;;*/

/*5;1;;*/
/*5;2;;*/
/*5;3;;*/
/*5;4;;*/

/*6;1;;*/
/*6;2;;*/
