Internationalization quick guide
--------------------------------

You can work on translations using one of two ways:
- [Using GitHub](https://github.com/firstcontributions/first-contributions/blob/master/README.md) by forking, branching, translating and creating a pull request.
- Directly, by downloading, translating and emailing the translation files back. It's a way more straightforward workflow, don't bother with GitHub if you don't know how to use it.

##### Step 1: Add the language to the project (if it's a new language)

Edit the Qt project file (_WatchFlower.pro_) and add a new language file entry to the TRANSLATIONS section, using project name and an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two letter code (ex: _i18n/watchflower_fr.ts_).

Edit the _i18n/i18n.qrc_ file and your language next to the others.

##### Step 2: Update the language file

To create (or update) the actual translation file, from the project root directory, run the following command:

```
lupdate WatchFlower.pro
```

This will scrape the source code and add/update the strings that need to be translated into the language files.  
If you are not able to run that command, you can simply ask me for a clean translation file.

##### Step 3: Translating

Translate by editing the .ts file using Qt Linguist.

- Remember to match upper/lower case letters, punctuation and trailing spaces!
- You don't have to translate everything, missing words or sentences will fall back to English.
- If you're not sure about a word or sentence, leave the "unfinished" tag, so other people can have a second look at it.

> Qt Linguist manual: https://doc.qt.io/qt-5/linguist-translators.html

> Qt Linguist standalone downloads: https://github.com/lelegard/qtlinguist-installers/releases

##### Step 4: (optional) Update the binary translation

To create (or update) the binary translation, run the following command from the project root directory:

```
lrelease WatchFlower.pro
```

This will convert the .ts language files into binary .qm files. These are the files actually loaded by the application.  
This step is optional, as it is only needed if you want to try the translation by building the project yourself. Otherwise it's a step done before every release of the project anyway.

##### Step 5: Publish it!

Send the file(s) back to the project, using email or a GitHub pull request.  
If you want to be credited in the application (and in this file) please be sure to mention it, and provide a name/pseudo, and wished an email/GitHub page.  
It's useful in case a person wants to contact you about the translation, or if you want to be contacted when a new version of the project will be released and a translation update is needed.


Special thanks
--------------

**Chinese (traditional and simplified)**
- Vic L. https://github.com/vicklau

**Danish**
- FYr76 https://github.com/FYr76

**Dutch**
- FYr76 https://github.com/FYr76

**French**
- Emeric Grange <emeric.grange@gmail.com>

**Frisian**
- FYr76 https://github.com/FYr76

**German**
- Megachip https://github.com/Megachip

**Norwegian (Bokmål and Nynorsk)**
- Guttorm Flatabø https://github.com/dittaeva

**Russian**
- Pavel Markin

**Spanish**
- Chris Díaz <christiandiaz.design@gmail.com>
