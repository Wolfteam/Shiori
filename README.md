# Shiori

<p align="center">
  <img height="120px" src="assets/icon/icon.png">
</p>

> A Genshin Impact database kinda app

> This app is not affiliated with or endorsed by miHoYo. Shiori is just a database app for the
> Genshin Impact game

![Tests](https://github.com/Wolfteam/Shiori/actions/workflows/tests.yml/badge.svg)
<p align="center">
  <img src="images/banner.png">
</p>

<p align="center" width="100%">
    <a href="https://play.google.com/store/apps/details?id=com.miraisoft.shiori">
      <img style="height:100px;width:30%;max-width:250px;transform: scale(1.25);margin-right:20px" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" />
    </a>
    <a href="https://apps.apple.com/us/app/shiori-for-genshin-unofficial/id6448140103">
      <img style="height:100px;width:30%;max-width:250px" src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" />
    </a>
    <a href="https://apps.microsoft.com/store/detail/shiori-for-genshin-unofficial/9PH29FZMQK7T">
      <img style="height:100px;width:35%;max-width:250px" src="https://www.nexiahome.com/wp-content/uploads/2016/03/windows-store-button.png" />
    </a>
</p>

### Features

* Artifacts
* Characters
* Weapons
* Materials
* And many more to come

### Discord
<p align="left">
    <a href="https://discord.gg/A8SgudQMwP">
      <img height="100" width="100" src="https://sparkcdnwus2.azureedge.net/sparkimageassets/XPDC2RH70K22MN-08afd558-a61c-4a63-9171-d3f199738e9f" />
    </a>
</p>

### Contributing

> Before contributing, please ask me if whatever you are planning to do / add / improve is valid for
> this project.

#### To run the server:

* Install the .net 6 runtime [HERE](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)
* Download and extract
  the [server.zip](https://github.com/Wolfteam/Shiori/releases/download/1.6.7%2B113/server.zip)
* Open a terminal and run one of the following commands (depending on the OS / shell the command may
  vary)
    * ``dotnet ShioriAssets.dll``
    * ``./ShioriAssets``
* After running the command you should see an output like this:

```
info: Microsoft.Hosting.Lifetime[14]
Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[14]
Now listening on: https://localhost:5001
info: Microsoft.Hosting.Lifetime[0]
Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
Hosting environment: Production
```

* Take note of the url's port, since you will need it later
* Copy the url and open it in your browser, you should see an ``It works!`` text

#### To run the app:

* Clone this repository
* Checkout the **develop** branch
* Create a **.env.common** file with the following content, the values can be anything:

```
ANDROID_APP_CENTER_KEY = xxxx
IOS_APP_CENTER_KEY = xxxx
MACOS_APP_CENTER_KEY = xxxx
ANDROID_PURCHASES_KEY = yyyyy
IOS_PURCHASES_KEY = yyyyy
COMMON_HEADER_NAME = header
API_HEADER_NAME = key
PUBLIC_KEY = xxxzzzzz
PRIVATE_KEY = xxxxzzz
LETS_ENCRYPT_KEY = xxxzzzzxxx
```

* Create a **.env.dev** and a copy named **.env.prod** with the following content
  (The url is the one used for the server, should work if you are using an android emulator)

```
API_BASE_URL = https://10.0.2.2:5001
ASSETS_BASE_URL = https://10.0.2.2:5001
API_HEADER_VALUE = value
```

* Install the ``Flutter Intl extension`` (It is available in Vs Code and Android Studio)
* Run the ``flutter intl initialize`` command from your IDE
* Comment the lines 19 to 30 in the ``infrastructure/api_service.dart`` and add the following behind
  line
  31 ``httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;``
* If you have fvm configured, run the script ``sh run_clean.sh``, otherwise manually run each
  sentence without the fvm prefix
* Profit

### Translations

If you want to help me with translations, I encourage you to check the following file:

* The general one (where common strings are stored [not related specifically to the game]):
  [General](https://github.com/Wolfteam/Shiori/blob/develop/lib/l10n/intl_en.arb)

To translate the general one is very simple, create a copy of the file, keeping the keys and
translate the values:
E.g (in spanish) : "dark" :"Oscuro"

### Special Thanks

* To  [Uzair Ashraf](https://github.com/uzair-ashraf) for his wish simulator
* To
  the [Genshin Helper Team](https://docs.google.com/spreadsheets/d/e/2PACX-1vRq-sQxkvdbvaJtQAGG6iVz2q2UN9FCKZ8Mkyis87QHFptcOU3ViLh0_PJyMxFSgwJZrd10kbYpQFl1/pubhtml)
  for their builds
* The folk(s) that developed the [Map](https://genshin-impact-map.appsample.com/#/)
* And the folks from [Honey Impact](https://genshin.honeyhunterworld)
  , [Fandom Wiki](https://genshin-impact.fandom.com/wiki/Genshin_Impact)
  , [Genshin.in](https://www.gensh.in/), [Genshin.Center](https://genshin-center.com/) that provide
  useful data
* And to [JetBrains](https://www.jetbrains.com/) who provides
  an [Open Source License](https://www.jetbrains.com/community/opensource/#support) for this
  project.

### Translators

Translating the app to other languages won't have been possible without the following contributors

| Chinese   | Russian        | Portuguese   | Italian                | Japanese      | Vietnamese    | Indonesian   | Ukrainian     |
|-----------|----------------|--------------|------------------------|---------------|---------------|--------------|---------------|
| 2O48#9733 | SipTik#8026    | Brunoff#0261 | Reniel [Skidex ツ]#7982 | 𝕽𝖚𝖗𝖎#3080 | Ren Toky#5263 | Arctara#7162 | VALLER1Y#4726 |
|           | KKTS#8567      | DanPS#4336   | Septenebris#7356       |||||
|           | KlimeLime#7577 |||||||
|           | Avantel#8880   |||||||
|           | чебилин#5968   |||||||
|           | Anixty#3279    |||||||
