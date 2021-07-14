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
#include <fstream>
#include <chrono>

using namespace std;

X11KeyLayout::X11KeyLayout(QObject* parent): QObject(parent)
{
}

X11KeyLayout::X11KeyLayout(QString name,QString longName) : QObject(nullptr), m_name(name), m_longName(longName)
{
}

Language::Language(QObject* parent): QObject(parent)
{
}

Language::Language(QString name,QString longName) : QObject(nullptr), m_name(name), m_longName(longName)
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

QMap<QString,QString> Locale::variantNames;

Locale::Locale(QObject* parent): QObject(parent)
{
    
    fstream file;
    
    file.open("/usr/share/X11/xkb/rules/evdev.lst",std::fstream::in);
    
    std::string tmp;
    bool start = false;
    
    while(std::getline(file,tmp)) {
        if (start) {
            
            if (tmp.size()==0) {
                break;
            }
            //TODO: some extra checks
            QString p = QString::fromStdString(tmp);
            QStringList q = p.split(QLatin1Char(':'));
            QString a = q[0].simplified();
            QString b = q[1].simplified();
            
            QStringList r = a.split(QLatin1Char(' '));
            QString name = r[1]+QStringLiteral(":")+r[0];
            Locale::variantNames[name]=b;
            
            //clog<<name.toStdString()<<"--->"<<b.toStdString()<<endl;
            
        }
        else {
            if (tmp=="! variant") {
                start = true;
            }
        }
        
    }
    
    file.close();
    
    QStringList lines = run(QStringLiteral("localectl"),{QStringLiteral("list-locales")});
    
    Language* firsts[4] = {nullptr,nullptr,nullptr,nullptr};
    
    for (QString line:lines) {
        
        if (line.startsWith(QStringLiteral("C."))) {
            continue;
        }
        
        if (line.startsWith(QStringLiteral("ca_ES.UTF-8@valencia"))) {
            firsts[3]=new Language(line,QStringLiteral("Valencià (Espanya)"));
            continue;
        }
        
        QLocale ql(line);
        QString longName = ql.nativeLanguageName() + QStringLiteral(" (") 
            + ql.nativeCountryName() +  QStringLiteral(")");
        
        longName[0] = longName[0].toUpper();
        
        if (line.startsWith(QStringLiteral("es_ES.UTF-8"))) {
            firsts[2]=new Language(line,longName);
            continue;
        }
        
        if (line.startsWith(QStringLiteral("ca_ES.UTF-8"))) {
            firsts[1]=new Language(line,longName);
            continue;
        }
        
        if (line.startsWith(QStringLiteral("en_US.UTF-8"))) {
            firsts[0]=new Language(line,longName);
            continue;
        }
        
        m_languagesModel.append(new Language(line,longName));
    }
    
    //sort work arround
    for (int n=0;n<4;n++) {
        if (firsts[n]!=nullptr) {
            m_languagesModel.push_front(firsts[n]);
        }
    }
    
    lines = run(QStringLiteral("localectl"),{QStringLiteral("list-x11-keymap-layouts")});
    
    for (QString line:lines) {
        QStringList variants = run(QStringLiteral("localectl"),{QStringLiteral("list-x11-keymap-variants"),line});
        
        for (QString variant: variants) {
            QString index = line+QStringLiteral(":")+variant;
            m_layoutsModel.append(new X11KeyLayout(index,Locale::variantNames[index]));
        }
    }
    
}

QString Locale::findBestLayout(QString localeName)
{
    if (localeName.startsWith(QStringLiteral("ca_ES.UTF-8@valencia"))) {
        return QStringLiteral("es:cat");
    }
    
    QLocale ql(localeName);
    
    if (ql.language()==QLocale::Spanish) {
        if (ql.country()==QLocale::Spain) {
            return QStringLiteral("es:deadtilde");
        }
        else {
            return QStringLiteral("latam:deadtilde");
        }
    }
    
    if (ql.language()==QLocale::Catalan) {
        return QStringLiteral("es:cat");
    }
    
    return QStringLiteral("us:intl");
}

void LocalePlugin::registerTypes(const char* uri)
{
    qmlRegisterType<X11KeyLayout> (uri, 1, 0, "X11KeyLayout");
    qmlRegisterType<Language> (uri, 1, 0, "Language");
    qmlRegisterType<Locale> (uri, 1, 0, "Locale");
    qmlRegisterAnonymousType<QMimeData>(uri, 1);
    
}
