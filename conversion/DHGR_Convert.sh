
#!/bin/zsh

# DHGR_Convert.sh
# Convert video for Apple // playback

# Input video can be downloaded from YouTube using the following website
# https://v24.www-y2mate.com/

input="$1"

rm -rf ~/Desktop/out4
mkdir ~/Desktop/out4

echo "Extracting Frames from : $input"
ffmpeg -i "$input" -vf "crop=ih/3*4:ih,scale=280:192" ~/Desktop/out4/FRAME.%05d.bmp

find ~/Desktop/out4 -type f -print0 | sort -zf | while IFS= read -r -d '' f; do
  echo;echo "Processing Frame: $f";echo
  /Users/frank/Documents/GitHub/b2d/b2d "$f" D D9 V0
  # D=Double Hires, D=Dither 9 (Buckels), V= ???
done

rm ~/Desktop/VIDEO#5b1004

find ~/Desktop/out4 -name "FRAME.*.A2FC" | sort -V | while read -r f; do
  echo "Condensing Frame: $f"
  cat "$f" >> "$HOME/Desktop/VIDEO#5b1004"  # NAPS - NuLib2 Attribute Preservation String
done
