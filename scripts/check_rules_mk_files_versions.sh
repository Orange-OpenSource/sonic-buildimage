#!/bin/sh

cd $(dirname $0)
cd ..
rootdir=$(pwd)
for pkgsrcname in isc-dhcp debootstrap bash kdump-tools lm-sensors snmpd iptables hiredis; do
    basevarname=$(echo $pkgsrcname"_VERSION" | tr [a-z\-] [A-Z_])

    cd $rootdir/src/$pkgsrcname/

    i=0
    # retrieve current version values of package sources from makefile rules
    # usually there is only one value configured but there are some exceptions such as snmpd
    # versions differ between the target debian versions -> loop required in that case
    for line in $(grep "^$basevarname =" ../../rules/$pkgsrcname.mk | sed -e 's/ *= */=/'); do
         i=$((i+1))
         value=$(echo $line | sed 's/.*= *//g')
         eval "$basevarname=$value"
	 # we assume the full versions appears in the same order
         eval $(grep "^$basevarname\_FULL =" ../../rules/$pkgsrcname.mk | sed -e 's/ *= */=/' | head -$i | tail -1)
         # before parsing with awk regex, apply backslash to dots and plus to avoid ambiguous detection
         eval "versionpattern=\$(echo \$$basevarname | sed -e 's/"'\./\\\\.'"/g' -e 's/"'\+/\\\\+/g'"')"

         # next, use eval and awk to parse 'apt-cache showsrc' output and retrieve available versions from debian repositories
         # pipe result to a unique and version sort (-u and -V options) and tail to get the last version
         eval $(echo "version=\$(apt-cache -c ../../alt_apt_confdir/etc/apt/apt.conf showsrc $pkgsrcname | awk  -F\"[' ]\" '/^Version: (1:)*$versionpattern[^0-9]*/{print \$2}' | cut -d: -f2- | sort -uV | tail -1)")
         # previous line will be interpreted as follow (modulo package name and version changes)
         # version=$(apt-cache -c ../../alt_apt_confdir/etc/apt/apt.conf showsrc isc-dhcp | awk  -F"[' ]" '/^Version: (1:)*4\.4\.1[^0-9]*/{print $2}' | cut -d: -f2- | sort -uV |tail -1)
         if [ -z "$version" ]; then
             eval echo "ERROR No candidate version in apt sources for $pkgsrcname \$$basevarname. Exiting" >&2
             exit 3
         fi
         if [ "$version" != "$(eval echo \$$basevarname\_FULL)" ]; then
             echo "WARNING $(eval echo \$$basevarname\_FULL) and latest version $version differs." >&2
             eval backslashedfullversion=$(echo "\$(echo \$$basevarname\_FULL| sed 's/\./\\\\./g')")
             if [ -z "$(eval "apt-cache -c ../../alt_apt_confdir/etc/apt/apt.conf showsrc $pkgsrcname | grep '^Version: \(1:\)*$backslashedfullversion$'")" ];then
                 echo "WARNING No candidate version in apt sources for $(eval echo \$$basevarname\_FULL). Updating rules/$pkgsrcname.mk to use latest version $version instead." >&2
                 linenumber=$(grep -n "^$basevarname\_FULL =" ../../rules/$pkgsrcname.mk | head -$i | tail -1 | cut -d: -f1)
                 sed -i_ "$linenumber,+0s/^$basevarname\_FULL = .*/$basevarname\_FULL = $version/g" ../../rules/$pkgsrcname.mk
             fi
         fi
    done
done
