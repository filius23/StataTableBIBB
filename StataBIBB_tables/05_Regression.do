* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 5: Regressionstabellen
* --------------------------------- *

do "01_init.do"
* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear

sample 10

* ------------------ *
* Ein Regressionsmodell


reg F518_SUF c.zpalter 	// einfaches Regressionsmodell
estimates store reg1 	// Ergebnisse speichern
// oder so:
eststo reg2: reg F518_SUF zpalter 	// einfaches Regressionsmodell
est dir

ereturn list			// abrufbare Informationen

// estimates Übersicht:
est dir
est restore reg1
est replay reg1
* est drop _all // alle raus


esttab reg1 // Tabelle mit Standard-Einstellungen

esttab reg1, b se(%9.3f) label // Formatierung, SE statt t + Variablen Labels

// neben b & se sind auch möglich:
 * z, se, p, ci, beta (standardisierte Koeffizienten)


esttab reg1, b se(%9.3f) stats( r2 ll F N) // Modellkennzahlen angeben (volle Liste oben bei ereturn list)


esttab reg1, b se(%9.3f) /// 
	stats(r2 r2_a N, fmt(%9.4f %9.4f %9.0fc) labels("R²" "adj. R²" "Observations")) /// N und R² labeln
	coeflabel(zpalter "Alter" _cons "Konstante")  // Koeffizienten links labeln

esttab reg1, b se(%9.3f) /// 
	stats(r2 N, fmt(%9.4f %9.0fc) labels("R²" "Observations")) ///
	coeflabel(zpalter "Alter" _cons "Konstante") ///
	mtitles("1. Modell") /// Modelltitel
	nonumbers // Zahl oben ausblenden
	
* Modelltitel, Tabellentitel und Notiz hinzufügen
esttab reg1, b se(%9.3f) /// 
	stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	coeflabel(zpalter "Alter" _cons "Konstante") ///
	mtitles("1. Modell") /// 
	nonumbers ///
	title(Tabellentitel) 	/// Titel für die Tabelle
	addnotes("erste Anmerkung" "zweite Anmerkung darunter") // Notizen ganz unten
	
* Signifikanzsterne anpassen
esttab reg1, b se(%9.3f) /// 
	stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	coeflabel(zpalter "Alter" _cons "Konstante") ///
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001 **** 0.0001)

* neben- statt untereinander
esttab reg1, b se(%9.3f) /// 
	wide /// nebeneinander stellen
	stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	coeflabel(zpalter "Alter" _cons "Konstante") ///
	title(Modelltitel) 	///
	addnotes("erste Anmerkung" "zweite Anmerkung darunter")
	
* noparentheses  oder brackets []	


* Informationen nebeneinander stellen mit cells()	
* funktioniert nicht: 
esttab reg1,b se(%9.3f) ci(%9.3f) p(%9.3f) /// 
			wide ///
			stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
			coeflabel(zpalter "Alter" _cons "Konstante") ///
			star(+ 0.10 * 0.05 ** 0.01 *** 0.001 **** 0.0001) ///
			title(Modelltitel)      ///
			addnotes("erste Anmerkung" "zweite Anmerkung darunter")
	
esttab reg1, cells("b se(fmt(%9.3f)) ci(fmt(%9.2f)) p(fmt(%9.3f))")
esttab reg1, cells("b se(fmt(%9.3f)) ci_l(fmt(%9.2f)) ci_u(fmt(%9.2f)) p(fmt(%9.3f))") // Übersichtlicher: KIs aufteilen in zwei Spalten

esttab reg1, cells("b se(fmt(%9.3f)) ci_l(fmt(%9.2f)) ci_u(fmt(%9.2f)) p(fmt(%9.3f))") ///
			collabels("B" "SE" "u.KI" "o.KI" "p")		// labels
	
	

	
* ------------------------------------------------------ *
* kategoriale UV	
reg F518_SUF i.S1
estimates store reg2

esttab reg2
	
esttab reg2,  b se(%9.3f)	///
	coeflabel(1.S1 "Maenner" 2.S1 "Frauen" _cons "Konstante")
	
	
* um Referenzkategorie zu labeln, muss die Regression mit xi erstellt werden	
xi: reg F518_SUF i.S1
estimates store reg2b

esttab reg2b,  b se(%9.3f)	///	
	coeflabel(_IS1_2 "Frauen" _cons "Konstante") 

	esttab reg2b
esttab reg2b,  b se(%9.3f)	///	
	coeflabel(_IS1_2 "Frauen" _cons "Konstante") ///
	refcat(_IS1_2 "Männer")	

esttab reg2b,  b se(%9.3f)	///	
	coeflabel(_IS1_2 "Frauen" _cons "Konstante") ///
	refcat(_IS1_2 "Männer", label("Referenzkategorie") below) ///
	modelwidth(20)
	



* ------------------------------------------------------ *
* Mehrere Regressionsmodelle
* ------------------------------------------------------ *
est dir // liste alle gespeicherten Ergebnisse
est drop _all

glo mod1 " "
glo mod2 "c.zpalter"
glo mod3 "c.zpalter##c.zpalter"
glo mod4 "c.zpalter##c.zpalter i.m1202"

