#!/bin/bash -e
if [ "$#" != "3" ]; then
	echo "usage: $0 <decrypted OS dump> <output.h> <N or C for non-cas/cas>"
	exit 1
fi
echo "Compiling patchfinder"
javac Find900a0000.java
rm -f patches.h odump.txt a.elf part2 "$2"
echo "Disassembling OS dump and finding CAS patches"
arm-none-eabi-objdump -EL -D -b binary --adjust-vma=0x10000000 -m arm -M reg-names-raw "$1" | java -Xms256m -Xmx1g Find900a0000 "$3" > patches.h
echo "Compiling patcher"
arm-none-eabi-gcc -mcpu=arm926ej-s -nostdlib -fPIC -ffreestanding -Os -DOS_VALUE_CHECK=$osvc mainforloader.c -o a.elf
echo "Creating header"
hn=`basename "$2" | cut -d . -f 1`
arm-none-eabi-objcopy --only-section=.text --output-target binary a.elf "$hn"
xxd -i "$hn" > "$2"
rm -f a.elf "$hn" *.class
echo "Done!"
