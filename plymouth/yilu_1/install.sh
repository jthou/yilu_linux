#!/bin/bash
sudo cp -r $PWD/../yilu_1/ /usr/share/plymouth/themes 
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/yilu_1/yilu_1.plymouth 100
sudo update-alternatives --config default.plymouth 
sudo update-initramfs -u

