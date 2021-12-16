estpost correlate zpalter F518_SUF F200, matrix
estimates store m1
xi: reg az i.S1
est store m2

esttab m1, not unstack compress noobs nonumber nomtitles ///
		 varlabels(zpalter "(1) Alter" F518_SUF "(2) Bruttoeinkommen" F200 "(3) Wochenarbeitszeit") ///
		 eqlabels("(1) Alter" "(2) Bruttoeinkommen" "(3) Wochenarbeitszeit") ///
		 varwidth(25) ///
		 modelwidth(25)