forval i = 1/4 {
	xi: reg F518_SUF i.S1 ${mod`i'}
	est store regm`i'
}

est dir
esttab regm*,  b se(%9.3f)

esttab regm*,  b se(%9.3f) ///
	coeflabel(_IS1_2 "Frauen" zpalter "Alter" ///
			  c.zpalter#c.zpalter "Alter²" ///
			  _Im1202_2  "dual/schul. Abs." ///    
			  _Im1202_3  "Meister/Techniker" ///
			  _Im1202_4  "Hochschule/Uni" ///
			  _cons "Konstante") ///
	refcat(_IS1_2 "Männer" ///
		   _Im1202_2 "kein Abs.")	///
		   nomtitle ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	varwidth(20)
		   
		   
		 


* ----------------------------------------------------------------- *
* nur den interessierenden Koeffizienten behalten
esttab regm*,  b se(%9.3f) keep(_IS1_2)
esttab regm*,  b se(%9.3f) keep(_IS1_2 zpalter) // mehrere mit Leerzeichen


* wie können wir hier die Kontrollvariablen vermerken?
* -> estadd local 

glo mod1 " "
glo mod2 "c.zpalter"
glo mod3 "c.zpalter##c.zpalter"
glo mod4 "c.zpalter##c.zpalter i.m1202"

forval i = 1/4 {
	quietly xi: reg F518_SUF i.S1 ${mod`i'}
	est store regm`i'
	estadd local not11 "${mod`i'}"
}
esttab regm*,  b se(%9.3f) keep(_IS1_2) scalars("not11 Kontrollvariablen")

esttab regm*,  b se(%9.3f) keep(_IS1_2) scalars("not11 Kontrollvariablen") ///
	modelwidth(25) ///
	coeflabel(_IS1_2 "Frauen") ///
	refcat(_IS1_2 "Männer")

	
forval i = 1/4 {
	quietly xi: reg F518_SUF i.S1 ${mod`i'}
	est store regm`i'
	
	loc note "${mod`i'}"
	loc note = ustrregexra("`note'","^\s", "-") // ^\s = "am Anfang Leerzeichen"
	loc note = ustrregexra("`note'","c.zpalter##c.zpalter", "Alter & Alter^2") 
	loc note = ustrregexra("`note'","c.zpalter", "Alter")
	loc note = ustrregexra("`note'"," i.m1202", ", Ausbildung")
	estadd local note "`note'"
}
esttab regm*,  b se(%9.3f) keep(_IS1_2) scalars("note Kontrollvariablen")

esttab regm*,  b se(%9.3f) keep(_IS1_2) scalars("note Kontrollvariablen") ///
	modelwidth(25) ///
	varwidth(17) ///
	coeflabel(_IS1_2 "Frauen") ///
	refcat(_IS1_2 "Männer") ///
	nomtitle 

* ------------------------------------------------------ * 
* mehrere Modellgruppen

forvalues s = 1/2 {
		
	quietly  xi: reg F518_SUF c.zpalter##c.zpalter if S1 == `s'
	est store reg_`s'_1
	estadd local note "Alter & Alter^2"
	
	quietly xi:  reg F518_SUF c.zpalter##c.zpalter i.m1202  if S1 == `s'
	est store reg_`s'_2
	estadd local note "Alter & Alter^2, Ausbildung"
}

est dir

esttab reg_*, r2 

esttab reg_*, r2 ///
	 mgroups("Männer" "Frauen", pattern(1 0 1 0))
	 
esttab reg_*, r2 ///
	 mgroups("" "Männer" "Frauen", pattern(1 1 0 1 ))	 

	 
esttab reg_*, b se(%9.3f)  ///
		nomtitle ///
	 	coeflabel(_IS1_2 "Frauen" zpalter "Alter" ///
			  c.zpalter#c.zpalter "Alter²" ///
			  _Im1202_2  "dual/schul. Abs." ///    
			  _Im1202_3  "Meister/Techniker" ///
			  _Im1202_4  "Hochschule/Uni" ///
			  _cons "Konstante") ///
		stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	refcat(_IS1_2 "Männer" ///
		   _Im1202_2 "kein Abs.") ///
	 mgroups("Männer" "Frauen", pattern(1 0 1 0))
	 
* ------------------------------------------------------ * 
* volle Formatierung
	 
esttab reg_* , ///
		b se(%9.3f)  ///
		nomtitle ///
	 	coeflabel(_IS1_2 "Frauen" zpalter "Alter" ///
			  c.zpalter#c.zpalter "Alter²" ///
			  _Im1202_2  "dual/schul. Abs." ///    
			  _Im1202_3  "Meister/Techniker" ///
			  _Im1202_4  "Hochschule/Uni" ///
			  _cons "Konstante") ///
		stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	refcat(_IS1_2 "Männer" ///
		   _Im1202_2 "kein Abs.") ///
	 mgroups("Männer" "Frauen", pattern(1 0 1 0))
	 
	 
* 	 latex
esttab reg_* using "${tex}/regtab4.tex", ///
		b se(%9.3f)  ///
		nomtitle ///
	 	coeflabel(_IS1_2 "Frauen" zpalter "Alter" ///
			  c.zpalter#c.zpalter "Alter²" ///
			  _Im1202_2  "dual/schul. Abs." ///    
			  _Im1202_3  "Meister/Techniker" ///
			  _Im1202_4  "Hochschule/Uni" ///
			  _cons "Konstante") ///
		stats(r2 N, fmt(%9.3f %9.0g) labels(R² Observations)) ///
	refcat(_IS1_2 "Männer" ///
		   _Im1202_2 "kein Abs.") ///
	 mgroups("Männer" "Frauen", pattern(1 0 1 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) booktabs replace
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
 