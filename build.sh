#!/bin/bash

sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y install ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip libpython3-dev qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev python3-setuptools python3-pyelftools python3-mako libfuse-dev libtiff-dev

git clone https://github.com/friendlyarm/kernel-rockchip.git -b nanopi6-v6.1.y kernel-rockchip
git clone https://github.com/coolsnowwolf/lede
cd kernel-rockchip
git apply ../lede/target/linux/generic/hack-6.1/910-kobject_uevent.patch
git apply ../lede/target/linux/generic/hack-6.1/911-kobject_add_broadcast_uevent.patch
git apply ../lede/target/linux/generic/pending-6.1/100-compiler.h-only-include-asm-rwonce.h-for-kernel-code.patch
cd lede

sed -i '$a src-git video https://github.com/openwrt/video' feeds.conf.default
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

sed -i '/\$(Package\/ariang\/install)/d' package/feeds/packages/ariang/Makefile
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

svn co https://github.com/jjm2473/packages/trunk/multimedia/rkmpp package/feeds/packages/rkmpp
svn co https://github.com/jjm2473/packages/trunk/multimedia/rkrga package/feeds/packages/rkrga

mkdir -p files/root
pushd files/root
git clone https://github.com/robbyrussell/oh-my-zsh .oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions .oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions .oh-my-zsh/custom/plugins/zsh-completions
cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc
sed -i 's/plugins=(git)/plugins=(git command-not-found extract z docker zsh-syntax-highlighting zsh-autosuggestions zsh-completions)/g' .zshrc
popd

mkdir -p files/etc/opkg
cp ../distfeeds.conf files/etc/opkg/distfeeds.conf

cp ../init-settings.sh files/root/init-settings.sh
mkdir -p files/etc
cp ../rc.local files/etc/rc.local


mkdir -p files/etc/config
pushd files/etc/config
curl -H "Authorization: $AUTHORIZATION" https://file.jasontsang.dev:4096/Download/archive/NanoPi-R4S-Rebuild/etc/config/fstab > fstab
popd

mkdir -p files/root/my-defaults
pushd files/root/my-defaults
curl -H "Authorization: $AUTHORIZATION" https://file.jasontsang.dev:4096/Download/archive/NanoPi-R4S-Rebuild/init-settings.sh > 99-init-settings
popd


sed -i '30c \ \ \ \ tristate "SND_COMPRESS_OFFLOAD"' ../kernel-rockchip/sound/core/Kconfig
sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=6.1/g' target/linux/rockchip/Makefile
cp ../files/target/linux/rockchip/armv8/config-6.1 target/linux/rockchip/armv8/config-6.1
cp ../files/arch/arm64/boot/dts/rockchip/Makefile ../kernel-rockchip/arch/arm64/boot/dts/rockchip/Makefile
cp ../files/target/linux/rockchip/image/armv8.mk target/linux/rockchip/image/armv8.mk
rm -rf target/linux/rockchip/modules.mk
cp ../files/.config .config
make defconfig

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make download -j8
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make V=sc -j1