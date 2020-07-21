# FNORD
Some fun ways to mess with Apple ]['s output routine

Try running it yourself in [a browser-based Apple II emulator](http://micah.cowan.name/apple2js/apple2jse.html#fnord)!

See also [this YouTube video](https://youtu.be/-ihj4dO9wOI) on the filters and what they do.

## About

This project contains a number of programs for Apple ][ computers that will mess with screen output - both as you are typing it, and from program and command output.

Note that regardless of what the screen shows, the real input that your Apple sees will be exactly what you typed!

To try one of the output filters, use:
```
  ] brun filter
```

To return output to normal, enter:
```
  ] pr#0
```
or restart BASIC with Control-RESET

These programs have been tested on a real-life Apple //c, and via emulation on enhanced Apple //e and Apple ][+ configurations (the Apple ][+ can only work well with the `LEET`, `WHABAT`, and `HLSPACES` filters, since it lacks a lowercase character set).

Try running the `CATALOG` or `LIST` commands with a filter enabled - or just start typing away at the prompt and see what happens.

Sadly, the filters cannot be chained, one to another, primarily because they all install to the same space in memory, overwriting one another.

## How to try it out!

The easiest way to try these programs is to run them in [an Apple II emulator in your browser](http://micah.cowan.name/apple2js/apple2jse.html#fnord)!

You can also grab the `fnord.dsk` image from github's "releases" tab for this project. Then either run in an Apple ][ emulator, or transfer to your real Apple II-series computer via something like [Floppy Emu](https://www.bigmessowires.com/floppy-emu/) or [ADTPro](https://adtpro.com/), boot the disk, and follow the instructions!

## Filter Descriptions

### `BRUN MIXCASE`
Triggers automatic MiXeD cAsE mOdE. Doesn't play well with `INVERSE` or `FLASH`; numbers and symbols will be displayed instead of the lowercase characters.

### `BRUN LEET`
Now your program's output will look like it was written by a 1337 h4x0r! Plays nice with `INVERSE` or `FLASH`.

### `BRUN DOUBLE`
Doubles every character printed, except carriage return (so that lines aren't doubly-separated). If the character is a letter, then it will print the first one in uppercase, the second one in lowercase. Doesn't play well with `INVERSE` and `FLASH`. The length of what's typed is of course modified, but backspacing (with the Left Arrow key) still works intuitively because it, too, gets processed twice.

### `BRUN WHABAT`
Based on a spoken "code" sometimes used by parents to prevent listening children from understanding what is being said. Featured on Bojack Horseman. Automatically adds "AB" before every vowel, unless the previous character encountered had also been a vowel. Works best with capital letters (because the "AB" additions are always capitals), and (for that reason) plays nice with `INVERSE` or `FLASH`. Take note: if you backspace over the inserted "AB" characters with the Left Arrow key, you will in actuality be backing over other characters that came before them, since they only appear on the display and were not processed as part of the "current input line". It's a good idea to avoid backing over your input in this mode, in general.

### `BRUN FNORD`
Just adds an extra word, a lower-case "fnord", at the end of the line just before every carriage return (whether you typed it, or the end of a line was reached in a program's output. Since the word is lower-case it will not play well with `INVERSE` or `FLASH`

### `BRUN HLSPACES`
Very simple. Just automatically inplies `INVERSE` to any new, explicitly-written space characters.

## But why, though?

This was done in part as a fun exercise while I was exploring the internals of how output is processed in the Apple ][ ROM code (the Monitor, and AppleSoft Basic), and in part because I needed something fun/cool to work on for the [KansasFest 2020 Hackfest](https://www.kansasfest.org/hackfest/). I was exploring this area of the Apple's internals because I was curious if it was possible to set it up so that a BASIC `PRINT` statement would write simultaneously to page one, and also page two, of the text display region of memory. Turns out, it is possible! ...though you first have to modify AppleSoft's understanding of where your BASIC program resides, as normally it resides at the start of the text display "page two" area, so writing there would obliterate the program while it ran, unless you take pains.

But while I was in there, I began to get silly ideas of what else you might make the `PRINT` statements (or other output functions) do - thus this toy project was born!

## Building notes

If you want to modify or build from these sources, you will need tools from the following projects:

  * The ca65 and ld65 tools from [the cc65 project](https://github.com/cc65/cc65)
  * These [tools for manipulating Apple DOS 3.3 filesystems](https://github.com/deater/dos33fsprogs)

NOTE: The **dos33fsprogs** project contains *many* different subprojects, most of which are *not needed* to build `fnord.dsk`. The only subdirectories you must build, are `dos33fs-utils` and `asoft_basic-utils`.

Fnord's Makefile assumes all of these tools are accessible from the current `PATH` environment variable.

## A note on how to hook output filters into your Apple

If you were to boot directly into BASIC (no dos), and poke these filter routines directly into memory at `$030b`, the way you would hook them into filtering screen output would be to set `$36-$37` to the address (`$030B`, low byte first).

However, both Apple DOS and ProDOS have already hooked this for their own purposes, and take measures to keep it that way, so both DOS's need other means of hooking in.

ProDOS has explicit support for doing this on the command line:
```
  ] PR#A$30B
```

I'd have preferred to use this method, but do not have convenient tools for building ProDOS images outside of a running Apple ][. So I'm using what works for at least my version (3.3) of Apple DOS (unsure if a better means exists): to set `$AA53-54` to the desired address. So we do that.
