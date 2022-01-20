* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 5: Regressionstabellen
* Lösungen
* --------------------------------- *

do "01_init.do"
* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear




* --------------------------------------- *
* 1 Erstellen Sie ein bivariates Regressionsmodell mit `F518_SUF` als abhängiger und `az` als unabhängiger Variable.

reg F518_SUF az
est store m1

* Speichern Sie die Ergebnisse mit `estimates store` und erstellen Sie eine Tabelle mit `esttab`
esttab m1
* Wie können Sie die Standardfehler statt der t-Werte anzeigen lassen?
esttab m1, b se(%9.3f) 
* Lassen Sie sich auch das R² und die Fallzahl ausgeben.
esttab m1, b se(%9.3f) stats(N  r2 ) 

* Labeln Sie die Variablen links in der Tabelle.

esttab m1, b se(%9.3f) /// 
	stats(r2 N, fmt(%9.4f %9.0fc) labels("R²" "Observations")) ///
	coeflabel(az "Wochenarbeitszeit" _cons "Konstante") ///
	mtitles("1. Modell") /// Modelltitel
	nonumbers // Zahl oben ausblenden
	
	
* Verändern Sie das Signifikanzniveau
esttab m1, b se(%9.3f) /// 
	stats(r2 N, fmt(%9.4f %9.0fc) labels("R²" "Observations")) ///
	coeflabel(az "Wochenarbeitszeit" _cons "Konstante") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001 **** 0.0001) ///
	nonumbers // Zahl oben ausblenden
	

* Lassen Sie sich die Werte für die Variable und die Konstante neben- statt untereinander anzeigen.
esttab m1, cells("b se(fmt(%9.3f)) ci_l(fmt(%9.2f)) ci_u(fmt(%9.2f))  t(fmt(%9.3f)) p(fmt(%9.3f))") ///
			collabels("B" "SE" "u.KI" "o.KI" "t" "p")		// labels



* --------------------------------------- *
* 2 + Erstellen Sie ein bivariates Regressionsmodell mit `F518_SUF` als abhängiger und `mig` als unabhängiger Variable.
reg F518_SUF i.mig01

* erstellen Sie das Modell mit Hilfe von `xi` so, dass Sie die Referenzkategorie beschriften können.
xi: reg F518_SUF i.mig01
est store m2

* FÜgen Sie die Beschriftung für die Referenzkategorie ein.

esttab m2,  b se(%9.3f)	///	
	coeflabel(_Imig01_1 "Migrationshintergrund" _cons "Konstante") ///
	refcat(_Imig01_1 "kein Migrationshintergrund")	///
	varwidth(30) ///
	stats(r2 N, fmt(%9.4f %9.0fc) labels("R²" "Observations")) ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001 **** 0.0001) ///
	nonumbers // Zahl oben ausblenden

	
xi: reg F518_SUF i.m1202
est store m3
esttab m3,  b se(%9.3f)	///	
	coeflabel(_Im1202_2 "duale aus" _cons "Konstante") ///
	refcat(_Im1202_2 "keine Aus.")	///
	varwidth(30) ///
	stats(r2 N, fmt(%9.4f %9.0fc) labels("R²" "Observations")) ///
	nonumbers // Zahl oben ausblenden

tab m1202
* --------------------------------------- *
* 3 Erstellen Sie ein Regressionsmodell, welches schrittweise mehrere Variablen aufnimmt:

est dir // liste alle gespeicherten Ergebnisse
estimates clear

glo mod1 " "
glo mod2 "c.zpalter"
glo mod3 "c.zpalter##c.zpalter"
glo mod4 "c.zpalter##c.zpalter i.m1202"

forval i = 1/4 {
	xi: reg az i.S1 ${mod`i'}
	est store regmx`i'
}

est dir
esttab regmx*,  b se(%9.3f)

* Stellen Sie die Ergebnisse in einer Tabelle nebeneinander dar.

* Labeln Sie Variablen und wie oben gezeigt und verändern Sie die labels 

esttab regmx*,  b se(%9.3f) ///
	coeflabel(_IS1_2 "Frauen" zpalter "Alter" ///
			  c.zpalter#c.zpalter "Alter²" ///
			  _Im1202_2  "duale oder schul. Ausb." ///    
			  _Im1202_3  "Meister oder Techniker" ///
			  _Im1202_4  "Hochschule/Uni" ///
			  _cons "Konstante") ///
	refcat(_IS1_2 "Männer" ///
		   _Im1202_2 "kein Ausb.")	///
		   nomtitle ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	varwidth(30)
		   

* --------------------------------------- *
* 4
*  Verwenden Sie die Modellserie von gerade eben (Übung 3), behalten Sie aber den Koeffizienten für das Geschlecht in ihrer Tabelle.
*  Wie müssen Sie die Schleife für die Modellserie aus Übung 3 anpassen, um die Kontrollvariablen in einer Zeile unten einzufügen?

est drop _all 

glo mod1 " "
glo mod2 "c.zpalter"
glo mod3 "c.zpalter##c.zpalter"
glo mod4 "c.zpalter##c.zpalter i.m1202"


forval i = 1/4 {
	xi: reg az i.S1 ${mod`i'}
	est store regmx`i'
	estadd local no11 "${mod`i'}"
}

eststo m4: mixed az i.S1 ${mod4} ||Bula:

esttab regm* m4,  b se(%9.3f) keep(_IS1_2) scalars("no11 Kontrollvariablen") ///
	modelwidth(25) ///
	stats(N r2 model) ///
	coeflabel(_IS1_2 "Frauen") ///
	refcat(_IS1_2 "Männer")

	
	
* --------------------------------------- *
* 5 Schätzen Sie getrennte Modelle für `mig01=0` und `mig01=1` mit den Kontrollvariablen aus Übung 3. Passen Sie also die Schleife von [oben](#mgroups) an, sodass jeweils zwei Modelle für die Gruppen  `mig01=0` und `mig01=1` geschätzt werden:


forvalues m = 0/1 {
        
    xi: reg F518_SUF c.zpalter##c.zpalter if mig01 == `m'
    est store reg_`s'_1
    estadd local note "Alter & Alter^2"
    
    xi: reg F518_SUF c.zpalter##c.zpalter i.m1202  if mig01 == `m'
    est store reg_`s'_2
    estadd local note "Alter & Alter^2, Ausbildung"
}
esttab reg_*


* Fügen Sie jetzt Gruppenlabels ein und labeln Sie die Tabelle entsprechend der kennengelernten Optionen.

esttab reg_*, r2 ///
	 mgroups("" "ohne Mig." "mit Mig.", pattern(1 1 0 1 ))	 ///
	 		b se(%9.3f)  ///
		nomtitle ///
	 	coeflabel(_IS1_2 "Frauen" zpalter "Alter" ///
			  c.zpalter#c.zpalter "Alter²" ///
			  _Im1202_2  "dual/schul. Abs." ///    
			  _Im1202_3  "Meister/Techniker" ///
			  _Im1202_4  "Hochschule/Uni" ///
			  _cons "Konstante") ///
		stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	refcat(_Im1202_2 "kein Abs.") ///
		   varwidth(20)

	 
	 