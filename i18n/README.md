
Internationalization guide
--------------------------

##### Step 1: (if the language file doesn't alread exist)
Edit the Qt project file (WatchFlower.pro) and add a new langage file entry to the TRANSLATIONS section, using project name and an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two letter code (ex: i18n/watchflower_fr.ts).

##### Step 2:

To create (or update) translation files, from the project root directory, run:

> lupdate WatchFlower.pro"

This will scrape the source code and add strings to be translated into the language files.

##### Step 3:

Translate by opening the .ts file using Qt Linguist.

Qt Linguist manual: https://doc.qt.io/qt-5/linguist-translators.html

Qt Linguist standalone downloads: https://github.com/lelegard/qtlinguist-installers/releases

##### Step 4: (if the language file doesn't already exist)

Edit the i18n/i18n.qrc file and add the

---

Special thanks
--------------

**French**
- Emerig Grange <emeric.grange@gmail.com>

**German**
- Megachip https://github.com/Megachip

**Spanish**
- Chris Díaz <christiandiaz.design@gmail.com>
