
gen mig02 = mig01 + 1
				  *c.zpalter##i.mig02
 xi: reg F518_SUF  c.zpalter i.mig02 c.zpalter#i.mig02
 est store m1
 esttab m1,  b se(%9.3f) ///
	modelwidth(25) ///
	varwidth(17) ///
	coeflabel(_IS1_2 "Frauen") ///
	refcat( 1.mig01 "kein Mig.hintergrund") ///
	nomtitle 
