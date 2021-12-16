* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 2: tabstat
* Lösung
* --------------------------------- *

* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear


* --------------------------------- *
* 1 Erstellen Sie eine Überblickstabelle für `F200` mit Min, Mean, SD, 1. Quartil (`p25`), Median, 3. Quartil (`p75`) und der Anzahl der Beobachtungen.

tabstat F200, c(stat) stat(min mean sd max p25 p75 n) 
estpost tabstat F200, c(stat) stat(min mean sd max p25 p75 n) 

esttab, ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.0fc)) max(fmt(%13.0fc)) count(fmt(%6.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F200 "Wochenarbeitszeit")

esttab using "tabelle2.rtf", ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.0fc)) max(fmt(%13.0fc)) count(fmt(%6.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F200 "Wochenarbeitszeit")	///
	replace
	
* --------------------------------- *
* 2 Ergänzen Sie die Tabelle von Übung 1 `F200` um `fastgini` - so kommen Sie an die abgelegte Info

ssc install fastgini // falls nicht schon installiert

tabstat F200, c(stat) stat(mean sd min max n)
estpost tabstat F200, c(stat) stat(mean sd min max n)


fastgini F200
return list
// matrix Befehle
mat gini = r(gini)
mat l gini
mat colname gini = F200
mat list gini

estpost tabstat F200, c(stat) stat(mean sd min max n)
estadd mat gini

esttab, cells("mean sd min max count gini")

esttab, 	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.0fc)) max(fmt(%13.0fc)) count(fmt(%6.0fc)) gini(fmt(%6.4fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N" "Gini") ///
	coeflabel(F200 "Wochenarbeitszeit")



* --------------------------------- *
* 3 Verändern Sie die oben gezeigte Schleife so, dass nicht mehr die *Anzahl*, sondern der *Anteil* der Missings eingefügt wird.
mdesc F518_SUF
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
		loc res_mat = r(percent)
		mat m1[1,`y'] = `res_mat'
	}
	mat l m1
	
estpost tabstat zpalter F518_SUF, c(stat) stat(mean sd min max n)
estadd mat m1
esttab, cells("count(fmt(%13.0fc)) m1(fmt(%13.2fc))")  noobs ///
		nomtitle nonumber label collabels("N" "Missings (%)") ///
		coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter")
		



* --------------------------------- *
* 4 
* Erweitern Sie den Gruppenvergleich um die Variablen `az` (Wochenarbeitszeit) und `F1104` (Jahr des Schulabschlusses)
estpost tabstat zpalter F518_SUF az F1104, by(S1) c(stat) stat(mean sd)
estpost tabstat zpalter F518_SUF az F1104, by(S1) c(stat) stat(mean sd) nototal	


esttab, cells(mean(fmt(%10.1fc)) sd(fmt(%13.3fc) par)) nostar  nonumber unstack ///
  nomtitle nonote noobs  ///
   collabels(none)    ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter" az "Wochenarbeitszeit" F1104 "Jahr des Schulabschlusses")

 
* Wo könnten Sie die Nachkommastellen verändern? Verändern Sie die Anzeige für die Mittelwerte auf 3 Nachkommastellen
esttab, cells("mean(fmt(%10.3fc)) sd(fmt(%13.3fc) par)") nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles ///
   coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter" az "Wochenarbeitszeit" F1104 "Jahr des Schulabschlusses")


* Lassen Sie sich in auch den Median ausgeben. Legen Sie dafür 0 Nachkommastellen als Format fest. Denken Sie daran, `estpost` neu zu konfigurieren.
estpost tabstat zpalter F518_SUF az F1104, by(S1) c(stat) stat(mean sd p50) nototal
esttab, cells(mean(fmt(%10.3fc)) p50(fmt(%10.0fc)) sd(fmt(%13.3fc) par)) nostar  nonumber unstack ///
   collabels(none) ///
  nomtitle nonote noobs label  ///
   eqlabels("Männer" "Frauen") /// 
    coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter" az "Wochenarbeitszeit" F1104 "Jahr des Schulabschlusses")



* Passen Sie die Syntax in `cells()` an, um die Werte neben- oder untereinander angezeigt zu bekommen.
esttab, cells("mean(fmt(%10.3fc)) sd(fmt(%13.3fc) par)") nostar  nonumber unstack ///
   collabels("Mean" "SD" "Mean" "SD") ///
  nomtitle nonote noobs label  ///
   eqlabels("Männer" "Frauen") /// 
    coeflabel(F518_SUF "Bruttoverdienst" zpalter "Alter" az "Wochenarbeitszeit" F1104 "Jahr des Schulabschlusses")
	