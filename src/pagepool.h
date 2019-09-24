/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
#pragma once

#include <QObject>
#include <QQuickItem>

/**
 * A Pool of Page items, pages will be unique per url and the items
 * will be kept around unless explicitly deleted.
 * Instaces are C++ owned and can be deleted only manually using deletePage()
 * Instance are unique per url: if you need 2 different instance for a page
 * url, you should instantiate them in the traditional way
 * or use a different PagePool instance.
 */
class PagePool : public QObject
{
    Q_OBJECT
    /**
     * The last url that was loaded with @loadPage. Useful if you need
     * to have a "checked" state to buttons or list items that
     * load the page when clicked.
     */
    Q_PROPERTY(QUrl lastLoadedUrl READ lastLoadedUrl NOTIFY lastLoadedUrlChanged)

    /**
     * If true (default) the pages will be kept around, will have C++ ownership and only one instance per page will be created.
     * If false the pages will have Javascript ownership (thus deleted on pop by the page stacks) and each call to loadPage will create a new page instance. When cachePages is false, Components gets cached never the less
     */
    Q_PROPERTY(bool cachePages READ cachePages WRITE setCachePages NOTIFY cachePagesChanged)

public:
    PagePool(QObject *parent = nullptr);
    ~PagePool();

    QUrl lastLoadedUrl() const;

    void setCachePages(bool cache);
    bool cachePages() const;

    /**
     * Returns the instance of the item defined in the QML file identified
     * by url, only one instance will be made per url if cachePAges is true. If the url is remote (i.e. http) don't rely on the return value but us the async callback instead
     * @param url full url of the item: it can be a well formed Url,
     *       an absolute path
     *       or a relative one to the path of the qml file the PagePool is instantiated from
     * @param callback If we are loading a remote url, we can't have the item immediately but will be passed as a parameter to the provided callback.
     * Normally, don't set a callback, use it only in case of remote urls.
     * @returns the page instance that will have been created if necessary. 
     *          If the url is remote it will return null,
     *          as well will return null if the callback has been provided
     */
    Q_INVOKABLE QQuickItem *loadPage(const QString &url, QJSValue callback = QJSValue());

    /**
     * @returns The url of the page for the given instance, empty if there is no correspondence
     */
    Q_INVOKABLE QUrl urlForPage(QQuickItem *item) const;

    /**
     * @returns true if the is managed by the PagePool
     * @param the page can be either a QQuickItem or an url
     */
    Q_INVOKABLE bool contains(const QVariant &page) const;

    /**
     * Deletes the page (only if is managed by the pool.
     * @param page either the url or the instance of the page
     */
    Q_INVOKABLE void deletePage(const QVariant &page);

    /**
     * @returns full url from an absolute or relative path
     */
    Q_INVOKABLE QUrl resolvedUrl(const QString &file) const;

    /**
     * @returns true if the url identifies a local resource (local file or a file inside Qt's resource system).
     * False if the url points to a network location
     */
    Q_INVOKABLE bool isLocalUrl(const QUrl &url);

Q_SIGNALS:
    void lastLoadedUrlChanged();
    void cachePagesChanged();

private:
    QQuickItem *createFromComponent(QQmlComponent *component);

    QUrl m_lastLoadedUrl;
    QHash<QUrl, QQuickItem *> m_itemForUrl;
    QHash<QUrl, QQmlComponent *> m_componentForUrl;
    QHash<QQuickItem *, QUrl> m_urlForItem;

    bool m_cachePages = true;
};

