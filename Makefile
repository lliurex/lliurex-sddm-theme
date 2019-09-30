build:

get-translations:
	xgettext -kde -ki18nd:2 lliurex-desktop/*.qml lliurex-desktop/ui/*.qml
	
install-desktop:
	mkdir -p $(DESTDIR)/usr/share/sddm/themes
	mkdir -p $(DESTDIR)/usr/lib/sddm/sddm.conf.d
	mkdir -p $(DESTDIR)/usr/lib/systemd/system

	cp -r lliurex-desktop $(DESTDIR)/usr/share/sddm/themes/
	cp -r conf/80-lliurex-desktop.conf $(DESTDIR)/usr/lib/sddm/sddm.conf.d/
	cp -r sddm.service.d $(DESTDIR)/usr/lib/systemd/system/

install-classroom: install-desktop
	cp -r lliurex-classroom $(DESTDIR)/usr/share/sddm/themes/
	cp -r conf/85-lliurex-classroom.conf $(DESTDIR)/usr/lib/sddm/sddm.conf.d/

install-server: install-classroom
	cp -r lliurex-server $(DESTDIR)/usr/share/sddm/themes/
	cp -r conf/86-lliurex-server.conf $(DESTDIR)/usr/lib/sddm/sddm.conf.d/

install: install-server

.PHONY: all clean install build
