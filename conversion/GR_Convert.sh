
#!/bin/zsh

# DGR_Convert.sh
# Convert video for Apple // playback

# Input video can be downloaded from YouTube using the following website
# https://v24.www-y2mate.com/

input="$1"

rm -rf ~/Desktop/out1
mkdir ~/Desktop/out1

echo "Extracting Frames from : $input"
ffmpeg -i "$input" -vf "crop=ih/3*4:ih,scale=40:48" /Users/frank/Desktop/out1/FRAME.%05d.bmp

find ~/Desktop/out1 -type f -print0 | sort -zf | while IFS= read -r -d '' f; do
  echo;echo "Processing Frame: $f";echo
  /Users/frank/Documents/GitHub/b2d/b2d "$f" L D9 V0 A
  # DL=Double Lores, D=Dither 9 (Buckels), V= ???, A=Alternate output
done

rm ~/Desktop/VIDEO#5B1001

find ~/Desktop/out1 -name "FRAME.*.SL2" | sort -V | while read -r f; do
  echo "Condensing Frame: $f"
  cat "$f" >> "$HOME/Desktop/VIDEO#5b1001"  # NAPS - NuLib2 Attribute Preservation String
  printf '\x00\x00\x00\x00\x00\x00\x00\x00' >> "VIDEO#5b1001"
  # pad last screen hole so frames align. b2d explicitly leaves this out of SL2 files.
done
