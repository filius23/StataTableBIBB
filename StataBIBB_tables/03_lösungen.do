* --------------------------------- *
* Tabellenexport mit Stata
* Kapitel 3: table & gewichtete table
* Lösungen
* --------------------------------- *

* --------------------------------- *
* 1
* Erstellen Sie eine Häufigkeitstabelle für von `gkpol`. 
* Lassen Sie sich die Labels für `gkpol` anzeigen und passen Sie die Tabelle nach Ihren Vorstellungen an. Wie würden Sie die kumulierten Anteile aus ihrer Tabelle ausblenden?
estpost tabulate gkpol
esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
       nonumber nomtitle noobs

esttab, cells("b(label(freq)) pct(fmt(2))") ///
       nonumber nomtitle noobs	   
	   
esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///	 
	nonumber nomtitle noobs ///
	varlabels(`e(labels)') ///	
	varwidth(40) 
	
* Passen Sie die Labels für die Spalten (bspw. `N` statt `freq` und `%` statt `pct`) an und blenden Sie die kumulierte relative Häufigkeit aus.

esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///	 
	nonumber nomtitle noobs ///
	varlabels(`e(labels)') ///
	collabels("N" "%" "kum. Anteil") ///
	varwidth(40)
	
* --------------------------------- *
* 2
* Erstellen Sie eine Kreuztabelle für `gkpol` und `mobil`. 
tabulate gkpol mobil
estpost tabulate gkpol mobil
esttab, cell(b(fmt(%13.0fc))) unstack noobs collabels(none) nonumber nomtitles varlabels(`e(labels)') varwidth(40)

* Passen Sie die Beschriftung der Tabelle nach Ihren Vorstellungen an.
esttab, cell(b(fmt(%13.0fc))) unstack noobs collabels(none) nonumber nomtitles ///
		  varlabels(`e(labels)') varwidth(40) ///
		  eqlabels(, lhs("Wohnortgröße"))  ///
		   mgroups("Interviewmodus" "", pattern(1 0 1)) // Überschrift über spalten
			

* Was müssten Sie ändern, um die Zeilen- oder Spaltenprozente anzeigen zu lassen?
esttab, cell(colpct(fmt(%13.3fc))) unstack noobs collabels(none) nonumber nomtitles ///
		  varlabels(`e(labels)') varwidth(40) ///
		  eqlabels(, lhs("Wohnortgröße"))  ///
		   mgroups("Interviewmodus" "", pattern(1 0 1)) // Überschrift über spalten

* Fügen Sie auch eine Notiz ein und einen Titel ein
esttab, cell(colpct(fmt(%13.3fc))) unstack noobs collabels(none) nonumber nomtitles ///
		  varlabels(`e(labels)') varwidth(40) ///
		  eqlabels(, lhs("Wohnortgröße"))  ///
		  modelwidth(20) /// spaltenbreite
		   mgroups("Interviewmodus" "", pattern(1 0 1)) /// Überschrift über spalten
			title("Hier kann ein Titel stehen") /// titel
			note("Und hier eine Notiz") // notiz
			
			
esttab using "${word}/tab2.rtf", cell(colpct(fmt(%13.3fc))) unstack noobs collabels(none) nonumber nomtitles ///
		  varlabels(`e(labels)') varwidth(40) ///
		  eqlabels(, lhs("Wohnortgröße"))  ///
		  modelwidth(20) /// spaltenbreite
		   mgroups("Interviewmodus" "", pattern(1 0 1)) /// Überschrift über spalten
			title("Hier kann ein Titel stehen") /// titel
			note("Und hier eine Notiz") // notiz
		
			