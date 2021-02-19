#!/bin/bash -e
if [ "$#" != "3" ]; then
	echo "usage: $0 <decrypted OS dump> <output.tns> <N or C for non-cas/cas>"
	exit 1
fi
echo "Compiling patchfinder"
javac Find900a0000.java
rm -f patches.h odump.txt a.elf part2 "$2"
echo "Disassembling OS dump and finding CAS patches"
arm-none-eabi-objdump -EL -D -b binary --adjust-vma=0x10000000 -m arm -M reg-names-raw "$1" | java -Xms256m -Xmx1g Find900a0000 "$3" > patches.h
echo "Getting OS version check value"
osvc="0x`dd if="$1" bs=4 count=1 skip=8 2>/dev/null | hexdump | head -n 1 | awk '{print $5$4$3$2}'`"
echo "Compiling patcher"
arm-none-eabi-gcc -mcpu=arm926ej-s -nostdlib -fPIC -ffreestanding -Os -DOS_VALUE_CHECK=$osvc main.c -o a.elf
arm-none-eabi-objcopy --only-section=.text --output-target binary a.elf part2
(printf "PRG\0"; cat part2) > "$2"
rm -f a.elf part2 *.class
echo "Done!"
