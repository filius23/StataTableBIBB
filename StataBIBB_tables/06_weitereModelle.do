* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 6: andere Modelle
* --------------------------------- *

do "01_init.do"
* einlesen 
use "${data}/BIBBBAuA_2018_suf1.0_clean.dta", clear

* ------------------ *
* logit


logit nt i.S1 
est store logm1
esttab logm1, b se(%9.3f) 
esttab logm1, b se(%9.3f) eform // eform für Odds Ratios

logit nt i.S1  if !missing(zpalter)
est store logm1b
logit nt i.S1 zpalter 
est store logm2
estadd lrtest logm1b
esttab logm?, b se(%9.3f) scalars("lrtest_chi2  LRTest Chi²" lrtest_df lrtest_p) 


esttab logm?, b se(%9.3f) scalars("lrtest_chi2  LRTest Chi²" lrtest_df lrtest_p)   pr2 aic bic


* ------------------ *
* margins

est restore logm2
margins, dydx(*)
esttab logm?, b se(%9.3f) //?

margins, dydx(*) post
est store mar_mod2
esttab mar_mod2, cells("b(fmt(a3)) se(fmt(a3)) ci_l(fmt(a3)) ci_u(fmt(a3)) p(fmt(a3))") nonumbers 

est restore logm2
margins, at(zpalter = (18 20(5)65) ) post
est store pred_mod2
esttab pred_mod2, cells("b(fmt(a3)) se(fmt(a3)) ci_l(fmt(a3)) ci_u(fmt(a3)) p(fmt(a3))") nonumbers 


* ------------------ *
* mixed
xtmixed F518_SUF i.S1 ||Bula:
est store mmodel
*ereturn list
*estadd mat e(N_g)
esttab mmodel 
esttab mmodel ,	transform(ln*: exp(@) exp(@))  ///
     eqlabels("" "sd(week)" "sd(_cons)" "sd(Residual)", none) 
	 
* ICC
xtmixed F518_SUF i.S1 ||Bula:
estat icc
estadd scalar icc2 = r(icc2) // Use 'return list' to check for other scalars from 'estaticc' you might want
esttab, se wide transform(ln*: exp(@) exp(@)) ///
    varwidth(13) scalars(icc2)	 
	 