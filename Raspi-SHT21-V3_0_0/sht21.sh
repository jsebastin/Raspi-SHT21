#!/bin/sh
# Autor: Joerg Kastning

# Variablen  ###########################################################

LogInterval=600
maxtemp=115.0			# Grenzwert ab dem eine Temperaturwarnung verschickt wird.
minhumidity=30			# Mindestwert fuer die Luftfeuchtigkeit.
maxhumidity=40			# Maximalwert fuer die Luftfeuchtigkeit.
email="name@example.org"	# Zieladresse für die E-Mail-Benachrichtigung.

# Funktionen ###########################################################

tempalarm() {
	
	temp="$(tail -n1 sht21-data.csv | awk '{print $4}')"
	if [ $(echo "if (${temp} > ${maxtemp}) 1 else 0" | bc) -eq 1 ]
	then
		echo "ALARM: Die Temperatur hat den festgelegten Grenzwert überschritten!" | mailx -s "Temperaturalarm" "$email" ;
	fi
}

humidityalarm() {
	# Luftfeuchtigkeit aus Datei auslesen und Variable zuweisen.
	humidity="$(tail -n1 sht21-data.csv | awk '{print $5}')"

	# Prüfung, ob Luftfeuchtigkeit innerhalb definierter Parameter liegt.
	if [ $humidity -lt $minhumidity ]
	then
		echo "WARNUNG: Die Luftfeuchtigkeit ist zu hoch!" | mailx -s "WARNUNG - Luftfeuchtigkeit zu hoch!" "$email" ;
	fi

	if [ $humidity -gt $maxhumidity ]
	then
		echo "WARNUNG: Die Luftfeuchtigkeit ist zu niedrig!" | mailx -s "WARNUNG - Luftfeuchtigkeit zu niedrig!" "$email" ;
	fi
}

# Hauptprogramm ########################################################

while true
do
	TimeString=$(date +"%d.%m.%Y %H:%M:%S")	
	Timestamp=$(date +%s)
	TimeOffset=$(date -d '1970-01-01 0 sec' +%s)
	
	Timestamp=$(($Timestamp - TimeOffset))		
				
	if [ $(($Timestamp % 5)) -eq 0 ]
	then
		Sht21Data=$(./sht21 S)
#		echo "$TimeString\t$Timestamp\t$Sht21Data" # Für Tests einkommentieren.
			
		if [ $(($Timestamp % $LogInterval)) -eq 0 ]
		then
			echo "$TimeString\t$Timestamp\t$Sht21Data" >> sht21-data.csv

			tempalarm
			humidityalarm

			#./sht21 C > sht21-cosm.txt
			#./function-cosm-push.sh
			#./function-ftp-upload.sh
		fi
	fi	
	sleep 1
done
