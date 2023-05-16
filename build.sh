#!/bin/bash

# sudo apt update -y
# sudo apt full-upgrade -y
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
    genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
    libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
    libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
    python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
    swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev \
    python3-setuptools python3-pyelftools python3-mako libfuse-dev libtiff-dev

git clone https://github.com/coolsnowwolf/lede
cd lede

sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

sed -i '/\$(Package\/ariang\/install)/d' package/feeds/packages/ariang/Makefile
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

mkdir -p files/root
pushd files/root
git clone https://github.com/robbyrussell/oh-my-zsh .oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions .oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions .oh-my-zsh/custom/plugins/zsh-completions
cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc
sed -i 's/plugins=(git)/plugins=(git command-not-found extract z docker zsh-syntax-highlighting zsh-autosuggestions zsh-completions)/g' .zshrc
popd

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

cp ../files/.config .config
make defconfig

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make download -j8
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make V=sc -j1