#!/bin/bash
# Get the latest copies of the JDK from Oracle
# author: Raymond Colebaugh

# TODO getopts
ARCHS="x64"		# Available: x64, i586, sparc, arm
FORMATS="tar.gz"	# Available: tar.gz, rpm, dmg, exe
SYSTEMS="linux"		# Available: linux, solaris, windows, macosx

get_filelist() {
  # TODO: make this more resilient. i'm sure this url won't
  # be latest for long...
  LINKS=`curl http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html | grep filepath | \
  grep -v demos | awk '{print $7}' | cut -d'"' -f5 | \
  grep -E "$ARCHS" | grep -E "$SYSTEMS" | \
  grep -E "$FORMATS" | xargs`
}

get_checksums() {
  # scrape the checksums page, and parse the results.
  curl http://www.oracle.com/technetwork/java/javase/downloads/java-se-binaries-checksum-1956892.html | \
  grep '<th>MD5 Checksum</th>' | grep jdk | \
  ruby -e "puts STDIN.gets.gsub('</td><td>', ' ').split('<tr>')" | \
  egrep "^<td>.*</tr> $" | sed 's/<\/*t[rd]>//g' > temp_java_sums
}

verify_sum() {
  verified=1
  expected=`grep $1 temp_java_sums | awk '{print $2}'`
  result=`md5sum $1 | awk '{print $1}'`
  if [ "$result" == "$expected" ]; then
    verified=0
  fi
  return $verified
}

dl_and_verify() {
  verified=1
  echo " => Downloading `basename $1`"
  while [ $verified -ne 0 ]; do
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" $1
    verify_sum `basename $1`
    verified="$?"
    if [ $verified -ne 0 ]; then
      echo "Checksum is inaccurate! Retrying..."
    fi
  done
}

cleanup() {
  echo "Cleaning up..."
  rm -f temp_java_sums
  echo " => Finished."
  exit 0
}

get_filelist
get_checksums

echo " => Selected jdk for $SYSTEMS [$FORMATS $ARCHS]"
for file in $LINKS; do
  dl_and_verify $file
done
cleanup
