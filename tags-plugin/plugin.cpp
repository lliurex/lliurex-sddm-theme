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

#include <iostream>
#include <fstream>
#include <chrono>

using namespace std;

QStringList list_files(QString path)
{
    QStringList files;

    QDir dir(path);

    dir.setFilter(QDir::Files);

    return dir.entryList();
}

Tags::Tags(QObject* parent): QObject(parent)
{
    reload();
}

void Tags::reload()
{

    m_tagsModel.clear();
    m_tagsModel = list_files("/etc/lliurex-auto-upgrade/tags/");

    m_autoTagsModel.clear();
    m_autoTagsModel = list_files("/run/lliurex-auto-upgrade/tags/");

    m_systemTagsModel.clear();
    m_systemTagsModel = list_files("/usr/share/lliurex-auto-upgrade/tags/");

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
