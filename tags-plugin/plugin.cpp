/*
 * Copyright (C) 2026 Lliurex project
 *
 * Author:
 *  Enrique Medina Gremaldos <quique@necos.es>
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
#include <QDir>

#include <iostream>
#include <fstream>
#include <chrono>

using namespace std;


Tag::Tag(QObject* parent): QObject(parent)
{
}

Tag::Tag(QString name) : QObject(nullptr), m_name(name)
{
    if (m_name.indexOf(QString::fromLatin1(".")) >= 0) {
        m_isAuto = true;
    }
    else {
        m_isAuto = false;
    }
}

Tags::Tags(QObject* parent): QObject(parent)
{
    reload();
}

void Tags::reload()
{

    QDir dir(QString::fromLatin1("/etc/lliurex-auto-upgrade/tags/"));

    dir.setFilter(QDir::Files);

    QStringList files = dir.entryList();

    m_tagsModel.clear();

    for (const QString& file : files) {
        m_tagsModel.append(new Tag(file));
    }

    emit onTagsChanged();
}

TagsPlugin::TagsPlugin(QObject* parent) : QQmlExtensionPlugin(parent)
{
}

void TagsPlugin::registerTypes(const char* uri)
{
    qmlRegisterType<Tag> (uri, 1, 0, "Tag");
    qmlRegisterType<Tags> (uri, 1, 0, "Tags");
    qmlRegisterAnonymousType<QMimeData>(uri, 1);
    
}
