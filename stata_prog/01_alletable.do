* ado installieren 
ssc install gtools
ssc install estout, replace
net install "http://www.stata.com/users/kcrow/tab2docx"
which estout // check versions
which esttab

 
	// updates mit 
	adoupdate estout
	adoupdate gtools
* ------------------ *
* Datenimport 
* ------------------ *
clear all
cd "D:\Datenspeicher\BIBB_BAuA" // wo liegt der Datensatz?
use "BIBBBAuA_2018_suf1.0_Kopie.dta", clear
mvdecode zpalter, mv(9999)
mvdecode F518_SUF, mv( 99998/ 99999)
mvdecode F200, mv( 97/99)
mvdecode m1202, mv(-1)

	foreach i of varlist * {
	local longlabel: var label `i'
	local shortlabel = substr("`longlabel'",1,32)
	label var `i' "`shortlabel'"
}

saveold "BIBBBAuA_2018_suf1.0_clean.dta", replace ver(13)
glo tab_dir "D:\oCloud\Home-Cloud\Lehre\BIBB\StataBIBB3/tex"

* ------------------ *
quietly reg F518_SUF zpalter
ereturn list
	mat l e(b)

su F518_SUF
ereturn list
return list



* ------------------ *
* tabstat
tabstat F518_SUF, c(var) stat(mean sd min max n) // wie orientiert?
tabstat F518_SUF, c(stat) stat(mean sd min max n)
ereturn list

estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
esttab, cells("mean sd min max count")

// Median hinzufügen braucht neues estpost:
esttab, cells("mean p50 sd min max count")

// mit p50 für Median
estpost tabstat F518_SUF, c(stat) stat(mean p50 sd min max n)
esttab, cells("mean p50 sd min max count")

// formatierung - ohne Median, übersichtlicher
esttab, ///
	cells("mean p50 sd min max count") ///
	nonumber nomtitle noobs label 

esttab, ///
	cells("mean sd min max count") ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")
		
esttab, ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.0fc)) max(fmt(%13.0fc)) count(fmt(%6.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")

	
/// format erklären
	help format
	dis strlen("10789.1234")
	display %10.2f 	10789.1234 // 0 Nachkommastellen
	display %10.0f 	10789.1234 // 2 Nachkommastellen
	display %11.5f 	10789.1234 // 0 hinzugefügt!
* mit fc werden Tausendertrenner eingefügt
	display %10.2fc 	10789.1234
	display %10,2fc 	10789.1234 // , und . tauschen -> "dt Format"
	
	
* export -------	
esttab using "${tab_dir}/tab1.rtf", ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%4.0fc)) max(fmt(%4.0fc)) count(fmt(%4.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst") ///
	replace
   
esttab using "${tab_dir}/tab1.tex", ///
	cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%4.0fc)) max(fmt(%4.0fc)) count(fmt(%4.0fc))")  ///
	nonumber nomtitle nonote noobs label ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	coeflabel(F518_SUF "Bruttoverdienst")  ///
	replace booktabs
	

	
* eigene Infos hinzufügen -----------------
tabstat F518_SUF, c(stat) stat(mean sd min max n)
estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
ereturn list
mat list e(mean)

estpost tabstat F518_SUF, c(stat) stat(mean sd min max n)
mdesc F518_SUF
mat miss = r(miss)
mat colname miss = F518_SUF
mat list miss
estadd mat miss

esttab, cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N" "Missings")		

esttab  using "${tab_dir}/desc_miss.tex", ///
		cells("mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc)) miss(fmt(%13.0fc))") noobs ///
		nomtitle nonumber label collabels("Mean" "SD" "Min" "Max" "N" "Missings")  ///
		coeflabel(F518_SUF "Bruttoverdienst") ///
		booktabs replace

		

fastgini F518_SUF
return list

* mehrere Variablen 
estpost tabstat zpalter F518_SUF F200, c(stat) stat(mean sd min max n)
mdesc F518_SUF F518_SUF F200
return list
* --> loop

	loc x = "zpalter F518_SUF F200"
	mat m1 = J(1,3,.)	
	mat colname m1 = `x'
	mat list m1

	forval v = 1/3 {
		loc x: dis	word("zpalter F518_SUF F200",`v')	
		*mdesc `x'
		*loc m = r(miss)
		fastgini `x'
		loc m =  r(gini)
		mat m1[1,`v'] = `m'
	}
	mat l m1
	
estpost tabstat zpalter F518_SUF F200, c(stat) stat(mean sd min max n)
estadd mat m1
esttab, cells("count(fmt(%13.0fc)) m1(fmt(%13.0fc))")  noobs ///
		nomtitle nonumber label collabels("N" "Missings") 
		
		
		

estpost tabstat zpalter F518_SUF F200, c(stat) stat(mean sd min max n)
estadd mat m1
esttab, cells("count(fmt(%13.0fc)) m1(fmt(%13.3fc))")  noobs ///
		nomtitle nonumber label collabels("N" "Gini") 

	
* Gruppenvergleich	
estpost tabstat zpalter F518_SUF, by(S1) c(stat) stat(mean sd) nototal	

