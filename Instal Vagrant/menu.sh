#!/bin/bash
# A menu driven shell script sample template 
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
BASEDIR=$(pwd)
echo $BASEDIR
if [ -z "$1" ]
then
    echo "This Menu script need tow parameter. First a folder for a new collection of site."
    echo "Second a path to core-cms. "
    echo "Example ./menu.sh ~/Documents/php74Centos8 ~/Documents"
    exit
fi
if [ -z "$2" ]
then
    echo "Parameter 2 omited. "
    exit
fi
SCRIPTPATH="$( cd "$(dirname "$2")" >/dev/null 2>&1 ; pwd -P )"
dir=`eval echo $1 `
projectDIRECTORY=$(echo "$dir"| sed 's/\//\\\//g')
dir2=`eval echo $2 `
cmsDIRECTORY=$(echo "$dir2"| sed 's/\//\\\//g')
unset username
echo -n "git username:"
read username

# ----------------------------------
# Step #2: User defined function
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}
addvagrantbox()
{
    boxList=$(vagrant box list)
    boxinstal=""
    echo "$boxList"
    for i in "$boxList";
    do
        if [[ $i == *"sd-Centos8Php74fci"* ]]; then
            echo "It's there!"
        else
            boxinstal=$(vagrant box add sd-Centos8Php74fci sd-Centos8Php74fci.box)
        fi
    done
}
preperDir()
{
    $(mkdir -p $1)
    $(mkdir -p "$1"/vagrantconfig)
    $(cp apache-config-http-2-and-ssl-config-2.0.sh "$1"/vagrantconfig)
    $(cp web-bootstrap-apache-latest-php-7.4.centoos8.sh "$1"/vagrantconfig)
    $(cd $1 && vagrant init sd-Centos8Php74fci)
}
instalCore()
{
    $(cp Vagrantfilecopy "$1")
    $(cd $1 && mv Vagrantfilecopy Vagrantfile)
    dir=`eval echo $1 `
    projectDIRECTORY=$(echo "$dir"| sed 's/\//\\\//g')
    dir2=`eval echo $2 `
    cmsDIRECTORY=$(echo "$dir2"| sed 's/\//\\\//g')
    $(sed -ie "s/corecmsDir=\"~\/Documents\/\"/corecmsDir=\"$cmsDIRECTORY\"/g" $1/Vagrantfile)
    $(rm $1/Vagrantfilee)
}
zero(){
    if [ ! -d ~/Documents/core-cms ] 
    then
        $(git -C ~/Documents clone ssh://.../core-cms.git) #clone the core 
    fi
}
one(){
	echo "use ./checksumValidation.sh for validation."
    sh ./checksumValidation.sh
        pause
}
 
# do something in two()
two(){
    sh ./corecms.sh "$2" "$username"
    pause
}

three(){
    if [ -d $1 ] 
    then
        echo "Directory $1 already exists. Run ./menu.sh with different input."
       pause
        exit
    fi 
    addvagrantbox
    preperDir
    sh ./newvagrantinfo.sh $1 'No' 
    pause
}
fourA(){
    if [ -d $1 ] 
    then
        echo "Directory $1 already exists. Run ./menu.sh with different input."
       pause
        exit
    fi
    echo $BASEDIR 
    # echo $2
    # echo $username
    sh ./corecms.sh "$2" "$username"
    addvagrantbox
    preperDir $1
}
four(){
    fourA $1 $2;
    preperDir $1
    instalCore $1 $2
    sh ./newvagrantinfo.sh $1 'No' 
    pause
}
five(){
    echo $BASEDIR
    fourA $1 $2;
    $(cd $1 && vagrant up | tee -a /dev/tty)
    $(mkdir -p "$1"/freshnewsite.co.uk)
    $(cd "$1" && vagrant plugin install vagrant-rsync-back)
    instalCore $1 $2
    $(cd "$1" && vagrant rsync-back)
    sh ./newvagrantinfo.sh $1 'no'
    cd $1 && vagrant ssh -t --command 'cd /var/www/vhosts/freshnewsite.co.uk; composer config repositories.core-cms path /opt/core-cms '
    cd $1 && vagrant ssh -t --command 'cd /var/www/vhosts/freshnewsite.co.uk; composer require sdsomersetdesign/core-cms dev-master '
    cd $1 && vagrant ssh -t --command 'cd /var/www/vhosts/freshnewsite.co.uk; php artisan core-cms:install '
    $(cd "$1"/freshnewsite.co.uk  && npm install)
    $(cd "$1"/freshnewsite.co.uk && npm run dev)
    cd $BASEDIR && sh ./newvagrantinfo.sh $1 'Yes'
    pause
}
# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo ""
	echo ""	
	echo "host - info "
    echo "Node.js : $(which node)"
    echo "Vagrant : $(vagrant -v)" 
    echo "Vagrant Plugin:" 
    echo "$(vagrant plugin list)"
    echo ""
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Validation Vagrant box."
    echo "2. Core CSM."
    echo "3. New Vagrant Machine only"
    echo "4. New Vagrant Machine with Core Cms"
    echo "5. New Vagrant Machine with test site"
	echo "6. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
	read -p "Enter choice [ 1 - 6] " choice
	case $choice in
		1) one ;;
		2) two $1 $2;;
		3) three $1;;
        4) four $1 $2;;
        5) five $1 $2;;
        6) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
 
	show_menus
	read_options $1 $2
done