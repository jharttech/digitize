#!/bin/bash

################################################################

# This is a simple script to help with the legal copying of owned
# dvd movies to digital backups.


################################################################

# Display logo
clear
cat jhart_shell_logo.txt
echo -e "\n"
echo "
################################################################"
echo "
################################################################"
echo -e "\n"

################################################################

# Here we change directories into the default linux video file
# location. ~/Videos/
# If a "Videos" directory does not exsist we create one.

cd
_File_Check=$(ls | grep "Videos")
if [ "" == "$_File_Check" ]; then
	mkdir Videos
	cd Videos
	mkdir Movie_Backups
	cd Movie_Backups
else
	cd Videos
	_File_Check_Two=$(ls | grep "Movie_Backups")
	if [ "" == "$_File_Check_Two" ]; then
		mkdir Movie_Backups
		cd Movie_Backups
	else
		cd Movie_Backups
	fi
fi


################################################################

# Here we ask for the name of the owned movie to make a digital
# copy of.

while true; do
	echo "Please enter your movies title (Use underscores for spaces)."
	read _MovieTitle
	echo "Your movies title is "$_MovieTitle""
	echo "Is the title correct? y/n "
	read yn
	if [ "$yn" == "y" ];
	then
		echo "Would you like to specify the title to encode? y/n (If you do not know what this means choose 'n' to use default settings)."
		read yesno
		if [ "$yesno" == "y" ];
		then
			echo "Please enter the number of the title to encode (If you do not know please enter '1'): "
			read _TitleNum
			echo "Now going to make a digital backup of "$_MovieTitle" it will be located in ~/Videos/Movie_Backups/"
			sleep 3
			HandBrakeCLI -i /dev/sr0 -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160
			break
		else
			if [ "$yesno" == "n" ];
			then
				echo "Going to use default settings."
				echo "Now going to make a digital backup of "$_MovieTitle" it will be located in ~/Videos/Movie_Backups/"
				sleep 3
				HandBrakeCLI -i /dev/sr0 -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160
				break
			fi
		fi
	fi
	_CheckForFile=$(ls | grep "$_MovieTitle")
		if [ "" == "$_CheckForFile" ];
		then
			echo "There was an error with the copying of your movie, usually this means that you need to manually specify the correct title number to encode.  I recommend trying again with a different title number.  If you do not know what this means you can read more about it at https://handbrake.fr/docs/en/1.2.0/ or you can read the manual page by running 'man HandBrakeCLI' in your linux terminal." 
			echo -e "\n"
			echo "Would you like to try to copy again using a different title number? y/n"
			read _retry
			if [ "$_retry" == "y" ];
			then
				echo "Please enter the number of the title to encode (If you do not know please enter '1'): "
				read _TitleNum
				echo "Now going to make a digital backup of "$_MovieTitle" it will be located in ~/Videos/Movie_Backups/"
				sleep 3
				HandbrakeCLI -i /dev/sr0 -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160
				break
			else
				if [ "$_retry" == "n" ];
				then
					echo "Sorry your movie has not been copied. Thank You! - Jhart"
					break
				fi
			fi
		else
		if [ "$_MovieTitle" == "$_CheckForFile" ];
			then
				echo "Congratulations you now have a digital copy of your movie "$_MovieTitle".  Enjoy and Thank You! - Jhart"
				break
			fi
		fi
done


#######################################################################
# Done Message

echo "Enjoy and Thank You! -Jhart"
sleep 3
#######################################################################
exit




