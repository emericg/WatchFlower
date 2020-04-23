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

#include <QApplication>
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
    //
}

UtilsLanguage::~UtilsLanguage()
{
    //
}

/* ************************************************************************** */
/* ************************************************************************** */

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
    //qDebug() << "UtilsI18N::loadLanguage <<" << lng;

    if (m_currentLanguage != lng)
    {
        if (m_qt_app)
        {
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
            m_currentLanguage = lng;

            if (m_currentLanguage == "Dansk") localefull = "da_DK";
            else if (m_currentLanguage == "Deutsch") localefull = "de_DE";
            else if (m_currentLanguage == "English") localefull = "en_EN";
            else if (m_currentLanguage == "Espanol") localefull = "es_ES";
            else if (m_currentLanguage == "Français") localefull = "fr_FR";
            else if (m_currentLanguage == "Frisk") localefull = "fy_NL";
            else if (m_currentLanguage == "Nederlands") localefull = "nl_NL";
            else if (m_currentLanguage == "русский") localefull = "ru_RU";
            else
            {
                localefull = QLocale::system().name();
                m_currentLanguage = "auto";
            }

            QString localeshort = localefull;
            localeshort.truncate(localefull.lastIndexOf('_'));

            m_qtTranslator = new QTranslator;
            m_qtTranslator->load("qt_" + localeshort, QLibraryInfo::location(QLibraryInfo::TranslationsPath));
            m_appTranslator = new QTranslator;
            m_appTranslator->load(":/i18n/watchflower_" + localeshort + ".qm");

            // Install new language
            if (m_qtTranslator) m_qt_app->installTranslator(m_qtTranslator);
            if (m_appTranslator) m_qt_app->installTranslator(m_appTranslator);
            if (m_qml_engine) m_qml_engine->retranslate();
        }
    }
}

/* ************************************************************************** */
