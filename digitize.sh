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
			echo "Please enter the number of the title to encode (If you do not know please enter '0'): "
			read _TitleNum
			if [ "$_TitleNum" == "0" ];
			then
				echo "Now going to scan disc for Main Feature movie track."
				sleep 3
				HandBrakeCLI -i /dev/sr0 -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160 2>&1 | tee output
				_MainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
				echo "Your Main Feature title track is # "$_MainTrack" "
				echo "Now going to try to digitize your movie titled "$_MovieTitle"."
				sleep 4
				HandBrakeCLI -i /dev/sr0 -t "$_MainTrack" -o "$_MovieTitle".mp4 -e x264
			else
			echo "Now going to make a digital backup of "$_MovieTitle" title track # "$_TitleNum", it will be located in ~/Videos/Movie_Backups/"
			sleep 3
			HandBrakeCLI -i /dev/sr0 -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160
			break
		fi
		else
			if [ "$yesno" == "n" ];
			then
				echo "Going to use default settings."
				echo "Now going to attemp to make a digital backup of "$_MovieTitle" it will be located in ~/Videos/Movie_Backups/"
				sleep 3
				HandBrakeCLI -i /dev/sr0 -t 0 -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160 2>&1 | tee output
				_CheckMainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
				sleep 2
				HandBrakeCLI -i /dev/sr0 -t "$_CheckMainTrack" -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160
				sleep 5
				break
			fi
		fi
	fi
done
########################################################################
# Here we check the size of new created movie file to see if it is
# big enough to be the actual movie.
# First attempt at dynamic minimum size.  Issue is that this will need
# changed for different compression options.  I will be working
# on compression options and dynamic minimum size based on compression
# type.

_Size=$(lsblk /dev/sr0 | grep -oP '(?<=1 ).*?(?=\.)')
_MakeMinSize=$(expr $_Size - 1)
while true; do
	_MinimumSize=$(expr $_MakeMinSize \* 100000000)
	_ActualSize=$(wc -c <"$_MovieTitle".mp4) >> /dev/null
	if [[ $_ActualSize -ge $_MinimumSize ]];
	then
		echo "size is over "$_MinimumSize" bytes"
		sleep 5
	else
		echo "size is under "$_MinimumSize" bytes"
		rm -f "$_MovieTitle".mp4
		echo "The chosen Title Index did NOT contain the main movie."
		sleep 1
	fi
	_CheckForFile=$(ls | grep "$_MovieTitle")
	if [ "" == "$_CheckForFile" ];
	then
		echo -e "\n"
		echo "There was an error with the copying of your movie, usually this means that you need to manually specify the correct title number to encode.  I recommend trying again with a different title number.  If you do not know what this means you can read more about it at https://handbrake.fr/docs/en/1.2.0/ "
		echo -e "\n"
		while true; do
			echo "Would you like to try to copy again using a different title number? y/n"
			read _retry
			if [ "$_retry" == "y" ];
			then
				echo "Please enter the number of the title to encode (If you do not know please enter '0'): "
				read _Retry
				if [ "$_Retry" == "0" ];
				then
					echo "Now going to scan disc for Main Feature movie track."
					sleep 3
					HandBrakeCLI -i /dev/sr0 -t "$_Retry" -o "$_MovieTitle".mp4 -e x264 -q 20 -B 160 2>&1 2>&1 | tee output
					_MainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
					echo "Now going to make a digital backup of "$_MovieTitle" it will be located in ~/Videos/Movie_Backups/ "
					echo "Now going to try to digitize your movie titled "$_MovieTitle"."
					sleep 4
					HandBrakeCLI -i /dev/sr0 -t "$_MainTrack" -o "$_MovieTitle".mp4 -e x264
					break
				fi
			else
				if [ "$_retry" == "n" ];
				then
					echo "Sorry your movie has not been copied. Thank You! - Jhart"
					exit
				fi
			fi
		done
	else if [ ""$_MovieTitle.mp4"" == "$_CheckForFile" ];
	then
		echo "Congratulations you now have a digital copy of your movie "$_MovieTitle".  Enjoy and Thank You! - Jhart"
		sleep 3
		exit
	fi
fi
done



#######################################################################
exit




