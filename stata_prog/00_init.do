* Master DoFile
cap log close
clear all
mac list
set trace off
clear matrix
clear mata

set more off,perm
set scrollbufsize 500000
set maxvar 32000, perm
set matsize 11000, perm
set linesize 250
set varabbrev off
prog drop _allado

estimates clear

* ------------------------------ *
* Pfade setzen
if ("`c(username)'" == "Filser") {
	glo pfad 		"D:\oCloud\Home-Cloud\Lehre\BIBB\StataBIBB3"		// Projekt/Kursordner
}
glo data		"${pfad}/data"		// wo liegen die Datensätze?
glo word		"${pfad}/word"		// Word-Ordner
glo tex 		"${pfad}/tex"		// tex-Ordner
glo prog		"${pfad}/prog"		// wo liegen die doFiles?


* ----------------------------- *
*  Ordner erstellen wenn nicht bereits vorhanden
foreach dir1 in data word tex prog {
	capture cd 	"${`dir1'}"
	if _rc!=0  {
		mkdir ${`dir1'}
		display "${`dir1'} erstellt"
	} 
 }

cd "${pfad}"


* ------------------ *
* clean data: label kürzen & missings raus

use "${data}/BIBBBAuA_2018_suf1.0.dta", clear
foreach i of varlist * {
	local longlabel: var label `i'
	local shortlabel = substr("`longlabel'",1,15)
	label var `i' "`shortlabel'"
}
mvdecode zpalter F1104, mv(9999)
mvdecode F518_SUF, mv( 99998/ 99999)
mvdecode F200 F1408, mv( 97/99)
mvdecode m1202, mv(-1)
mvdecode Mig, mv(-4)
gen mig01 = Mig != 0 if !missing(Mig)

save "${data}/BIBBBAuA_2018_suf1.0_clean.dta", replace 
