* ado installieren 
ssc install gtools
ssc install estout, replace
which estout // check versions
which esttab

* ------------------ *
* Datenimport 
* ------------------ *
cd "D:\Datenspeicher\BIBB_BAuA" // wo liegt der Datensatz?
use "BIBBBAuA_2018_suf1.0.dta", clear
mvdecode zpalter, mv(9999)
mvdecode F518_SUF, mv( 99998/ 99999)


tabstat zpalter F518_SUF, c(var) stat(mean sd min max n) // wie orientiert?

tabstat zpalter F518_SUF, c(stat) stat(mean sd min max n)
ereturn list

est dir 
est clear  // clear the est locals
estpost tabstat new_cases new_deaths new_tests new_vaccinations, c(stat) stat(sum mean sd min max n)
help estpost




esttab, ///
 cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber ///
  nomtitle nonote noobs label collabels("Sum" "Mean" "SD" "Min" "Max" "N")