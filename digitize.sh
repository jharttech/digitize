#!/bin/bash

################################################################

# This is a simple script to help with the legal copying of owned
# dvd movies to digital backups.

################################################################

echo "
################################################################"
echo "
################################################################"
echo -e "\n"

################################################################
# Here we will install needed tools
sudo apt install git ffmpeg handbrake-cli -y
################################################################

# Here we will ask if the user has an external hard drive they would like to use

echo ""
echo "Do you have an external hard drive you would like to store the Movie in? y/n"
read "confirmed"
if [ "$confirmed" == "y" ]; then
    echo ""
    lsblk -o NAME,TYPE,MOUNTPOINT | grep /media | awk -F"/" '{print $NF}'| nl -s': '

    echo "Please type a number corresponding to the device you like to store the movie on."


    read "device_name_input"

    device_name=$(lsblk -o NAME,TYPE,MOUNTPOINT | grep /media | awk -F"/" '{print $NF}' | awk 'NR=='$device_name_input)

    username=$(echo $USER)
    cd /media/$username/$device_name
    _File_Check=$(ls | grep "Moviess")
    if [ -z "$_File_Check" ]; then
        mkdir /media/$username/$device_name/Moviess
        cd Moviess
        mkdir Movie_Backups
        cd Movie_Backups
    else
        cd Moviess
        _File_Check_Two=$(ls | grep "Movie_Backups")
        if [ -z "$_File_Check_Two" ]; then
            mkdir Movie_Backups
            cd Movie_Backups
        else
            cd Movie_Backups
        fi
    fi


fi



        # If they dont we will create a folder in their Video Directory
if [ "$confirmed" == "n" ]; then
    cd
    _File_Check=$(ls | grep "Videos")
    if [ -z "$_File_Check" ]; then
        mkdir Videos
        cd Videos
        mkdir Movie_Backups
        cd Movie_Backups
    else
        cd Videos
        _File_Check_Two=$(ls | grep "Movie_Backups")
        if [ -z "$_File_Check_Two" ]; then
            mkdir Movie_Backups
            cd Movie_Backups
        else
            cd Movie_Backups
        fi
    fi
fi    



# Here we change directories into the default linux video file
# location. ~/Videos/
# If a "Videos" directory does not exist we create one.

#find the name of different external mounts



################################################################
# Here we attempt to find where the DVD player is mounted

echo "Detecting DVD devices and mount points..."
lsblk | grep sr | awk -F" " '{print "/dev/"$1}' | nl -s': '
echo "Please type a number corresponding to your DVD Player"
read "user_input"

dvd_devices=$(lsblk | grep sr | awk -F" " '{print "/dev/"$1}' | awk 'NR=='$user_input)

echo "$dvd_devices"

if [ -z "$user_input" ]; then
    echo "No DVD player detected."
    exit 1
fi

################################################################
# Here we ask for the name of the owned movie to make a digital
# copy of.

echo "Please enter your movie's title (Use underscores for spaces)."
read "_MovieTitle"
echo "Your movie's title is $_MovieTitle"
echo "Is the title correct? y/n "
read "yn"
while true; do
    if [ "$yn" == "y" ]; then
        echo "Would you like to specify the title to encode? y/n (If you do not know what this means choose 'n' to use default settings)."
        read yesno
        if [ "$yesno" == "y" ]; then
            echo "Please enter the number of the title to encode (If you do not know please enter '0'): "
            read _TitleNum
            if [ "$_TitleNum" == "0" ]; then
                echo "Now going to scan disc for Main Feature movie track."
                sleep 3
                HandBrakeCLI -i $dvd_devices -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192  2>&1 | tee output
                _MainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
                echo "Your Main Feature title track is # $_MainTrack"
                echo "Now going to try to digitize your movie titled $_MovieTitle."
                sleep 4
                HandBrakeCLI -i $dvd_devices -t "$_MainTrack" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192 
            else
                if [ "$confirmed" == "y" ]; then
                    echo "Now going to make a digital backup of $_MovieTitle title track # $_TitleNum, it will be located in /media/$username/$device_name/Moviess"
                else
                    echo "Now going to make a digital backup of $_MovieTitle title track # $_TitleNum, it will be located in ~/Videos/Movie_Backups/"
                fi
                sleep 3
                #HandBrakeCLI -i $dvd_devices -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192  #Uncommint this line and commint bellow to reduce filesize at quality expense
                HandBrakeCLI -i $dvd_devices -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192 
                break
            fi
        else
            if [ "$yesno" == "n" ]; then
                echo "Going to use default settings."
                if [ "$confirmed" == "y" ]; then
                    echo "Now going to make a digital backup of $_MovieTitle title track # $_TitleNum, it will be located in /media/$username/$device_name/Moviess"
                else
                    echo "Now going to make a digital backup of $_MovieTitle title track # $_TitleNum, it will be located in ~/Videos/Movie_Backups/"
                fi
                sleep 3
                HandBrakeCLI -i $dvd_devices -t 0 -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192  2>&1 | tee output
                _CheckMainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
                sleep 2
                HandBrakeCLI -i $dvd_devices -t "$_TitleNum" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192 
                sleep 5
                break
            fi
        fi
    fi
