# GenshinDb
<p align="center">
  <img height="120px" src="assets/icon/icon.png">
</p>

> A Genshin Impact database kinda app

> This app is not affiliated with or endorsed by miHoYo. GenshinDb is just a database app for the Genshin Impact game
<p align="center">
  <img src="images/banner.png">
</p>

### Features

* Artifacts
* Characters
* Weapons
* Materials
* And many more to come

[<img height="100" width="250" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" />](https://play.google.com/store/apps/details?id=com.miraisoft.genshindb)

### Translations

Currently the app supports English and Spanish (There are some folks working on a french / russian translation).
If you want to help me with the translations, i encourage you to check the following files:

* The main one (where all the data of the characters / artifacts / etc are stored):
[Main](https://github.com/Wolfteam/GenshinDb/blob/develop/assets/i18n/en.json)

* The general one (where common strings are stored [not related specifically to the game]):
[General](https://github.com/Wolfteam/GenshinDb/blob/develop/lib/l10n/intl_en.arb)

To translate the general one is very simple, create a copy of the file, keeping the keys and translate the values:
E.g (in spanish) : "dark" :"Oscuro"

The main one is where you will find all the data for all the weapons, artifacts, etc. 
To translate this file just create a copy of it and do the following:
There is a key called "key" for each character, weapon, etc, and this one does not require a translation, it's just there for convenience,
and the same applies here, just keep the keys and translate the values
E.g:  if I'm translating  "name": "Normal Attack"  to spanish it will look like this:  "name": "Ataque normal"

In this file, there are some translations (mainly for weapons) that look like this: "Increases DMG against enemies affected by Hydro or Pyro by {{0}}%",
The {{x}} is a placeholder and the value shouldn't be changed, but the position can be changed in the text. 

### Special Thanks

* To  [Uzair Ashraf](https://github.com/uzair-ashraf) for his wish simulator
* The folk(s) that developed the [Map](https://genshin-impact-map.appsample.com/#/)
* And the folks from [Honey Impact](https://genshin.honeyhunterworld), [Fandom Wiki](https://genshin-impact.fandom.com/wiki/Genshin_Impact), [Genshin.in](https://www.gensh.in/), [Genshin.Center](https://genshin-center.com/) that provide useful data

### Translators

Translating the app to other languages won't have been possible without the following contributors

|Chinese |Russian|
|---|---|
|2O48#9733|SipTik#8026|
| |KKTS#8567|
| |KlimeLime#7577|
| |Avantel#8880|
| |чебилин#5968|
| |Anixty#3279|





