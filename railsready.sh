#!/bin/bash
#
# Rails Ready
#
# Author: Josh Frye <joshfng@gmail.com>
# Licence: MIT
#
# Contributions from: Wayne E. Seguin <wayneeseguin@gmail.com>
# Contributions from: Ryan McGeary <ryan@mcgeary.org>
#
shopt -s nocaseglob
set -e

ruby_version="1.9.2"
ruby_version_string="1.9.2p136"
ruby_source_url="ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p136.tar.gz"
ruby_source_tar_name="ruby-1.9.2-p136.tar.gz"
ruby_source_dir_name="ruby-1.9.2-p136"
script_runner=$(whoami)
railsready_path=$(cd && pwd)/railsready
log_file="$railsready_path/install.log"
distro_sig=$(cat /etc/issue)

control_c()
{
  echo -en "\n\n*** Exiting ***\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT

echo -e "\n\n"
echo "#################################"
echo "########## Rails Ready ##########"
echo "#################################"

#determine the distro
if [[ $distro_sig =~ ubuntu ]] ; then
  distro="ubuntu"
elif [[ $distro_sig =~ centos ]] ; then
  distro="centos"
else
  echo -e "\nRails Ready currently only supports Ubuntu and CentOS\n"
  exit 1
fi

#now check if user is root
if [ $script_runner == "root" ] ; then
  echo -e "\nThis script must be run as a normal user with sudo privileges\n"
  exit 1
fi

echo -e "\n\n"
echo "!!! This script will update your system! Run on a fresh install only !!!"
echo "run tail -f $log_file in a new terminal to watch the install"

echo -e "\n"
echo "What this script gets you:"
echo " * An updated system"
echo " * Ruby $ruby_version_string"
echo " * Imagemagick"
echo " * libs needed to run Rails (sqlite, mysql, etc)"
echo " * Bundler, Passenger, and Rails gems"
echo " * Git"

echo -e "\nThis script is always changing."
echo "Make sure you got it from https://github.com/joshfng/railsready"

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $script_runner has no sudo privileges ; exit 1; }

# Ask if you want to build Ruby or install RVM
echo -e "\n"
echo "Build Ruby or install RVM?"
echo "=> 1. Build from souce"
echo "=> 2. Install RVM"
echo -n "Select your Ruby type [1 or 2]? "
read whichRuby

if [ $whichRuby -eq 1 ] ; then
  echo -e "\n\n!!! Set to build Ruby from source and install system wide !!! \n"
elif [ $whichRuby -eq 2 ] ; then
  echo -e "\n\n!!! Set to install RVM for user: $script_runner !!! \n"
else
  echo -e "\n\n!!! Must choose to build Ruby or install RVM, exiting !!!"
  exit 1
fi

echo -e "\n=> Creating install dir..."
cd && mkdir -p railsready/src && cd railsready && touch install.log
echo "==> done..."

echo -e "\n=> Ensuring there is a .bashrc and .bash_profile..."
sudo touch $HOME/.bashrc && sudo touch $HOME/.bash_profile
echo "==> done..."

echo -e "\n=> Downloading and running recipe for $distro...\n"
#Download the distro specific recipe and run it, passing along all the variables as args
sudo wget --no-check-certificate -O $railsready_path/src/$distro.sh https://github.com/joshfng/railsready/raw/master/recipes/$distro.sh && cd $railsready_path/src && bash $distro.sh $ruby_version $ruby_version_string $ruby_source_url $ruby_source_tar_name $ruby_source_dir_name $whichRuby $railsready_path $log_file
echo -e "\n==> done running $distro specific commands..."

#now that all the distro specific packages are installed lets get Ruby
if [ $whichRuby -eq 1 ] ; then
  # Install Ruby
  echo -e "\n=> Downloading Ruby $ruby_version_string \n"
  cd $railsready_path/src && wget $ruby_source_url
  echo -e "\n==> done..."
  echo -e "\n=> Extracting Ruby $ruby_version_string"
  tar -xzf $ruby_source_tar_name >> $log_file 2>&1
  echo "==> done..."
  echo -e "\n=> Building Ruby $ruby_version_string (this will take awhile)..."
  cd  $ruby_source_dir_name && ./configure --prefix=/usr/local >> $log_file 2>&1 \
   && make >> $log_file 2>&1 \
    && sudo make install >> $log_file 2>&1
  echo "==> done..."
elif [ $whichRuby -eq 2 ] ; then
  #thanks wayneeseguin :)
  echo -e "\n=> Installing RVM the Ruby enVironment Manager http://rvm.beginrescueend.com/rvm/install/ \n"
  curl -O -L http://rvm.beginrescueend.com/releases/rvm-install-head
  chmod +x rvm-install-head
  "$PWD/rvm-install-head" >> $log_file 2>&1
  [[ -f rvm-install-head ]] && rm -f rvm-install-head
  echo -e "\n=> Setting up RVM to load with new shells..."
  #if RVM is installed as user root it goes to /usr/local/rvm/ not ~/.rvm
  echo  '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # Load RVM into a shell session *as a function*' >> ~/.bashrc
  echo "==> done..."
  echo "=> Loading RVM..."
  source ~/.rvm/scripts/rvm
  source ~/.bashrc
  echo "==> done..."
  echo -e "\n=> Installing Ruby $ruby_version_string (this will take awhile)..."
  echo -e "=> More information about installing rubies can be found at http://rvm.beginrescueend.com/rubies/installing/ \n"
  rvm install $ruby_version >> $log_file 2>&1
  echo -e "\n==> done..."
  echo -e "\n=> Using 1.9.2 and setting it as default for new shells..."
  echo "=> More information about Rubies can be found at http://rvm.beginrescueend.com/rubies/default/"
  rvm --default use $ruby_version >> $log_file 2>&1
  echo "==> done..."
else
  echo "How did you even get here?"
  exit 1
fi

# Reload bash
echo -e "\n=> Reloading shell so ruby and rubygems are available..."
source ~/.bashrc
echo "==> done..."

echo -e "\n=> Installing Bundler, Passenger and Rails.."
if [ $whichRuby -eq 1 ] ; then
  sudo gem install bundler passenger rails --no-ri --no-rdoc >> $log_file 2>&1
elif [ $whichRuby -eq 2 ] ; then
  gem install bundler passenger rails --no-ri --no-rdoc >> $log_file 2>&1
fi
echo "==> done..."

echo -e "\n#################################"
echo    "### Installation is complete! ###"
echo -e "#################################\n"

echo -e "\n !!! logout and back in to access Ruby or run source ~/.bashrc !!!\n"

echo -e "\n Thanks!\n-Josh\n"
