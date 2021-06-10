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

#ifndef QML_LLIUREX_LOCALE_PLUGIN
#define QML_LLIUREX_LOCALE_PLUGIN

#include <QQmlExtensionPlugin>
#include <QObject>
#include <QList>

class X11KeyLayout: public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString name MEMBER m_name CONSTANT)
public:
    
    explicit X11KeyLayout(QObject* parent = nullptr);
    X11KeyLayout(QString name);

private:
    
    QString m_name;
};

class Language: public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString name MEMBER m_name CONSTANT)
    Q_PROPERTY(QString longName MEMBER m_longName CONSTANT)
    
public:
    
    explicit Language(QObject* parent = nullptr);
    Language(QString name,QString longName);
    
private:
    
    QString m_name;
    QString m_longName;
    
};

class Locale: public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QList<QObject *> languagesModel MEMBER m_languagesModel CONSTANT)
    Q_PROPERTY(QList<QObject *> layoutsModel MEMBER m_layoutsModel CONSTANT)
    
public:
    
    explicit Locale(QObject* parent = nullptr);
    
private:
    QList<QObject*> m_languagesModel;
    QList<QObject*> m_layoutsModel;
};

class LocalePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA (IID "Lliurex.Locale")

public:
    explicit LocalePlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
};


#endif
