
Internationalization quick guide
--------------------------------

You can work on translations unsing one of two ways:
- directly, by downloading, translating and emailing them back
- [using GitHub](https://github.com/firstcontributions/first-contributions/blob/master/README.md) and forking, branching, translating and creating a pull request

##### Step 1: Add the langage to the project (if its a new langage)

Edit the Qt project file (_WatchFlower.pro_) and add a new langage file entry to the TRANSLATIONS section, using project name and an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two letter code (ex: _i18n/watchflower_fr.ts_).

Edit the _i18n/i18n.qrc_ file and your langage next to the others.

##### Step 2: Update the langage file

To create (or update) the actual translation file, from the project root directory, run the following command:

> lupdate WatchFlower.pro

This will scrape the source code and add/update the strings that need to be translated into the language files.

##### Step 3: Translating

Translate by opening the .ts file using Qt Linguist.

- Remember to match punctuation and trailing spaces
- You don't have to translate everything, missing word or sentence will fall back to english
- If your not sure about a word or sentence, leave the "unfinished" tag so other people can have a second look at it

Qt Linguist manual: https://doc.qt.io/qt-5/linguist-translators.html

Qt Linguist standalone downloads: https://github.com/lelegard/qtlinguist-installers/releases

##### Step 4: Update the binary translation

To create (or update) the binary translation, from the project root directory, run the following command:

> lrelease WatchFlower.pro

This will convert the .ts language files into binary .qm files. These are the files actually loaded by the application.


---


Special thanks
--------------

**Dutch**
- FYr76 https://github.com/FYr76

**French**
- Emerig Grange <emeric.grange@gmail.com>

**Frisian**
- FYr76 https://github.com/FYr76

**German**
- Megachip https://github.com/Megachip

**Spanish**
- Chris Díaz <christiandiaz.design@gmail.com>
