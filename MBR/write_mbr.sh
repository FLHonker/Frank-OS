#!/bin/bash

dd if=mbr3_Loader.bin of=/home/frank/Developer/bochs-2.6.9/bin/hd60M.img bs=512 count=1 conv=notrunc
dd if=Loader_1.bin of=/home/frank/Developer/bochs-2.6.9/bin/hd60M.img bs=512 count=1 seek=2 conv=notrunc
