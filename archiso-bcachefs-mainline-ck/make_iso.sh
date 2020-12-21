#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

ISO_NAME="Arch Linux with bcachefs support."
ISO_PUBLISHER="Valentin Boettcher <hiro at protagon.space>"

ARCH=x86_64
KERNEL_ARCH=
REPO_BASE=$(sudo mktemp -d /var/XXXX-repo)
REPO_DIR=$REPO_BASE/$ARCH
REPO=$REPO_DIR/repo.db.tar.gz
PACKAGE_DIR=$DIR/packages
WORKDIR=$DIR/archlive/

function cleanup {
    sudo rm -r $REPO_BASE
}

trap cleanup EXIT

echo "Init Workdir"
echo "============"

echo "Removing $WORKDIR"
sudo rm -rf $WORKDIR
cp -r /usr/share/archiso/configs/releng/ $WORKDIR
#cp $WORKDIR/airootfs/etc/mkinitcpio.d/linux.preset $WORKDIR/airootfs/etc/mkinitcpio.d/linux-bcachefs-ck.preset
#sed -i 's/vmlinuz-linux/vmlinuz-linux-bcachefs-ck/' $WORKDIR/airootfs/etc/mkinitcpio.d/linux-bcachefs-ck.preset
#sed -i 's/initramfs-linux.img/initramfs-linux-bcachefs-ck.img/' $WORKDIR/airootfs/etc/mkinitcpio.d/linux-bcachefs-ck.preset
echo "Adding Packages"
cat >> $WORKDIR/packages.x86_64 <<EOF
libscrypt
bcachefs-tools-git
linux-bcachefs-ck
linux-bcachefs-ck-headers
EOF

#sed -e 's/mkinitcpio//g' $WORKDIR/packages.x86_64

echo "Setting up pacman.conf"
cat >> $WORKDIR/pacman.conf <<EOF
[repo]
SigLevel = Optional TrustAll
Server = file:///$REPO_DIR/
EOF

echo "Init Repo"
echo "========="

sudo mkdir -p $REPO_DIR
mkdir -p $PACKAGE_DIR
sudo ls -l $REPO_BASE
sudo repo-add $REPO

printf "\nBuilding AUR Packages\n"
echo "====================="

# git clone linux-bcachefs-ck
# git clone https://aur.archlinux.org/bcachefs-tools-git.git
# git clone https://aur.archlinux.org/linux-bcachefs-ck.git

function add_aur {
    CURRDIR=$(pwd)
    URL=$1
    INSTALL=$2
    NAME=$(echo $URL | sed -r 's/^.*\.org\/(.*).git$/\1/')

    cd $PACKAGE_DIR
    shopt -s nullglob

    BUILT=( $NAME/*.pkg.* )
    if (( ${#BUILT[@]} )); then
        echo "$NAME already built!"
        cd $NAME
    else
        echo "Building $NAME"
        echo "=============="

        sudo rm -rf $NAME
        git clone $URL
        cd $NAME
        makepkg -sc --noconfirm
    fi

    if [ "$INSTALL" = true ]; then
        sudo pacman -U *.pkg.* --noconfirm --needed
    fi

    sudo repo-add $REPO *.pkg.*
    sudo cp *.pkg.* $REPO_DIR

    # restore
    cd $CURRDIR
    shopt -u nullglob
}

add_aur https://aur.archlinux.org/libscrypt.git true
add_aur https://aur.archlinux.org/bcachefs-tools-git.git
add_aur https://aur.archlinux.org/linux-bcachefs-ck.git
#add_aur https://aur.archlinux.org/dracut-hook.git

printf "\nBuilding the ISO\n"
echo "====================="

sudo mkdir -p $WORKDIR/airootfs/$REPO_BASE
sudo cp -r $REPO_DIR $WORKDIR/airootfs/$REPO_BASE

cd $WORKDIR

#sudo mkarchiso -v -L $ISO_NAME -P $ISO_PUBLISHER -w $WORKDIR/work -o $WORKDIR/out $WORKDIR
sudo mkarchiso -v -w $WORKDIR/work -o $WORKDIR/out $WORKDIR
