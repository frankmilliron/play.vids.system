#!/usr/bin/env bash

# Exit on error
set -e

# Uncomment to log commands as they are executed
#set -x

# Original path for "cadius"
CADIUS=$(which cadius)

# Run Cadius but suppress standard output unless (1) the exit code is
# non-zero or (2) the output contains "Error :". If either of those is
# true, the output is printed to standard error, in red.
function cadius {
  set +e
  local result
  result=$($CADIUS "$@")
  if [ $? -ne 0 ]; then
    echo $(tput setaf 1)"$result"$(tput sgr0) >&2
    exit 1
  fi
  if [[ "$result" == *"Error :"* ]]; then
    echo $(tput setaf 1)"$result"$(tput sgr0) >&2
    exit 1
  fi
  set -e
}

# set up variables

imagename=VIDS.hdv
prodos_vol=VIDS
outpath=out
image=$outpath/$imagename
prodos_path="/$prodos_vol"

prodos_sysdisk_image=res/ProDOS_2_4_3.po
prodos_sysdisk_path="/PRODOS.2.4.3"

function add_video {
  cadius ADDFILE $image $prodos_path "$@"
}

mkdir -p $outpath

# delete old versions & set up new disk image
rm -f "$image"

cadius CREATEVOLUME $image $prodos_vol 32MB

# add videos
if [ -f "add_videos.sh" ]; then
  # To build an image with specific videos, create a file named "add_videos.sh" with
  # lines of the form: add_video PATH/NAME#TYPE
  source "add_videos.sh"
else
  # Test videos
  add_video examples/COLORCYCLE.GR#5B1001
  add_video examples/COLORCYCLE.DGR#5B1002
  add_video examples/COLORCYCLE.HGR#5B1003
  add_video examples/COLORCYCLE.DHGR#5B1004
  add_video examples/BLUEMONDAY.GR#5B1001
  add_video examples/BLUEMONDAY.DGR#5B1002
  add_video examples/BLUEMONDAY.HGR#5B1003
  add_video examples/BLUEMONDAY.DHGR#5B1004
fi

# add QUIT.SYSTEM to drop to Bitsy Bye on boot
cadius EXTRACTFILE $prodos_sysdisk_image "$prodos_sysdisk_path/QUIT.SYSTEM" $outpath
cadius ADDFILE $image $prodos_path "$outpath/QUIT.SYSTEM#FF2000"

# assemble video player & add it
acme --outfile $outpath/BASIS.SYSTEM#FF0000 --report $outpath/play.vids.system.listing play.vids.system.a
cadius ADDFILE $image $prodos_path $outpath/BASIS.SYSTEM#FF0000

# add PRODOS to make it bootable
cadius EXTRACTFILE $prodos_sysdisk_image "$prodos_sysdisk_path/PRODOS" $outpath
cadius ADDFILE $image $prodos_path "$outpath/PRODOS#FF0000"

cadius CHECKVOLUME $image
$CADIUS CATALOG $image
