#!/bin/bash
# Get the latest copies of the JDK from Oracle
# author: Raymond Colebaugh

# TODO getopts
ARCHS="x64"		# Available: x64, i586, sparc, arm
FORMATS="tar.gz"	# Available: tar.gz, rpm, dmg
SYSTEMS="linux"		# Available: linux, solaris, windows, macosx

# Get list of files
# TODO: make this more resilient. i'm sure this url won't be latest for long...
LINKS=`curl http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html | grep filepath | grep -v demos | awk '{print $7}' | cut -d'"' -f5 | grep -E "$ARCHS" | grep -E "$SYSTEMS" | grep -E "$FORMATS" | xargs `

echo " => Selected jdk for $SYSTEMS [$FORMATS $ARCHS]"
echo " => Downloading $LINKS"
for file in $LINKS; do
  wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" $file
done
echo " => Finished."
