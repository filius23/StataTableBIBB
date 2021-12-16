* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 4: Korrelationsmatrix
* Lösungen'
* --------------------------------- *

do "01_init.do"
* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear

* --------------------------------------- *
* 1 Erstellen Sie eine Korrelationstabelle für  `zpalter` `F518_SUF` `F200` und `F1410_01`


estpost correlate zpalter F518_SUF F200 F1410_01, matrix

esttab ., not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit" F1410_01 "(4) Jahre berufst. in D") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit" "(4) Jahre berufst. in D") ///
		 varwidth(30) ///
		 modelwidth(30)


* --------------------------------------- *
* 2 Erstellen Sie eine t-Testtabelle für Gruppenunterschiede zwischen Menschen mit und ohne Migrationshintergrund für die Variablen `az` und `F518_SUF`. Die Variablen zum Migrationshintergrund können Sie so erstellen: 


gen mig01 = Mig != 0

estpost ttest az F518_SUF, by(mig01) unequal
esttab, wide nonumber noobs
esttab,  cell("b(fmt(%8.3fc)) t(fmt(%8.3fc) star) N_1(fmt(%8.0fc)) mu_1(fmt(%8.3fc)) N_2(fmt(%8.0fc)) mu_2") /// 
	unstack wide nonumber noobs nomtitles ///
	collabels("Diff" "t" "N(k. mig.)" "Mean(k. mig.)" "N(mig.)" "Mean(mig.)")	///
	modelwidth(15)