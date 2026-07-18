# Play.Vids.system

Play video files in all Apple II graphics modes.

Copyright © 2022 by Frank Milliron, Lombard $oftware

Includes a customized version of [ProRWTS2](https://github.com/peterferrie/prorwts2) by Peter Ferrie

## File Format

Video files must have ProDOS type **$5B** (ANM / Animation) and aux type **$100X**, where the last digit determines the resolution:

| Aux Type | Name | Resolution | Colors | Models | Frame Size |
|-|-|-|-|-|-|
| $1001 | Low-resolution (GR) | 40x48 | 16 | all | 0x400 |
| $1002 | Double-low-resolution (DGR) | 80x48 | 16 | IIe/IIc/IIɢꜱ | 0x400 aux, 0x400 main |
| $1003 | High-resolution (HGR) | 140x192[^1] | 6 | all | 0x2000 |
| $1004 | Double-high-resolution (DHGR) | 140x192 | 16 | IIe/IIc/IIɢꜱ | 0x2000 aux, 0x2000 main |

[^1]: High-resolution graphics mode on the Apple II has a resolution of 280x192 pixels on a monochrome display, but on a color display it has an *effective* color resolution of only 140x192. In addition, there are complicated limitations on what colors can be adjacent.

Video files are sequences of frames; each frame is a copy of the appropriate Apple II video memory for that resolution. This includes the "screen holes" (portions of the video memory that is not displayed) and is not linearized. For the double-resolution modes which have a horizontally interlaced display, the auxiliary memory half of each frame comes first, as is the standard for image files.

Video files must be ProDOS "tree" files, which means they must be more than 128K in length, up to a maximum of 16MB.

On the Apple IIe/IIc/IIɢꜱ, playback is throttled to 10fps.

## Building

Build and install the ACME assembler from https://github.com/meonwax/acme

Alternatively, you can install ACME via Homebrew on macOS.
   ```
   brew install acme
   ```

Run `acme play.vids.system.a` to assemble. This generates `BASIS.SYSTEM#ff0000`, which can then be placed on a disk image. To output a pre-assembled disk image, use `build.sh`.

## Packaging

Build and install Cadius from https://github.com/mach-kernel/cadius

1. Create a new large (e.g. 32MB) disk image:
   ```
   cadius CREATEVOLUME vids.hdv VIDS 32MB
   ```
2. Place video files on the disk image:
   ```
   cadius ADDFILE vids.hdv example_videos/DGR#5B1002
   cadius ADDFILE vids.hdv example_videos/DHGR#5B1004
   cadius ADDFILE vids.hdv example_videos/GR#5B1001
   cadius ADDFILE vids.hdv example_videos/HGR#5B1003
   ```
3. Place `PRODOS` from [https://prodos8.com/](https://releases.prodos8.com/ProDOS_2_4_3.po) on the disk image:
   ```
   cadius EXTRACTFILE ProDOS_2_4_3.po /PRODOS.2.4.3/PRODOS .
   cadius ADDFILE vids.hdv PRODOS#FF0000
   ```
4. Place `BASIS.SYSTEM` on the disk image:
   ```
   cadius ADDFILE vids.hdv BASIS.SYSTEM#FF0000
   ```

Now when a user boots `vids.hdv` on real hardware, or in an emulator, [Bitsy Bye](https://prodos8.com/bitsy-bye/) will present a menu of files. If the user selects a video file it will automatically play, and return to the menu when complete.

## Keyboard Controls

* <kbd>Space</kbd> - Pause/Resume
* <kbd>→</kbd> - Skip forwards several frames
* <kbd>←</kbd> - Skip backwards several frames
* <kbd>Esc</kbd> - Quit back to ProDOS
* <kbd>V</kbd> or <kbd>v</kbd> - Toggles whether waiting for vertical blank (VBL) is active (default is on)

The <kbd>1</kbd> and <kbd>2</kbd> keys can be used to force single/double resolution, although this is mainly for debugging.
