/*1;1;5;Vypis aktualniho umisteni v tabulce*/
SELECT t.nazev, u.zapasy, u.vstrelene_goly, u.obdrzene_goly, u.body 
	FROM Umisteni u 
	JOIN Tymy t ON t.kod = u.kod 
ORDER BY u.body DESC
/*1;2;5;Vyp�e hr��e, kte�� maj� v�t�el�ch v�ce g�l�, ne� je pr�m�r*/
SELECT c.jmeno, c.prijimeni, c.tym, s.goly, s.asistence 
	FROM Statistiky s 
	LEFT JOIN Clenove c on c.cID = s.cID 
	WHERE goly > (SELECT AVG(goly) FROM Statistiky)
ORDER BY goly DESC
/*1;3;2;Vrac� n�zev t�mu a po�et z�pas�, odehran�ch na hostuj�c�m h�i�ti (tzv. "venku"), kdy t�m hr�l venku alespo� 2x*/
SELECT t.nazev, COUNT(r.zID) AS Pocet_zapasu_venku FROM Vysledky v 
	JOIN Rozpis r on r.zID = v.zID
		JOIN Tymy t on t.kod = r.hoste
GROUP BY t.nazev
HAVING COUNT(r.zID) > 1
/*1;4;3;Vyp�e t�my, kter� hr�ly alespo� jednou v prodlou�en�*/
SELECT t.nazev, COUNT(r.zID) AS Pocet_zapasu_prodlouzeni FROM Vysledky v 
	JOIN Rozpis r on r.zID = v.zID
		JOIN Tymy t on 
			(t.kod = r.hoste OR t.kod = r.domaci) 
			AND v.prodlouzeni = 1
	GROUP BY t.nazev
HAVING COUNT(r.zID) > 0
ORDER BY COUNT(r.zID) DESC
/*2;1;16;Vyp�e hr��e, kte�� nemaj� z�pis ve statistice*/
SELECT c.jmeno, c.prijimeni FROM Clenove c
	LEFT JOIN Statistiky s ON s.cID  = c.cID
	WHERE c.cID NOT IN (SELECT cID FROM Statistiky)
/*2;2;6;Vyp�e jm�na �to�n�k�, kte�� jsou v tabulce statistika (tedy sk�rovali nebo m�li asistenci)*/
SELECT c.cID, c.jmeno, c.prijimeni FROM Clenove c
	JOIN Statistiky s ON s.cID  = c.cID
	WHERE s.pozice LIKE '�'
/*2;3;1;Vyp�e obr�nce, kte�� bu�to nesk�rovali nebo nep�ihr�vali a jejich p��jmen� za��n� na P*/
SELECT c.jmeno, c.prijimeni, s.goly, s.asistence FROM Clenove c
	JOIN Statistiky s ON s.cID = c.cID
	WHERE s.pozice LIKE 'O' AND (s.goly = 0 OR s.asistence = 0) AND c.prijimeni LIKE 'p%'
/*2;4;2;Vyp�e z�pasy, ve kter�ch byl sou�in g�l� dom�c�ho a hostuj�c�ho t�mu alespo� 5*/
SELECT v.domaci_goly, v.hoste_goly, v.prodlouzeni FROM Vysledky v 
	WHERE v.domaci_goly * v.hoste_goly > 4

/*3;1;11;Vyp�e id hr���, kte�� jsou ve statistice pomoc� EXISTS*/
SELECT cID FROM Clenove
	WHERE EXISTS (SELECT cID FROM Statistiky WHERE Statistiky.cID = Clenove.cID)
/*3;2;11;Vyp�e id hr���, kte�� jsou ve statistice pomoc� INTERSECT*/
SELECT cID FROM Clenove
	INTERSECT
SELECT cID FROM Statistiky
/*3;3;11;Vyp�e id hr���, kte�� jsou ve statistice pomoc� IN*/
SELECT cID FROM Clenove
	WHERE cID IN (SELECT cID FROM Statistiky WHERE Statistiky.cID = Clenove.cID)
