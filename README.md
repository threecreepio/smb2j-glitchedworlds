Glitched Worlds SMB2J Patch
===========================

This patch adds a world select menu when starting SMB2J.

Make sure to only choose files 0, 1, 2 or 3, any other files will likely just crash the game.. But that's half the fun.

You can control the menu by pressing select to toggle between items, pressing left and right to increment values by 1, up and down to increment by 16.

The 'file' behavior is a little weird, so if you want to match the original game:
 - If you want to play 1-1, select File 0 and pick World 0
 - If you want to play 5-1, select File 1 and pick World 4
 - If you want to play 9-1, select File 2 and pick World 8
 - If you want to play A-1, select File 3 and pick World 0

A couple of extra things to be aware of:
 - The selectors are 0-based, so if you pick world 0, area 0, you will get what's normally 1-1 (the title screen will show 1-1.) This was done to make it easier to remember level numbers rather than having to remember that you were on "right side of a cloud - copyright sign"
 
 - The 'area' selector picks areas not levels. If you play a stage where there's a pipe entry cutscene, it is it's own separate area. This way you can access every single area but the numbering can be a little off.


Download & Installation
=======================

First, download the latest patch from the [releases](https://github.com/threecreepio/smb2j-glitchedworlds/release)

Then simply apply that IPS (using for instance Lunar IPS) to the original, unmodified version of the "Super Mario Brothers 2 (Japan).fds" ROM. 

The MD5 checksum for the ROM you should be using is `7f38210a8a2befb8d347523b4ff6ae7c`.

Have fun!

/threecreepio
