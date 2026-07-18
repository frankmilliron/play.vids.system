#!/bin/zsh

# Convert video for Apple // playback

# Input video can be downloaded from YouTube using the following website
# https://v24.www-y2mate.com/

usage="\
Apple II Video Conversion

usage: $0 format infile outname

Formats are:
   GR   - low resolution (40x48, 16 color)
   DGR  - double low resolution (80x48, 16 color)
   HGR  - high resolution (140x192, 6 color)
   DHGR - double high resolution (140x192, 16 color)
"

# ============================================================

# Exit on error
set -e

# ============================================================
# Verify dependencies

whence ffmpeg > /dev/null || ( echo "ffmpeg not found" 2>&1 ; exit 1 )

whence b2d > /dev/null || ( echo "b2d not found" 2>&1 ; exit 1 )

# ============================================================
# Process arguments

if [[ $# -eq 0 ]]; then
  echo "$usage" ; exit 0
fi

# TODO: Insert optional argument parsing here

if [[ $# -ne 3 ]]; then
  echo "$0: invalid arguments" 1>&2 ; exit 1
fi

format="$1"
input="$2"
outname="$3"

# Suffix is NuLib2 Attribute Preservation String (NAPS)

case "$format" in
  GR)
    suffix="#5B1001"
    b2dformat="L"
    # "A"lternate format generates .SL2 files. The non-alternate
    # format generates a single file with all screen holes elided.
    b2dsuffix="SL2"
    b2dalt="A"
    scale="40:48"
    ;;
  DGR)
    suffix="#5B1002"
    b2dformat="DL"
    # "A"lternate format generates .DL1 and .DL2 files. The
    # non-alternate format generates a single file with all screen
    # holes elided.
    b2dsuffix="DL[12]"
    b2dalt="A"
    scale="80:48"
    ;;
  HGR)
    suffix="#5B1003"
    b2dformat="H"
    b2dsuffix="BIN"
    b2dalt=""
    scale="140:192"
    ;;
  DHGR)
    suffix="#5B1004"
    b2dformat="D"
    b2dsuffix="A2FC"
    b2dalt=""
    scale="280:192"
    ;;
  *)
    echo "$0: invalid format" 1>&2 ; exit 1
    ;;
esac

if [[ ! -e "$input" ]]; then
  echo "$0: input file not found: $input" 1>&2 ; exit 1
fi

output="$outname$suffix"

if [[ -e "$output" ]]; then
  echo "$0: output file $output already exists" 1>&2 ; exit 1
fi

tempdir=$(mktemp -d "${TMPDIR:-/tmp}/pkg.XXXXXXXXX")
test -d "${tempdir}" || (echo "$0: cannot make tempdir" 1>&2 ; exit 1)
trap "rmdir $tempdir" EXIT

# ============================================================
# Use ffmpeg to extract frames

echo "Extracting frames from: $input"

fps="2"
loglevel="error"
start="00:00"
end="20:00"

ffmpeg -i "$input" -ss "$start" -t "$end" -loglevel "$loglevel" \
       -vf "minterpolate='mi_mode=mci:mc_mode=aobmc:vsbmc=1:fps=$fps',crop=ih/3*4:ih,scale=$scale" \
       "$tempdir/FRAME.%05d.bmp"

# ============================================================

nframes=$(find "$tempdir" -type f -name "FRAME.*.bmp" | wc -l | xargs)

echo "Processing $nframes frames..."

find "$tempdir" -type f -print0 | sort -zf | while IFS= read -r -d '' f; do
  echo "Processing frame: $f"
  dither="9" # Buckels
  b2d "$f" "$b2dformat" D"$dither" "$b2dalt" > /dev/null
  rm "$f"
done

# ============================================================

echo "Building: $output"

find "$tempdir" -name "FRAME.*.$b2dsuffix" | sort -V | while read -r f; do
  #echo "Concatenating frame: $f"
  cat "$f" >> "$output"
  rm "$f"

  if [[ "$b2dformat" = "L" || "$b2dformat" = "DL" ]]; then
    # pad last screen hole so frames align. b2d explicitly leaves this out of low resolution / double low resolution files
    printf '\x00\x00\x00\x00\x00\x00\x00\x00' >> "$output"
  fi
done

bytes=$(wc -c "$output" | awk '{print $1;}')
if [[ $bytes -lt $(( 1024 * 128 )) ]]; then
  echo "$0: file is not large enough to be a tree"
  rm "$output"
fi
