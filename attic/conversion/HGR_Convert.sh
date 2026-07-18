
#!/bin/zsh

# HGR_Convert.sh
# Convert video for Apple // playback

# Input video can be downloaded from YouTube using the following website
# https://v24.www-y2mate.com/

input="$1"

rm -rf ~/Desktop/out3
mkdir ~/Desktop/out3

echo "Extracting Frames from : $input"
ffmpeg -i "$input" -ss 0:00 -t 20:00 -vf "minterpolate='mi_mode=mci:mc_mode=aobmc:vsbmc=1:fps=10',crop=ih/3*4:ih,scale=140:192" ~/Desktop/out3/FRAME.%05d.bmp

find ~/Desktop/out3 -type f -print0 | sort -zf | while IFS= read -r -d '' f; do
  echo;echo "Processing Frame: $f";echo
  /Users/frank/Documents/GitHub/b2d/b2d "$f" H D9 V0
  # D=Double Hires, D=Dither 9 (Buckels), V= ???
done

rm ~/Desktop/VIDEO#5B1003

find ~/Desktop/out3 -name "FRAME.*.BIN" | sort -V | while read -r f; do
  echo "Condensing Frame: $f"
  cat "$f" >> "$HOME/Desktop/VIDEO#5B1003"  # NAPS - NuLib2 Attribute Preservation String
done