esttab, cells(mean(fmt(%10.4fc)) sd(fmt(%13.4fc) par)) nostar  nonumber unstack ///
  nomtitle nonote noobs label  ///
   collabels(none) gap   ///
   eqlabels("Männer" "Frauen") /// 
   nomtitles
	
*help fmt  
est dir 
est clear  // clear the est locals

* ------------------ *
* Kreuztabelle
tabulate m1202 S1 
estpost tabulate m1202 S1
/// b pct colpct rowpct
esttab, cell(b(fmt(2))) unstack noobs 
esttab, cell(b(fmt(2))) unstack noobs collabels(none) nonumber nomtitles
esttab, cell(b(fmt(2))) unstack noobs collabels(none) nonumber nomtitles varlabels(`e(labels)') 

esttab, cell(b(fmt(2))) unstack noobs collabels(none) nonumber nomtitles ///
			varlabels(`e(labels)', blist(Total "{hline @width}{break}"))

esttab, cell(b) unstack noobs collabels(none) nonumber nomtitles ///
			varlabels(`e(labels)', blist(Total "{hline @width}{break}")) ///
			eqlabels(, lhs("Ausbildungsabs."))                    

esttab, cell(b) unstack noobs collabels(none) nonumber nomtitles ///
			varlabels(`e(labels)', blist(Total "{hline @width}{break}")) ///
			eqlabels(, lhs("Ausbildungsabs.")) ///
			mgroups("Gender" "", pattern(1 0 1))

esttab using "${tab_dir}/crosstab.rtf", cell(b) unstack noobs collabels(none) nonumber nomtitles ///
			replace ///
			varlabels(`e(labels)', blist(Total "{hline @width}{break}")) ///
			eqlabels(, lhs("Ausbildungsabs.")) ///
			mgroups("Gender" "", pattern(1 0 1))			
			

esttab using "${tab_dir}/crosstab2.tex", cell(b) unstack noobs collabels(none) nonumber nomtitles ///
		replace booktabs ///
		eqlabels(, lhs("Ausbildungsabs.")) ///
		varlabels(`e(labels)') /// 
		mgroups("Gender" "", pattern(0 1 0) prefix(\multicolumn{2}{c}{) suffix(}) span erepeat(\cmidrule(lr){2-3})) // Überschrift über spalten
		
		
		
		varlabels(`e(labels)', blist(Total "{hline @width}{break}")) ///
		mgroups("Gender" "", pattern(1 0 1))			
				
* ------------------ *			
* gewichtete Tabelle			
svyset _n [pweight=gew2018]
estpost svy: tabulate  m1202 S1 , row percent count
esttab ., se nostar nostar unstack ///
		varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs.")) nonumber nomtitles

		mlabels("Geschlecht", span erepeat("t"))

		lab var S1 "Gender"
esttab . using "${tab_dir}/svy_desc.rtf", cell(count(fmt(2))) se nostar nostar unstack ///
		varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs.")) nonumber ///
		title("title") ///
		note("note") ///
		mgroups("Gender", pattern(0 1 0 1) span )
		labcol2("lc2", title("t2")) ///
		///
		mlabels(, titles  )		///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span}))
		collabels(none) // "count" ausblenden

esttab . using "${tab_dir}/svy_desc.tex", se nostar nostar unstack ///
	booktabs replace nonumber nomtitles ///
	varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs.")) ///
	mgroups("Gender", pattern(0 1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Überschrift über spalten

	
	esttab ., se nostar nostar unstack ///
	booktabs replace nonumber ///
	varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs.")) ///
	mgroups("Gender", pattern(0 1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Überschrift über spalten

* ------------------ *
* correlationsmatrix
estpost correlate zpalter F518_SUF F200, matrix
* help correlate
esttab ., unstack compress noobs  nonumber label nomtitles


* ------------------ *
* regression
reg F518_SUF c.zpalter##c.zpalter i.m1202 
est store reg1
estadd local note "Mod1"

esttab reg1 , r2 
esttab reg1 , r2 label
esttab reg1 , r2 coeflabel(F200 "Arbeitz")
/*//
	cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber ///
	nomtitle nonote noobs label collabels("Sum" "Mean" "SD" "Min" "Max" "N") ///
	replace
  */ 	
reg F518_SUF c.zpalter##c.zpalter i.m1202  F200 
est store reg2
estadd local note "Mod2"
esttab reg2, r2 scalar(note) stats(ll r2 cmdline)


esttab reg1 reg2, r2 scalar(note) stats(ll r2 cmdline)

esttab reg1 reg2 using "${tab_dir}/regtab.rtf", r2 scalar(note) stats(ll r2 cmdline)

* ------------------ *
* margins



* ------------------ *
* formating
/*
	fragment           suppress table opening and closing (LaTeX, HTML)
	[no]float          whether to use a float environment or not (LaTeX)
	page[(packages)]   add page opening and closing (LaTeX, HTML)
	alignment(string)  set alignment within columns (LaTeX, HTML, RTF)
	width(string)      set width of table (LaTeX, HTML)
	longtable          multi-page table (LaTeX)
	fonttbl(string)    set custom font table (RTF)
*/

/* Output
	replace            overwrite an existing file
	append             append the output to an existing file
	type               force prining the table in the results window
	noisily            display the executed estout command
*/