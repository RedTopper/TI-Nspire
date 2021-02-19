#!/bin/bash
os=$1
out=$2
ex=`echo "$os" | sed 's/.*\.//'`
if [ "$ex" = "tco" ]; then 
	m="/MX"
elif [ "$ex" = "tcc" ]; then 
	m="/MXC"
else 
	echo Unsupported OS ; exit 1
fi
echo "Dumping OS..."
b15e="$(dirname "$0")/../boot1.5_exploit"
rm -f os.bin cut.bin *.class
echo "Press I on the emulated calculator's keyboard when prompted."
cat << 'EOF' | wine "$(dirname "$0")/../nspire_emu.exe" /1="$b15e/Boot1CX.img" /R /N /PB="$b15e/tinspirecx_boot2_4.0.3.49.img.tns" /PO="$1" "$m" /D >/dev/null 2>&1
k 10000000
c
wm os.bin 10000000 2000000
q
EOF
set -e # for some reason wine exits 1
echo "Cutting OS out of RAM dump"
javac CutOS.java
java -Xms64m -Xmx256m CutOS os.bin cut.bin
rm -f os.bin *.class
rm -f "$2"
mv cut.bin "$2"
echo "Dumped $2 successfully."
