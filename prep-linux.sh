#!/bin/bash
# Perform basic preparation for a Linux box.
# Supported flavors: Debian (Wheezy) / Raspbian (Wheezy)
#                    Ubuntu (Quantal)
#                    CentOS (6)
# Note: This is not fully unattended, you will have to be
# around to type passwords!
# Raymond Colebaugh

function usage {
   echo "This script does some basic set up work. It requires a "
   echo "user name to create and add to sudo."
   echo "Usage: $0 <username>"
}

if [ $# -ne 1 ]; then
   usage
   exit 1
fi

# Set inputs
USER="$1"
FLAVOR=`head -1 /etc/issue | cut -d' ' -f1`

# Get up to date initially...
echo "Updating..."
if [ "$FLAVOR" == "Debian" -o "$FLAVOR" == "Raspbian" ]; then
   if [ "$FLAVOR" == "Debian" ]; then
      echo "Enabling contrib and non-free repos..."
      sed -i 's/^\(deb.*\)$/\1 contrib non-free/g' /etc/apt/sources.list
      grep '^[^#].*cdrom:' /etc/apt/sources.list
      if [ $? -eq 0 ]; then
         echo "Disabling cdrom APT source..."
         sed -i '/^[^#].*cdrom:/ s/^/#/g' /etc/apt/sources.list
      fi
   fi
   apt-get update && apt-get upgrade -y
   apt-get install -y sudo wget curl gcc gdb make \
      build-essential libncurses5-dev subversion git \
      puppet-common screen tree
elif [ "$FLAVOR" == "Ubuntu" ]; then
   apt-get update && apt-get upgrade -y
   apt-get install -y gcc curl gdb make man-db manpages subversion \
      git libncurses-dev screen puppet-common
elif [ "$FLAVOR" == "CentOS" ]; then
   yum update -y
   yum install -y sudo wget curl bzip2 gcc gcc-c++ gdb make patch \
      ncurses-devel openssh-clients subversion git tar scp tree
   echo "Enabling EPEL yum repo..."
   wget http://mirror.steadfast.net/epel/6/i386/epel-release-6-8.noarch.rpm
   rpm -i epel-release-6-8.noarch.rpm && rm epel-release-6-8.noarch.rpm
   yum update -y
   yum install -y puppet
fi

echo "Set a strong password for root! (^D to skip)"
passwd

# Create a user for the sysadmin
grep "$USER" /etc/passwd
if [ $? -eq 0 ]; then
   echo "User already exists."
else
   echo "User does not exist. Adding user $USER..."
   useradd -m -d /home/$USER -s /bin/bash $USER
   echo "Now set another (different) strong password for $USER."
   passwd $USER
fi

if [ -d /etc/sudoers.d ]; then
   echo "Adding user to sudoers file..."
   cat <<-CONF > /etc/sudoers.d/$USER
   $USER		ALL=(ALL:ALL) ALL
CONF
elif [ -f /etc/sudoers ]; then
   grep "$USER" /etc/sudoers
   if [ $? -eq 0 ]; then
      echo "User already granted sudo, skipping."
   else
      echo "Adding user to sudoers file..."
      echo "$USER		ALL=(ALL:ALL) ALL" >> /etc/sudoers
   fi
fi

echo "Locking down sshd..."
sed -i 's/^#*\(PermitRootLogin\s\)yes$/\1no/' /etc/ssh/sshd_config
sed -i 's/^#*Protocol.*$/Protocol 2/g' /etc/ssh/sshd_config
grep "AllowUsers" /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
   sed -i "s/^#*\(AllowUsers.*\)$/\1 $USER/g" /etc/ssh/sshd_config
else
   echo "AllowUsers $USER" >> /etc/ssh/sshd_config
fi
