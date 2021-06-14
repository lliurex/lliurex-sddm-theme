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

X11KeyVariant::X11KeyVariant(QObject* parent): QObject(parent)
{
}

X11KeyVariant::X11KeyVariant(QString name) : QObject(nullptr), m_name(name)
{
}

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

static QStringList run(QString cmd,QStringList args)
{
    QProcess p;
    
    p.start(cmd,args);
    p.waitForFinished();
    
    QByteArray out = p.readAll();
    QList<QByteArray> lines = out.split('\n');
    
    QStringList ret;
    
    for (int n=0;n<lines.count();n++) {
        QString value = QString::fromLocal8Bit(lines[n]);
        
        if (value.length()==0) {
            continue;
        }
        
        ret<<value;
    }
    
    return ret;
}

Locale::Locale(QObject* parent): QObject(parent)
{
    
    QStringList lines = run(QStringLiteral("localectl"),{QStringLiteral("list-locales")});
    
    for (QString line:lines) {
        
        if (line.startsWith(QStringLiteral("C."))) {
            continue;
        }
        
        QLocale ql(line);
        QString longName = ql.nativeLanguageName() + QStringLiteral(" (") 
            + ql.nativeCountryName() +  QStringLiteral(")");
        
        longName[0] = longName[0].toUpper();
        
        m_languagesModel.append(new Language(line,longName));
    }
    
    lines = run(QStringLiteral("localectl"),{QStringLiteral("list-x11-keymap-layouts")});
    
    for (QString line:lines) {
        QStringList variants = run(QStringLiteral("localectl"),{QStringLiteral("list-x11-keymap-variants"),line});
        
        for (QString variant: variants) {
            
            m_layoutsModel.append(new X11KeyLayout(line+QStringLiteral(":")+variant));
        }
    }
    
}

QString Locale::findBestLayout(QString localeName)
{
    if (localeName.startsWith(QStringLiteral("ca_ES@valencia"))) {
        return QStringLiteral("es");
    }
    
    return QStringLiteral("en");
}

void LocalePlugin::registerTypes(const char* uri)
{
    qmlRegisterType<X11KeyLayout> (uri, 1, 0, "X11KeyLayout");
    qmlRegisterType<Language> (uri, 1, 0, "Language");
    qmlRegisterType<Locale> (uri, 1, 0, "Locale");
    qmlRegisterAnonymousType<QMimeData>(uri, 1);
    
}
