#color constants
COLOR_NONE = \x1b[0m
COLOR_GREEN = \x1b[32;01m
COLOR_RED = \x1b[31;01m

install-desktop:
	@echo -e '$(COLOR_RED)* installing desktop theme... $(COLOR_NONE)'
	cp -r lliurex-desktop $(DESTDIR)/usr/share/sddm/themes/
	cp -r conf/80-lliurex-desktop.conf $(DESTDIR)/usr/lib/sddm/sddm.conf.d/
	cp -r sddm.service.d $(DESTDIR)/usr/lib/systemd/system/

install-classroom: install-desktop
	@echo -e '$(COLOR_RED)* installing classroom theme... $(COLOR_NONE)'
	cp -r lliurex-classroom $(DESTDIR)/usr/share/sddm/themes/
	cp -r conf/85-lliurex-classroom.conf $(DESTDIR)/usr/lib/sddm/sddm.conf.d/

install-server: install-classroom
	@echo -e '$(COLOR_RED)* installing server theme... $(COLOR_NONE)'
	cp -r lliurex-server $(DESTDIR)/usr/share/sddm/themes/
	cp -r conf/86-lliurex-server.conf $(DESTDIR)/usr/lib/sddm/sddm.conf.d/

install: install-server

.PHONY: all clean install