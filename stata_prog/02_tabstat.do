* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 2: tabstat/su
* --------------------------------- *


* Pfade setzen
if ("`c(username)'" == "Filser") {

glo pfad 		"D:\oCloud\Home-Cloud\Lehre\BIBB\StataBIBB3"		// projekt

}
glo data		"${pfad}/data"		// wo liegen die original Datensätze?
glo word		"${pfad}/word"		// Word-Ordner
glo tex 		"${pfad}/tex"		// tex-Ordner
glo prog		"${pfad}/prog"		// wo liegen die doFiles?



* einlesen 
use "${data}/BIBBBAuA_2018_short.dta", clear

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

// formatierung - ohne Median, übersichtlicher
esttab, ///
	cells("mean p50 sd min max count") ///
	nonumber nomtitle noobs label 

esttab, ///
	cells("mean sd min max count") ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")
		
esttab, ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.0fc)) max(fmt(%13.0fc)) count(fmt(%6.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")

	
/// format erklären
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

estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
mdesc F518_SUF
return list

// matrix Befehle
mat l r(miss) // :-( Fehler, da Skalar
mat miss = r(miss)
mat l miss
mat colname miss = F518_SUF
mat list miss
estadd mat miss

esttab, cells("mean sd min max count miss")

esttab, cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N" "Missings") ///
		coeflabel(F518_SUF "Bruttoverdienst") 

		
		
esttab  using "${tex}/desc_miss.tex", ///
		cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N" "Missings")  ///
		booktabs replace

		

fastgini F518_SUF
return list

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
estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd)
estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd) nototal	



esttab, cells(mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)) nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")

 // um cells() in eine Zeile zu bringen -> ""  
esttab, cells("mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)") nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")   
   
esttab using "${word}/Gruppenvergleich.rtf", cells(mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)) nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")
		 
 
 
estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd p50)
estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd p50) nototal	
// labcol2("lc2", title("t2")) 


esttab, cells(mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par) p50(fmt(%13.0fc))) nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")