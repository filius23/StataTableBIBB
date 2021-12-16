* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 2: tabstat/su
* --------------------------------- *


* Pfade setzen -> 
do "01_init.do"

* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear

su F518_SUF

* ------------------ *
* tabstat
tabstat F518_SUF, c(var) stat(mean sd min max n) // wie orientiert?
tabstat F518_SUF, c(stat) stat(mean sd min max n)
ereturn list

estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
esttab, cells("mean sd min max count")


// Median hinzufügen braucht neues estpost:
esttab, cells("mean p50 sd min max count")

// mit p50 für Median
estpost tabstat F518_SUF, c(stat) stat(mean p50 sd min max n)
esttab, cells("mean p50 sd min max count")

// formatierung - übersichtlicher
esttab, ///
	cells("mean p50 sd min max count") ///
	nonumber nomtitle noobs label 

esttab, ///
	cells("mean sd min max count") ///
	nonumber nomtitle nonote noobs ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst") ///
	varwidth(20)
		
esttab, ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.0fc)) max(fmt(%13.0fc)) count(fmt(%6.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")

	
/// format 
	help format
	dis strlen("10789.1234")
	display %10.2f 	10789.1234 // 0 Nachkommastellen
	display %10.0f 	10789.1234 // 2 Nachkommastellen
	display %11.5f 	10789.1234 // 0 hinzugefügt!
* mit fc werden Tausendertrenner eingefügt
	display %10.2fc 	10789.1234
	display %10,2fc 	10789.1234 // , und . tauschen -> "dt Format"
	
	
* export -------	
esttab using "${word}/tab1.rtf", ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%4.0fc)) max(fmt(%4.0fc)) count(fmt(%4.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst") ///
	replace
   
esttab using "${tex}/tab1.tex", ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%4.0fc)) max(fmt(%4.0fc)) count(fmt(%4.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")  ///
	replace booktabs
	

	
* eigene Infos hinzufügen -----------------
tabstat F518_SUF, c(stat) stat(mean sd min max n)


estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
mdesc F518_SUF
return list

// matrix Befehle
mat l r(miss) // :-( Fehler, da Skalar
mat miss = r(miss) // matrix mit name miss erstellen
mat l miss
mat colname miss = F518_SUF  // spalte umbenennen
mat list miss

estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
estadd mat miss

esttab, cells("mean sd min max count miss")

esttab, cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N" "Missings") ///
		coeflabel(F518_SUF "Bruttoverdienst") 

	
esttab  using "${tex}/desc_miss.tex", ///
		cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N" "Missings")  ///
		booktabs replace

		
* gini & mdesc hinzufügen
fastgini F518_SUF
return list
mat g2 = r(gini) // matrix mit name g2 erstellen
mat l g2
mat colname g2 = F518_SUF
mat list g2

mdesc F518_SUF
return list
mat miss = r(miss) // matrix mit name miss erstellen
mat l miss
mat colname miss = F518_SUF
mat list miss


estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
estadd mat miss
estadd mat g2

esttab, cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc)) g2(fmt(%13.4fc))") ///
			noobs 	nomtitle nonumber ///
			collabels("Mean" "SD" "Min" "Max" "N" "Missings" "Gini") ///
			coeflabel(F518_SUF "Bruttoverdienst") 


* ------------------------------------------ *
* was passiert wenn wir matrix nicht umbenennen?
		
mdesc F518_SUF
mat miss = r(miss) // matrix mit name miss erstellen
mat l miss
* mat colname miss = F518_SUF  // spalte umbenennen
mat list miss

estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
estadd mat miss

esttab, cells("mean sd min max count miss")




* ------------------------------------------ *
* mehrere Variablen 
estpost tabstat zpalter F518_SUF, c(stat) stat(mean sd min max n)
esttab, cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N") ///
		coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter") 




* ------------------------------------------ *
* kennzahlen bei mehreren Variablen einfügen

mdesc zpalter F518_SUF
return list // nur letzer Wert abrufbar

* Hilfs-Schleife
	glo x = "zpalter F518_SUF" // auszuwertende Variablen
	glo len: word count ${x} 	// wie viele sind es?
	mat m1 = J(1,${len},.)	   // entsprechend lange Matrix erstellen
	mat colname m1 = ${x}		// spalten schon mal richtig benennen
	mat list m1					// ansehen

	forval y = 1/$len {
		loc v: dis	word("${x}",`y') // y.tes Wort aus x in v ablegen
		display "`v'"				// zur Kontrolle: v anzeigen
		mdesc `v'					// missings in v berechnen
		loc res_mat = r(miss)
		mat m1[1,`y'] = `res_mat'
	}
	mat l m1
	
estpost tabstat zpalter F518_SUF, c(stat) stat(mean sd min max n)
estadd mat m1
esttab, cells("count(fmt(%13.0fc)) m1(fmt(%13.0fc))")  noobs ///
		nomtitle nonumber label collabels("N" "Missings") ///
		coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")
		
		
		
* -------------------------------------------- *
* Gruppenvergleich	
tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd)

estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd)
estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd) nototal	

esttab, cells(mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)) nostar  nonumber unstack ///
  nomtitle nonote noobs  ///
   collabels(none)  ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")

 // um cells() in eine Zeile zu bringen -> ""  
esttab, cells("mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)") nostar  nonumber unstack ///
  nomtitle nonote noobs  ///
  collabels("Mean" "SD" "Mean" "SD") ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")   
     
   
*export zu rtf
esttab using "${word}/Gruppenvergleich.rtf", cells(mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)) nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")
		 
 