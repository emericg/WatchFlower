/*!
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \author    Emeric Grange <emeric.grange@gmail.com>
 * \date      2020
 */

#include "utils_language.h"

#include <QCoreApplication>
#include <QLibraryInfo>
#include <QTranslator>
#include <QDebug>

/* ************************************************************************** */

UtilsLanguage *UtilsLanguage::instance = nullptr;

UtilsLanguage *UtilsLanguage::getInstance()
{
    if (instance == nullptr)
    {
        instance = new UtilsLanguage();
    }

    return instance;
}

UtilsLanguage::UtilsLanguage()
{
    // Set a default application name and instance
    m_appName = QCoreApplication::applicationName().toLower();
    m_qt_app = QCoreApplication::instance();
}

UtilsLanguage::~UtilsLanguage()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

void UtilsLanguage::setAppName(const QString &name)
{
    m_appName = name;
}

void UtilsLanguage::setAppInstance(QCoreApplication *app)
{
    m_qt_app = app;
}

void UtilsLanguage::setQmlEngine(QQmlApplicationEngine *engine)
{
    m_qml_engine = engine;
}

/* ************************************************************************** */

void UtilsLanguage::loadLanguage(const QString &lng)
{
    //qDebug() << "UtilsLanguage::loadLanguage <<" << lng;

    if (!m_qt_app) return;
    if (m_appLanguage == lng) return;

    // Remove old language
    if (m_qtTranslator)
    {
        m_qt_app->removeTranslator(m_qtTranslator);
        delete m_qtTranslator;
    }
    if (m_appTranslator)
    {
        m_qt_app->installTranslator(m_appTranslator);
        delete m_appTranslator;
    }

    //
    QString localefull;
    m_appLanguage = lng;

    if (m_appLanguage == "Dansk") localefull = "da_DK";
    else if (m_appLanguage == "Deutsch") localefull = "de_DE";
    else if (m_appLanguage == "English") localefull = "en_EN";
    else if (m_appLanguage == "Español") localefull = "es_ES";
    else if (m_appLanguage == "Français") localefull = "fr_FR";
    else if (m_appLanguage == "Frysk") localefull = "fy_NL";
    else if (m_appLanguage == "Nederlands") localefull = "nl_NL";
    else if (m_appLanguage == "Norsk (nynorsk)") localefull = "nn_NO";
    else if (m_appLanguage == "Pусский") localefull = "ru_RU";
    else
    {
        localefull = QLocale::system().name();
        m_appLanguage = "auto";
    }

    QString localeshort = localefull;
    localeshort.truncate(localefull.lastIndexOf('_'));

    m_qtTranslator = new QTranslator;
    m_qtTranslator->load("qt_" + localeshort, QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    m_appTranslator = new QTranslator;
    m_appTranslator->load(":/i18n/" + m_appName + "_" + localeshort + ".qm");

    // Install new language
    if (m_qtTranslator) m_qt_app->installTranslator(m_qtTranslator);
    if (m_appTranslator) m_qt_app->installTranslator(m_appTranslator);
    if (m_qml_engine) m_qml_engine->retranslate();
}

/* ************************************************************************** */
