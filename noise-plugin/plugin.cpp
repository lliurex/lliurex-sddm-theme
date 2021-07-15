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

#include "plugin.h"

#include <QQmlExtensionPlugin>
#include <QObject>
#include <QQmlEngine>
#include <QAbstractItemModel>
#include <QMimeData>
#include <QSGTexture>
#include <QSGRectangleNode>
#include <QSGOpaqueTextureMaterial>
#include <QQuickWindow>
#include <QSGImageNode>

#include <iostream>
#include <chrono>

using namespace std;

NoiseSurface::NoiseSurface(QQuickItem* parent)
{
    m_depth=2;
    m_frequency=0.01f;
    
    setFlag(ItemHasContents);
}

QSGNode* NoiseSurface::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData)
{
    QSGImageNode  *node = static_cast<QSGImageNode  *>(oldNode);
    //static int seed = 0;
    
    if (!node) {
        node = window()->createImageNode();
        node->setOwnsTexture(true);
        
        QImage* surface = noise::perlin(width(),height(),m_frequency,m_depth);
        QSGTexture* texture = window()->createTextureFromImage(*surface,QQuickWindow::TextureHasAlphaChannel);
        node->setTexture(texture);
        delete surface;
        
        m_width=width();
        m_height=height();
    }
    else {
        double ew = std::abs(m_width-width());
        double eh = std::abs(m_height-height());
        
        if (ew>0.01 || eh>0.01) {
            m_width=width();
            m_height=height();
            
            auto t0 = std::chrono::steady_clock::now();
            QImage* surface = noise::perlin(width(),height(),m_frequency,m_depth);
            auto t1 = std::chrono::steady_clock::now();
            double us = std::chrono::duration_cast<std::chrono::microseconds>(t1-t0).count();
            //clog<<"time: "<<us<<" us"<<endl;
            
            QSGTexture* texture = window()->createTextureFromImage(*surface,QQuickWindow::TextureHasAlphaChannel);
            node->setTexture(texture);
            delete surface;
        }
        
    }
    node->setRect(boundingRect());
    
    return node;
}

UniformSurface::UniformSurface(QQuickItem* parent)
{
    setFlag(ItemHasContents);
}

QSGNode* UniformSurface::updatePaintNode(QSGNode* oldNode, UpdatePaintNodeData* updatePaintNodeData)
{
    QSGImageNode  *node = static_cast<QSGImageNode  *>(oldNode);
    
    if (!node) {
        node = window()->createImageNode();
        node->setOwnsTexture(true);
        
        QImage* surface = noise::uniform(width(),height());
        QSGTexture* texture = window()->createTextureFromImage(*surface,QQuickWindow::TextureHasAlphaChannel);
        node->setTexture(texture);
        delete surface;
        
        m_width=width();
        m_height=height();
    }
    else {
        double ew = std::abs(m_width-width());
        double eh = std::abs(m_height-height());
        
        if (ew>0.01 || eh>0.01) {
            m_width=width();
            m_height=height();
            
            auto t0 = std::chrono::steady_clock::now();
            QImage* surface = noise::uniform(width(),height());
            auto t1 = std::chrono::steady_clock::now();
            double us = std::chrono::duration_cast<std::chrono::microseconds>(t1-t0).count();
            //clog<<"time: "<<us<<" us"<<endl;
            
            QSGTexture* texture = window()->createTextureFromImage(*surface,QQuickWindow::TextureHasAlphaChannel);
            node->setTexture(texture);
            delete surface;
        }
        
    }
    node->setRect(boundingRect());
    
    return node;
}

NoisePlugin::NoisePlugin(QObject* parent) : QQmlExtensionPlugin(parent)
{
}

void NoisePlugin::registerTypes(const char* uri)
{
    qmlRegisterType<NoiseSurface> (uri, 1, 0, "NoiseSurface");
    qmlRegisterType<UniformSurface> (uri, 1, 0, "UniformSurface");
    qmlRegisterAnonymousType<QMimeData>(uri, 1);
    
}
