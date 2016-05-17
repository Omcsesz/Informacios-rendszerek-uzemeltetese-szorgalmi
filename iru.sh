#!/bin/bash

#**************************************#
#               iru.sh                 #
#            Email top 5 lister        #
#       written by Omar Sweidan	       #
#            May 17, 2016              #
#				       # 
#**************************************#


#Leveleket tartalmazo mappa eleresi utvonala
MAIL_FOLDER="/home/sweidan/.local/share/evolution/mail/local/cur"

#ha letezik a folder -> belepunk
if [ -d "$MAIL_FOLDER" ]
then
    echo "Bent vagyok a mail folderben"
    # megszamoljuk, hany darab level van
    NUMBER_OF_MAILS=$( ls -l $MAIL_FOLDER | wc -l )
    
    #ha vannak levelek, megkezdjuk a feldolgozast
    if [ $NUMBER_OF_MAILS -eq  0 ];  
    then
	echo "Nincsenek levelek"
    else
	
	# letrehozunk egy tombot a kuldoknek
	declare -A senders # -A: array
	
	# vegigmegyunk a MAIL_FOLDER tartalman
	for file in $MAIL_FOLDER/*
	do

	   # a grep az adott fileból a From: tartalmu sort szedi ki, leven ez tartalmazza a kuldot
	   # a cut az adott sort darabolja a ' ' határoló mentén (-d' ' kapcsoló)
	   # az -f3 a harmadik oszlopot valasztja ki
	   # az -f2 a masodik oszlopot valasztja ki => igy szabadítjuk meg az email cimet az ot korulvevo karakterektol
	   # a sed a kezdo whitespace karaktereket vagja le (-e: expression) (sed == stream editor)
  
	   SENDER=$(grep 'From: ' $file | cut -d' ' -f3- | cut -d'<' -f2 | cut -d'>' -f1 | sed -e 's/^[ \t]*//');
	    
           # meret kiszamolasa
	   SIZE=$(stat -c%s "$file")
	   SIZE=$(($SIZE/1024)) # meret kilobyteban

	   # ha tartalmaz kuldo mezot az adott fajl, akkor felvesszuk a levelek koze
	   if [ -n "$SENDER" ] 
	   then 

		# ha egy már letezo feladoval van dolgunk, akkor megnoveljuk a level meretevel az osszmeretet
		if [ ${senders[$SENDER]} ] 
		then
	  	     senders[$SENDER]=$((${senders[$SENDER]}+$SIZE))
		# egyebkent
		else
		     senders[$SENDER]=$SIZE
		fi
           fi
	done
	
	# az összmeret alapjan sorbarendezzuk oket, majd kivalasztjuk az 5 legnagyobbat
	for i in "${!senders[@]}"
	do
	    echo $i ${senders["$i"]};
	done | 	sort -rn -k2 | head -5 
#-r: reverse, -n: numerically, -k2: a masodik oszlop ertekei szerint 
   fi
else
    echo "Nem vagyok a mail_folderben"
fi
