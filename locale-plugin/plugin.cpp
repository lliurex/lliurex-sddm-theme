/*
 * Copyright (C) 2021 Lliurex project
 *
 * Author:
 *  Enrique Medina Gremaldos <quiqueiii@gmail.com>
 *
 * Source:
 *  https://github.com/lliurex/lliurex-sddm-theme
 *
 * This file is a part of lliurex sddm theme.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 */

#include "plugin.h"

#include <QQmlExtensionPlugin>
#include <QObject>
#include <QQmlEngine>
#include <QMimeData>
#include <QAbstractItemModel>
#include <QProcess>
#include <QLocale>

#include <iostream>
#include <chrono>

using namespace std;

X11KeyLayout::X11KeyLayout(QObject* parent): QObject(parent)
{
}

X11KeyLayout::X11KeyLayout(QString name) : QObject(nullptr), m_name(name)
{
}

Language::Language(QObject* parent): QObject(parent)
{
}

Language::Language(QString name,QString longName) : QObject(nullptr), m_name(name),m_longName(longName)
{
}

LocalePlugin::LocalePlugin(QObject* parent) : QQmlExtensionPlugin(parent)
{
}

Locale::Locale(QObject* parent): QObject(parent)
{
    QProcess p;
    
    QString program = QStringLiteral("localectl");
    QStringList args;
    args << QStringLiteral("list-locales");
    
    p.start(program,args);
    p.waitForFinished();
    
    QByteArray out = p.readAll();
    QList<QByteArray> lines = out.split('\n');
    
    for (int n=0;n<lines.count();n++) {
        QString value = QString::fromLocal8Bit(lines[n]);
        
        if (value.length()==0) {
            continue;
        }
        
        if (value.startsWith(QStringLiteral("C."))) {
            continue;
        }
        
        QLocale ql(value);
        /*
        QString longName = QLocale::languageToString(ql.language()) 
            + QStringLiteral(":") + QLocale::countryToString(ql.country());
        */
        
        QString longName = ql.nativeLanguageName() + QStringLiteral(" (") 
            + ql.nativeCountryName() +  QStringLiteral(")");
        
        longName[0] = longName[0].toUpper();
        
        m_languagesModel.append(new Language(value,longName));
        
    }
    
    args.clear();
    args << QStringLiteral("list-x11-keymap-layouts");
    
    p.start(program,args);
    p.waitForFinished();
    
    out = p.readAll();
    lines = out.split('\n');
    
    for (int n=0;n<lines.count();n++) {
        QString value = QString::fromLocal8Bit(lines[n]);
        
        if (value.length()==0) {
            continue;
        }
        
        m_layoutsModel.append(new X11KeyLayout(value));
    }
    
    
}

void LocalePlugin::registerTypes(const char* uri)
{
    qmlRegisterType<X11KeyLayout> (uri, 1, 0, "X11KeyLayout");
    qmlRegisterType<Language> (uri, 1, 0, "Language");
    qmlRegisterType<Locale> (uri, 1, 0, "Locale");
    qmlRegisterAnonymousType<QMimeData>(uri, 1);
    
}
