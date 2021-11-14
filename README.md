# Erbele

Erbele is a feature-rich text editor for macOS. Forked in 2016 from the Fraise github repository which was discontinued years ago, my main interest is to keep the popular app alive.

Supported macOS versions:
* macOS Sierra (10.12)
* macOS High Sierra (10.13)
* macOS Mojave (10.14)
* macOS Catalina (10.15)
* macOS Big Sur (11.0)
* macOS Monterey (12.0)

Architectures: 
* Intel
* Apple Silicon (since version 3.11.0)

Author: Andreas Bentele

Website: https://github.com/abentele/Erbele

Based on the discontinued project [Fraise 3.7.3](https://github.com/jfmoy/Fraise).
Fraise originally was forked from [Smultron 3.5.1](https://sourceforge.net/projects/smultron/), maintained by Peter Borg.

# Screen shots

![Erbele, English](https://github.com/abentele/Erbele/raw/master/Erbele-screenshot_en.png)

Same picture with German language:
![Erbele, German](https://github.com/abentele/Erbele/raw/master/Erbele-screenshot_de.png)

# Downloads

## Download release

Download the dmg file from [Releases](https://github.com/abentele/Erbele/releases).

## Troubleshooting

### Release 3.11

Release 3.11 has several bugs, most important incomplete implementation of Sandbox feature.
Please don't use release 3.11 but latest working release 3.10.

I'm currently working on a new release which removes automatic updates and switching to distribution via Mac App Store.
Please be patient.

### Gatekeeper issue (up to release 3.10)

With newer macOS versions there is an issue with Gatekeeper when opening the app after having it downloaded from github (see ticket #46).
This issue prevents you to launch the app because the app is labeled to be in quarantine.
*Workaround:* Just issue this command in the Terminal app, and retry: `#$ xattr -c Erbele.app`
This issue has been fixed with release 3.11.

## Build release

If you are familiar with git and Xcode, you also can checkout the git repository and build the app by yourself.

# Roadmap

Currently my main interest is to fix bugs, enhance already existing features and implement some new features while retaining the original focus and feature-set:
* powerful, but easy to use
* provide many helpful tools to edit texts
* support for many code languages (e.g. syntax highlighting)

For more details, see the [Issues list](https://github.com/abentele/Erbele/issues).

# Contribution

Please add bugs and wishes to the issues list, or discuss existing issues with me and the community.
If you would like to contribute, please let me know.
