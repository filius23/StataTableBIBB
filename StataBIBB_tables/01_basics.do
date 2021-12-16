* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 1: Grundlagen und Hintergründe
* --------------------------------- *

* ---------------- 
* ados installieren
* ssc install estout, replace
which estout // check versions
which esttab // check version

* statt installieren hier adopath setzen:
adopath ++ "pfad/zu/adofiles"

* ---------------- 
* e() und r()

use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear
reg F518_SUF zpalter
ereturn list
return list
matrix list e(b)


su F518_SUF
ereturn list
return list