/*3;4;11;Vyp�e id hr���, kte�� jsou ve statistice pomoc� EXCEPT*/
SELECT cID FROM Clenove
EXCEPT
(SELECT cID FROM Clenove 
	EXCEPT 
	SELECT cID FROM Statistiky)
/*4;1;2;Vyp�e t�my, kter� maj� nadpr�m�rn� po�et obdr�en�ch g�l�*/
SELECT t.nazev, u.obdrzene_goly FROM Tymy t
	JOIN Umisteni u ON u.kod = t.kod
	GROUP BY t.nazev, u.obdrzene_goly
	HAVING u.obdrzene_goly > (SELECT AVG(obdrzene_goly) FROM Umisteni)
/*4;2;3;Vyp�e hr��e, kte�� maj� nadpr�m�rn� po�et trestn�ch minut*/
SELECT c.cID, c.jmeno, c.prijimeni, s.trestne_minuty, (SELECT AVG(trestne_minuty) FROM Statistiky) AS prumer FROM Clenove c
	JOIN Statistiky s ON s.cID = c.cID
	GROUP BY c.cID, c.jmeno, c.prijimeni, s.trestne_minuty
	HAVING s.trestne_minuty > (SELECT AVG(trestne_minuty) FROM Statistiky)
/*4;3;1;Vyp�e hr��e s maxim�ln�m po�tem trestn�ch minut*/
SELECT c.cID, c.jmeno, c.prijimeni, s.trestne_minuty, (SELECT MAX(trestne_minuty) FROM Statistiky) AS maximum FROM Clenove c
	JOIN Statistiky s ON s.cID = c.cID
	GROUP BY c.cID, c.jmeno, c.prijimeni, s.trestne_minuty
	HAVING s.trestne_minuty >= (SELECT MAX(trestne_minuty) FROM Statistiky)
/*4;4;5;Vyp�e hr��e, kte�� maj� sou�et g�l� a asistenc� > 4*/
SELECT c.cID, c.jmeno, c.prijimeni, SUM(goly+asistence) AS soucet_asistenci_a_golu FROM Clenove c
	JOIN Statistiky s ON s.cID = c.cID
	GROUP BY c.cID, c.jmeno, c.prijimeni
	HAVING SUM(goly+asistence) > 4
/*5;1;6;Vyp�e PS� a N�zev m�sta, kter�mu p��slu�� dan� PS�. S u�it�m JOIN*/
SELECT DISTINCT a.psc, m.mesto FROM Mesto m
	JOIN Adresa a on a.psc = m.psc
		--GROUP BY a.psc, m.mesto
/*5;2;6;Vyp�e PS� a N�zev m�sta, kter�mu p��slu�� dan� PS�. S u�it�m IN*/
SELECT m.psc, m.mesto FROM Mesto m WHERE m.psc IN (SELECT a.psc FROM Adresa a)
/*5;3;6;Zobraz� aktu�ln� odehran� z�pasy p�ehledn� s v�sledkem a eliminuje z�pasy, kter� je�t� hr�ny nebyly*/
SELECT r.zID, t.nazev, v.domaci_goly, v.hoste_goly, t1.nazev FROM Rozpis r 
LEFT JOIN Vysledky v ON v.zID = r.zID
LEFT JOIN Tymy t ON t.kod = r.domaci
LEFT JOIN Tymy t1 ON t1.kod = r.hoste
GROUP BY r.zID, t.nazev, v.domaci_goly, v.hoste_goly, t1.nazev 
HAVING SUM(CASE WHEN domaci_goly IS NULL AND hoste_goly IS NULL then 0 else 1 end)>0
/*5;4;4;Vyp�e neodehran� z�pasy.*/
SELECT r.zID, t.nazev, v.domaci_goly, v.hoste_goly, t1.nazev FROM Rozpis r 
LEFT JOIN Vysledky v ON v.zID = r.zID
LEFT JOIN Tymy t ON t.kod = r.domaci
LEFT JOIN Tymy t1 ON t1.kod = r.hoste
WHERE v.domaci_goly IS NULL AND v.hoste_goly IS NULL
GROUP BY r.zID, t.nazev, v.domaci_goly, v.hoste_goly, t1.nazev 
/*6;1;;*/

/*6;2;;*/
