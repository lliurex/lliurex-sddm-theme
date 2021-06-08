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
#include <QQuickItem>

class NoiseSurface : public QQuickItem
{
    Q_OBJECT
    
    Q_PROPERTY(float frequency MEMBER m_frequency)
    Q_PROPERTY(int depth MEMBER m_depth)
    
public:
    explicit NoiseSurface(QQuickItem* parent = nullptr);

protected:
    virtual QSGNode* updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData) override;

private:
    QSGGeometryNode* m_Texture;
    double m_width;
    double m_height;
    
    float m_frequency;
    int m_depth;
};

class LocalePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA (IID "Lliurex.Locale")

public:
    explicit NoisePlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
};


#endif
