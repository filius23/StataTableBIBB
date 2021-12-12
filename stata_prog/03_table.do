* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 3: table & gewichtete table
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
* tab

tabulate m1202
tabulate m1202 S1 

* ------------------ *
* "One-way frequency table"

estpost tabulate m1202
esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
       nonumber nomtitle noobs
	 
	 
esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///	 
	nonumber nomtitle noobs ///
	varlabels(`e(labels)') ///	
	varwidth(40) 
	
* export 
esttab using "${word}/03_tab1.rtf", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
	nonumber nomtitle noobs ///
	varlabels(`e(labels)') ///
	varwidth(40) ///
	replace 
	 	 
	 

* ------------------ *
* Kreuztabelle

tabulate m1202 S1 
estpost tabulate m1202 S1
/// b pct colpct rowpct
esttab, cell(b(fmt(%13.0fc))) unstack noobs 
esttab, cell(b(fmt(%13.0fc))) unstack noobs collabels(none) nonumber nomtitles
esttab, cell(b(fmt(%13.0fc))) unstack noobs collabels(none) nonumber nomtitles varlabels(`e(labels)') 
esttab, cell(b(fmt(%13.0fc))) unstack noobs collabels(none) nonumber nomtitles varlabels(`e(labels)') varwidth(40)


esttab, cell(b) unstack noobs collabels(none) nonumber nomtitles ///
			varlabels(`e(labels)') ///
			eqlabels(, lhs("Ausbildungsabs."))  ///
			varwidth(40) ///
			mgroups("Gender" "", pattern(1 0 1)) /// Überschrift über spalten
			title("Hier kann ein Titel stehen") /// titel
			note("Und hier eine Notiz") // notiz

			
loc x "eingefügtem Text"
esttab, cell(b) unstack noobs collabels(none) nonumber nomtitles ///
			varlabels(`e(labels)') ///
			eqlabels(, lhs("Ausbildungsabs."))  ///
			varwidth(40) ///
			mgroups("Gender" "", pattern(1 0 1)) /// Überschrift über spalten
			title("Hier kann ein Titel stehen") /// titel
			note("Und hier eine Notiz sogar mit: `x'") // notiz
			

			
* export
loc x "eingefügtem Text"
esttab using "${word}/crosstab.rtf", cell(b) unstack noobs collabels(none) nonumber nomtitles ///
			varlabels(`e(labels)') ///
			eqlabels(, lhs("Ausbildungsabs."))  ///
			varwidth(40) ///
			mgroups("Gender" "", pattern(1 0 1)) /// Überschrift über spalten
			title("Hier kann ein Titel stehen") /// titel
			note("Und hier eine Notiz sogar mit: `x'") /// notiz
			replace

esttab using "${tex}/crosstab.tex", cell(b) unstack noobs collabels(none) nonumber nomtitles ///
		varlabels(`e(labels)') /// 
		eqlabels(, lhs("Ausbildungsabs.")) ///
		mgroups("Gender" "", pattern(0 1 0) prefix(\multicolumn{2}{c}{) suffix(}) span erepeat(\cmidrule(lr){2-3})) /// Überschrift über spalten
		title("Hier kann ein Titel stehen") /// titel
		note("Und hier eine Notiz sogar mit: `x'") /// notiz
		replace booktabs // latex optionen
			

* ------------------ *			
* gewichtete Tabelle			
svyset _n [pweight=gew2018]
estpost svy: tabulate  m1202 S1 , row percent count

esttab ., cell(b(fmt(%13.0fc))) ///
    nostar nostar unstack ///
		nonumber nomtitles collabels(none)  ///
		varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs.")) ///
		mgroups("Gender", pattern(0 1 0 1) span ) ///
		varwidth(40) 
		
esttab using "${word}/svytab.rtf", cell(b(fmt(%13.0fc))) ///
    nostar nostar unstack ///
		nonumber nomtitles collabels(none)  ///
		varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs.")) ///
		mgroups("Gender", pattern(0 1) span ) ///
		varwidth(40) ///
		replace
	
esttab . using "${tex}/svy_desc.tex",  cell(b(fmt(%13.0fc))) ///
		nostar nostar unstack ///
		nonumber nomtitles collabels(none)  ///
		varlabels(`e(labels)') eqlabels(`e(eqlabels)', lhs("Ausbildungsabs."))  ///
		mgroups("Gender", pattern(0 1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		booktabs replace
		
