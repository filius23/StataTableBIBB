* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 5: Regressionstabellen
* --------------------------------- *
clear all
mac list
set trace off
clear matrix
estimates clear
set linesize 250

* Pfade setzen
if ("`c(username)'" == "Filser") {

glo pfad 		"D:\oCloud\Home-Cloud\Lehre\BIBB\StataBIBB3"		// projekt

}
glo data		"${pfad}/data"		// wo liegen die Datensätze?
glo word		"${pfad}/word"		// Word-Ordner
glo tex 		"${pfad}/tex"		// tex-Ordner
glo prog		"${pfad}/prog"		// wo liegen die doFiles?


* einlesen 
use "${data}/BIBBBAuA_2018_short.dta", clear

* ------------------ *
* regression
reg F518_SUF c.zpalter
ereturn list

est store reg1
esttab reg1 , r2 

esttab reg1 , b se(%9.3f) r2 label 
esttab reg1, r2 stats(ll r2 cmdline)



estadd local note "Mod1"

esttab reg1 , r2 
esttab reg1 , r2 label
esttab reg1 , r2 coeflabel(F200 "Arbeitz")
/*//
	cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber ///
	nomtitle nonote noobs label collabels("Sum" "Mean" "SD" "Min" "Max" "N") ///
	replace
  */ 	
  
  
  ##c.zpalter i.m1202 
  
reg F518_SUF c.zpalter##c.zpalter i.m1202  F200 
est store reg2
estadd local note "Mod2"
esttab reg2, r2 scalar(note) stats(ll r2 cmdline)


esttab reg1 reg2, r2 scalar(note) stats(ll r2)

esttab reg1 reg2, r2 scalar(note) stats(N r2) se nonumber  ///
	noabbrev label ///
	coeflabel(zpalter "Alter" c.zpalter#c.zpalter "Alter²" 1.m1202 "ohne Berufsausb." 2.m1202 "duale/schulische Berufsausb." 3.m1202 "Aufstiegsfortb." 4.m1202 "Uni/FH" F200 "Arbeitszeit/Woche" _cons "Konstante") ///
	mgroups("monatl. Einkommen" "", pattern(0 1) prefix(\multicolumn{2}{c}{) suffix(}) span erepeat(\cmidrule(lr){2-3})) ///
	mtitles("Modell 1" "Modell 2")

//	varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs."))
// varwidth(25)


esttab reg1 reg2 using "${tab_dir}/regtab.rtf", r2 scalar(note) stats(ll r2 cmdline)



esttab reg1 reg2 using "${tab_dir}/regtab.tex", replace r2 scalar(note) se nonumber  ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R-squared Observations)) ///
	noabbrev label booktabs ///
	coeflabel(zpalter "Alter" c.zpalter#c.zpalter "Alter²" 1.m1202 "ohne Berufsausb." 2.m1202 "duale/schulische Berufsausb." 3.m1202 "Aufstiegsfortb." 4.m1202 "Uni/FH" F200 "Arbeitszeit/Woche" _cons "Konstante") ///
	mtitles("Modell 1" "Modell 2") ///
	addnote("Source: ETB 2028 SUF Version 1")
	
	///
	mgroups("monatl. Einkommen" "", pattern(0 1 0) prefix(\multicolumn{2}{c}{) suffix(}) span erepeat(\cmidrule(lr){2-3})) 

	
esttab reg1 reg2 using "${tab_dir}/regtab.rtf", replace r2 scalar(note) se nonumber  ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R-squared Observations)) ///
	noabbrev label  ///
	coeflabel(zpalter "Alter" c.zpalter#c.zpalter "Alter²" 1.m1202 "ohne Berufsausb." 2.m1202 "duale/schulische Berufsausb." 3.m1202 "Aufstiegsfortb." 4.m1202 "Uni/FH" F200 "Arbeitszeit/Woche" _cons "Konstante") ///
	mtitles("Modell 1" "Modell 2") ///
	addnote("Source: ETB 2028 SUF Version 1")
		

		keep(1L10.policy#c.date)
		  estadd local RFE  "Yes"
