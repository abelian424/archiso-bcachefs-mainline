# archiso-bcachefs-mainline
A version of [vale981](https://github.com/vale981/archiso-bcachefs)'s repo to allow building bcachefs with a variety of available kernels on AUR. I recommend you go into the packages directory and build the packages before running make_iso.sh. You have to run chmod +x ./makeiso.sh before you can use make_iso.sh Here is the readme by vale981, modified for this repo:

# Archlinux Live with Bcachefs

The scripts in this repo can be used to obtain an `Arch Linux`
live/install/rescue ISO. This is realized through
[Archiso](https://wiki.archlinux.org/index.php/Archiso) with some
hacks to make it use the `linux-bcachefs-git` [from the
AUR](https://aur.archlinux.org/packages/linux-bcachefs-git).

The whole thing is currently in a *works for me* kind of state.

## Usage
I recommend that you at least skim the scripts in this repo to understand what is happening, because they require `root` access. You can either build the iso directly on arch, or use docker to provide an arch environment.

* The script will build the linux bcachefs kernel from the AUR and you
     set the architecture to build the kernel interactively, whenever
     the prompt comes up. I will add a variable to the `make_iso.sh`
     script when I come around to it...
* In the end, the ISO can be found under `archlive/out`
* The live ISO will have the built bcachefs packages in the root directory.

### On Arch Linux
 * make sure you have the following installed: `archiso sudo git base-devel bash`
   <!-- * or set the `KERNEL_ARCH` variable in the `make_iso.sh` script -->
 * run `chmod +x ./make_iso.sh`
 * run `./make_iso.sh` and get a cup of whatever hot beverage you favor

## Installing Arch Linux on Bcachefs

Just boot the resulting ISO and follow the installation as usual.
There are (at least) two (trivial) points to be considered however:
  1. After having formated your disk with `bcachefs create` you must
     mount it with `mount -t bcachefs`. In other words: You have to
     specify the fs type manually.
  2. When installing the base system with `pacstrap`, specify
     `linux-bcachefs-git` instead of `linux`.
