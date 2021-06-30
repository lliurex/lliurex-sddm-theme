/*
 * Copyright (C) 2020 Lliurex project
 *
 * Author:
 *  Enrique Medina Gremaldos <quiqueiii@gmail.com>
 *
 * Source:
 *  https://github.com/edupals/qml-module-edupals-n4d
 *
 * This file is a part of qml-module-edupals-n4d.
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

#ifndef QML_LLIUREX_NOISE_PLUGIN
#define QML_LLIUREX_NOISE_PLUGIN

#include "noise.h"

#include <QQmlExtensionPlugin>
#include <QObject>
#include <QQuickItem>
#include <QSGGeometryNode>

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

class UniformSurface : public QQuickItem
{
    Q_OBJECT
    
    
public:
    explicit UniformSurface(QQuickItem* parent = nullptr);

protected:
    virtual QSGNode* updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData) override;

private:
    QSGGeometryNode* m_Texture;
    double m_width;
    double m_height;
    
};

class NoisePlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA (IID "Lliurex.Noise")

public:
    explicit NoisePlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
};


#endif
