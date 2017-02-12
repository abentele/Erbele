# Erbele

Erbele is a feature-rich text editor for macOS Sierra. Forked in 2016 from the Fraise github repository which was discontinued years ago, my main interest is to keep the popular app alive.

**See why I [changed the name from "Fraise" to "Erbele"](https://github.com/abentele/Erbele/wiki/Changed-the-name-from-%22Fraise%22-to-%22Erbele%22)** - I would appreciate if all supporters of my project would add a star to my new project on github.

Author: Andreas Bentele

Website: https://github.com/abentele/Erbele

[Fraise 3.7.3](https://github.com/jfmoy/Fraise) was maintained by Jean-Francois Moy, but discontinued.
Fraise originally was forked from [Smultron 3.5.1](https://sourceforge.net/projects/smultron/), maintained by Peter Borg.

# Releases

These were the last releases I made, available on https://github.com/abentele/Fraise/releases.
New releases will be added here: [Releases](https://github.com/abentele/Erbele/releases)

# Roadmap

Currently my main interest is to fix bugs, enhance already existing features and implement some new features while retaining the original focus and feature-set:
* powerful, but easy to use
* provide many helpful tools to edit texts
* support for many code languages (e.g. syntax highlighting)

For more details, see the [Issues list](https://github.com/abentele/Erbele/issues) and the [Roadmap](https://github.com/abentele/Erbele/projects/1).

# Contribution

Please add bugs and wishes to the issues list, or discuss existing issues with me and the community.
If you would like to contribute, please let me know.

# Changelog

## Release 3.8

Release date: 2017-02-12

Changes:
* first release with new name "Erbele"
* changed release artifact from zip to dmg (which is more common on macOS)
* fixed a crash when using text font colors other than black (#28)
* fixed a crash because of missing deregistration of key/value observers

[Commit list](https://github.com/abentele/Erbele/compare/3.7.7...3.8)

## Release 3.7.7

Release date: 2017-01-04

Bug fixes:
* fixed all known bugs related to printing
* remove the page setup menu, as recommended by Apple, to simplify the UI; instead add all settings to the printing panel
* fixed wrong API usage of font selection in preferences and print dialog
* improved German translation

[Commit list](https://github.com/abentele/Erbele/compare/3.7.6...3.7.7)

## Release 3.7.6

Release date: 2016-12-31

Bug fixes:
* fixed a crash on launch
* fixed a crash when loading binary files
* fixed a crash when printing to PDF
* fixed margins when printing with header

[Commit list](https://github.com/abentele/Erbele/compare/3.7.5...3.7.6)

## Release 3.7.5

Release date: 2016-12-25

New features:
* added markdown to supported document types
* added russian translation (thanks to gpongelli)

Enhancements:
* replaced proprietary full screen mode with macOS full screen mode
* improved layout for some dialogs
* improved some translations
* changed icons in preferences dialog
* ignore .git folder when opening the contents of a folder

Bug fixes:
* no icons in document list panel
* wrong Window sizes on retina display
* print space character with color defined in settings didn't work
* fixed a crash when trying to open a folder

This release also fixes many deprecations and code cleanup not done with release 3.7.4.

[Commit list](https://github.com/abentele/Erbele/compare/3.7.4...3.7.5)

## Release 3.7.4

Release date: 2016-10-04

Forked from Fraise 3.7.3 (https://github.com/jfmoy/Fraise)

Changes:
* support for macOS Sierra (10.12); removed support for OS X 10.11 and earlier
* removed 32bit support
* removed auto-update feature (because it did't work for a long time, and currently there is no maintainer providing releases)

(maybe it's not a very stable release, because I didn't have time to test it very much, but wanted to provide a working release today, which maybe is long awaited by many people)

[Commit list](https://github.com/abentele/Erbele/compare/3.7.3...3.7.4)
