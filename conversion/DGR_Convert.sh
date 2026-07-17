
#!/bin/zsh

# DGR_Convert.sh
# Convert video for Apple // playback

# Input video can be downloaded from YouTube using the following website
# https://v24.www-y2mate.com/

input="$1"

rm -rf ~/Desktop/out2
mkdir ~/Desktop/out2

echo "Extracting Frames from : $input"
ffmpeg -i "$input" -ss 0:00 -t 20:00 -vf "minterpolate='mi_mode=mci:mc_mode=aobmc:vsbmc=1:fps=10',crop=ih/3*4:ih,scale=80:48" ~/Desktop/out2/FRAME.%05d.bmp

find ~/Desktop/out2 -type f -print0 | sort -zf | while IFS= read -r -d '' f; do
  echo;echo "Processing Frame: $f";echo
  /Users/frank/Documents/GitHub/b2d/b2d "$f" DL D9 V0 A
  # DL=Double Lores, D=Dither 9 (Buckels), V= ???, A=Alternate (two file, AUX/MAIN) output
done

rm ~/Desktop/VIDEO#5B1002

find ~/Desktop/out2 -name "FRAME.*.DL*" | sort -V | while read -r f; do
  echo "Condensing Frame: $f"
  cat "$f" >> "$HOME/Desktop/VIDEO#5B1002"  # NAPS - NuLib2 Attribute Preservation String
  printf '\x00\x00\x00\x00\x00\x00\x00\x00' >> "$HOME/Desktop/VIDEO#5B1002"
  # pad last screen hole so frames align. b2d explicitly leaves this out of DL1 (Aux)/DL2(Main) files.
done
