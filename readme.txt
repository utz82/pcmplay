********************************************************************************
PCMplay v1.0
by utz 09'2015 * http://irrlichtproject.de
********************************************************************************


About
*****

PCMplay is a multi-channel PCM WAV player for CoCo/Dragon computers. It mixes
four channels of fixed-length, looped WAV samples at a discretion frequency of 
approximately 7295 Hz.

You are free to use PCMplay in your own game/demo/music projects, provided you
don't violate the terms of the BSD 3-clause license. See 'main.asm' for 
license details. If this is not feasible for you, please contact me and we'll
work something out. I can be reached at <utz at my domain>, see above.


Composing Music
***************

You can compose music for PCMplay by hard-coding the 'music.asm' module, or by 
using the provided 'music.xm' template. While the latter option is much more
convenient, it has a few drawbacks. Namely, the XM template gives only a rough
impression of how the music will sound on an actual CoCo/Dragon machine. Also,
there is no easy way of including additional samples in the template.

In order to use the XM template, you will need the following tools:

- an XM tracker (recommended: Milkytracker, http://www.milkytracker.org)
- Perl (https://www.perl.org/get.html)
- lwtools (http://lwtools.projects.l-w.ca)

Provided you have these installed and/or included in your search path,
converting your XM composition to a ready-to-run .bin file is a matter of 
simply running the included compile.bat (Win) resp. compile.sh (*nix) scripts.

If you only want to obtain the music.asm module, run xm2pcmplay.pl without any
arguments. You can invoke xm2pcmplay.pl with the -v flag to obtain some extra
debugging information.

A few restrictions apply when using the XM template.

- You may not change the number of channels.
- You may only use notes C-1 - B-5.
- Any changes to the BPM parameter are ignored ('Spd' can be changed though).
- The only valid effect is Fxx (change tempo, xx <= $1f).
- All other effects, including volume/panning settings are ignored.
  
By default, PCMplay songs will loop back to the start. You can change the
loop point manually, by putting the "sloop" label in 'music.asm' at another
position in the song sequence. You can disable looping entirely by
uncommenting line 66 in 'main.asm'.

PCMplay is not tuned to any particular frequency. If you find this unacceptable,
you can retune the frequency table with the provided tablegen-16bit.sh script
(*nix only).
  


Module Format
*************

PCMplay modules (ie. 'music.asm') consist of a song sequence, followed by one or
more note patterns.

The song sequence contains the order in which patterns are played, so
unsurprisingly it consists of one or more pointers to patterns. It also must
contain the label "sloop" - this will determine where the player loops to after
it has completed the sequence. In order to disable looping, uncomment line 66 in
main.asm. 

The sequence is terminated with a 0-word. So, a very simple song sequence would
look like this:

sloop
	.dw pattern01
	.dw 0
	
This would simply loop a single pattern over and over again. 

Patterns consist of an arbitrary number of steps or rows, containing 9 bytes
each. The function of these is as follows

byte 1    - tempo ($01-$7f), lower value means higher speed
byte 2..5 - note values channel 1-4 ($00 - $3c), $00 = silence
byte 6..9 - sample pointers ch 1-4 (ie. the hi-byte of the sample address)

Patterns are terminated with a value >= $80 on the start of a row.



Sample Format
*************

Samples are looped, and must be exactly 256 bytes long. They contain unsigned
raw PCM data with 4-bit depth, ie. sample bytes can have a maximum value of 15.
Samples are stored pre-shifted (all values multiplied by 4) in order to allow
faster mixing of the DAC output.

In order to keep sample pitches consistent, wave period lengths should be a
power of 2.

You can use the included wav2smp utility to convert normal raw unsigned 8-bit
WAV samples of any length to PCMplay's internal format. Usage is as follows:

[perl] [./]wav2smp.pl <volume (1..15)> <infile.wav> [<outfile.smp>]

All used samples must be linked into 'samples.asm'.



Thanks
******

- to Simon Jonassen for his advice, and his CoCo madness
- to Ciaran Anscomb for xroar
- to William Astle for lwtools