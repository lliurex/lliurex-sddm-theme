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

#ifndef QML_LLIUREX_TAGS_PLUGIN
#define QML_LLIUREX_TAGS_PLUGIN

#include <QQmlExtensionPlugin>
#include <QObject>
#include <QList>
#include <QMap>
#include <QStringList>

class Tags: public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QStringList tagsModel MEMBER m_tagsModel NOTIFY onTagsChanged)
    Q_PROPERTY(QStringList autoTagsModel MEMBER m_autoTagsModel NOTIFY onTagsChanged)
    Q_PROPERTY(QStringList systemTagsModel MEMBER m_systemTagsModel NOTIFY onTagsChanged)
    
    public:
    
    explicit Tags(QObject* parent = nullptr);
    
    Q_INVOKABLE void reload();

    signals:

    void onTagsChanged();
    
    private:
    QStringList m_tagsModel;
    QStringList m_autoTagsModel;
    QStringList m_systemTagsModel;

};

class TagsPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA (IID "Lliurex.Tags")

    public:

    explicit TagsPlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
};


#endif
