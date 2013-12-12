#!/bin/bash
# Deploy jdk from tar.gz
# author: Raymond Colebaugh

FILE="$1"
TARGET="/opt"

function usage {
  echo "Usage: A Path to the jdk is required. Installs to /opt by default."
  echo "$0 path-to-jdk.tar.gz [/install-path]"
  }

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

echo "Extracting..."
tar -zxf $FILE
JAVADIR="`ls -d jdk1*`"

echo "Moving to $TARGET..."
if [ -d "${TARGET}/${JAVADIR}" ]; then
  # TODO: add a --force|-f option
  echo "Found existing jdk install. Exiting."
  exit 1
fi

sudo mv ./$JAVADIR $TARGET
JAVADIR="/$TARGET/$JAVADIR"
echo "Removing old links to java in /usr/bin..."
sudo rm -f /usr/bin/java{,c,ws,doc}
echo "Creating new symbolic links..."
sudo ln -s $JAVADIR/bin/java{,c,ws,doc} /usr/bin
sudo ln -s $JAVADIR/bin/jdb /usr/bin
sudo ln -s $JAVADIR/bin/jar /usr/bin

# Set up environment
echo "Checking for presence of JAVA_HOME in /etc/environment..."
grep JAVA_HOME /etc/environment 
if [ $? -eq 0 ] ; then
  echo "Replacing..."
  sudo sed -i '/JAVA_HOME/d' /etc/environment
else
  echo "Not present. Appending..."
fi
sudo su -c "echo 'JAVA_HOME=\"$JAVADIR\"' >> /etc/environment"
echo "Sourcing /etc/environment..."
source /etc/environment
echo "Done."
exit 0
