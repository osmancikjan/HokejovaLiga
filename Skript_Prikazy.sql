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
	WHERE s.pozice LIKE('Ú')
/*2;3;2;Vypíše obránce, kteøí buïto neskórovali nebo nepøihrávali*/
SELECT c.jmeno, c.prijimeni, s.goly, s.asistence FROM Clenove c
	JOIN Statistiky s ON s.cID = c.cID
	WHERE s.pozice LIKE('O') AND (s.goly = 0 OR s.asistence = 0)
/*2;4;;*/