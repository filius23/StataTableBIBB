* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 4: Korrelationsmatrix & t-Test
* --------------------------------- *

* Pfade setzen -> 
do "01_init.do"

* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear

* ------------------ *
* correlate
correlate zpalter F518_SUF F200 
 
estpost correlate zpalter F518_SUF F200, matrix


esttab ., not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(30) ///
		 modelwidth(30)
 
 
 
esttab  using "${word}/corrmat.rtf", not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(30) ///
		 replace
		 
		 
esttab  using "${tex}/corrmat.tex", not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(30) ///
		 replace booktabs

		 
* --------------------------------------- *
** für Spearman's Rho:
foreach v of varlist zpalter F518_SUF F200 {
	egen rnk_`v' = rank (`v'), unique
}

estpost correlate rnk_zpalter rnk_F518_SUF rnk_F200, matrix


esttab ., not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(30) ///
		 title("Dies ist der Spearman-Rangkorrelationskoeffizient")

esttab  using "${word}/corrmat2.rtf", not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(30) ///
		 replace ///
		 title("Dies ist der Spearman-Rangkorrelationskoeffizient")
		 

esttab  using "${tex}/corrmat2.tex", not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(30) ///
		 replace booktabs ///
		 title("Dies ist der Spearman-Rangkorrelationskoeffizient")
		 
		 
		 
* ------------------------------------------------------------------------ *
* t-test

ttest az, by(S1) unequal

estpost ttest az F518_SUF, by(S1) unequal
esttab, wide nonumber noobs
esttab,  cell("b(fmt(%8.3fc)) t(fmt(%8.3fc) star) N_1(fmt(%8.0fc)) mu_1(fmt(%8.3fc)) N_2(fmt(%8.0fc)) mu_2") /// 
	unstack wide nonumber noobs nomtitles ///
	collabels("Diff" "t" "N(M)" "Mean(M)" "N(W)" "Mean(W)")		 
		 
		 