done

########################################################################
# Here we check the size of the newly created movie file to see if it is
# big enough to be the actual movie.
# First attempt at dynamic minimum size.  Issue is that this will need
# to be changed for different compression options.  I will be working
# on compression options and dynamic minimum size based on compression
# type.

_Size=$(lsblk $dvd_devices | grep -oP '(?<=1 ).*?(?=\.)')
_MakeMinSize=$(expr $_Size - 1)
while true; do
    # _MinimumSize=$(expr $_MakeMinSize \* 100000000)
    # _ActualSize=$(wc -c <"$_MovieTitle".mp4) >> /dev/null
    # if [[ $_ActualSize -ge $_MinimumSize ]]; then
    #     echo "size is over $_MinimumSize bytes"
    #     sleep 5
    # else
    #     echo "size is under $_MinimumSize bytes"
    #     rm -f "$_MovieTitle".mp4
    #     echo "The chosen Title Index did NOT contain the main movie."
    #     sleep 1
    # fi
    _CheckForFile=$(ls | grep "$_MovieTitle")
    if [ -z "$_CheckForFile" ]; then
        echo -e "\n"
        echo "There was an error with the copying of your movie, usually this means that you need to manually specify the correct title number to encode. I recommend trying again with a different title number. If you do not know what this means you can read more about it at https://handbrake.fr/docs/en/1.2.0/"
        echo -e "\n"
        while true; do
            echo "Would you like to try to copy again using a different title number? y/n"
            read _retry
            if [ "$_retry" == "y" ]; then
                echo "Please enter the number of the title to encode (If you do not know please enter '0'): "
                read "_RetryVar"
                if [ "$_RetryVar" == "0" ]; then
                    echo "Now going to scan disc for Main Feature movie track."
                    sleep 3
                    HandBrakeCLI -i $dvd_devices -t "$_RetryVar" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192  2>&1 | tee output
                    _MainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
                    echo "Now going to make a digital backup of $_MovieTitle, it will be located in ~/Videos/Movie_Backups/"
                    echo "Now going to try to digitize your movie titled $_MovieTitle."
                    sleep 4
                    HandBrakeCLI -i $dvd_devices -t "$_MainTrack" -o "$_MovieTitle".mp4 -e x264
                    break
                else
                    echo "Now going to scan disc for Main Feature movie track."
                    sleep 3
                    HandBrakeCLI -i $dvd_devices -t "$_RetryVar" -o "$_MovieTitle".mp4 -e x264 -q 18 -B 192  2>&1 | tee output
                    _MainTrack=$(grep -B1 Main output | grep title | tr -dc '0-9')
                    echo "Now going to make a digital backup of $_MovieTitle, it will be located in ~/Videos/Movie_Backups/"
                    echo "Now going to try to digitize your movie titled $_MovieTitle."
                    sleep 4
                    HandBrakeCLI -i $dvd_devices -t "$_MainTrack" -o "$_MovieTitle".mp4 -e x264
                    break  
                fi
            else
                if [ "$_retry" == "n" ]; then
                    echo "Sorry, your movie has not been copied. Thank you! - Jhart"
                    exit
                fi
            fi
        done
    else
        if [ "$_MovieTitle".mp4 == "$_CheckForFile" ]; then
            echo "Congratulations, you now have a digital copy of your movie $_MovieTitle. Enjoy and Thank You! - Jhart"
            sleep 3
            exit
        fi
    fi
done

#######################################################################
exit
