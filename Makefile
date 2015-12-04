enet/Makefile:
	cd enet; ./configure --enable-shared=yes --enable-static=yes

libenet: enet/Makefile
	-$(MAKE) -C enet all

liblua:
	cd lua/src; $(MAKE) mingw

mingw:
	$(MAKE) -f Makefile.mingw

mingw-clean:
	$(MAKE) -f Makefile.mingw clean

msvc:
	nmake.exe -f Makefile.msvc

linux: libenet
	$(MAKE) -f Makefile.linux

linux-clean:
	$(MAKE) -f Makefile.linux clean

libenet-clean: enet/Makefile
	$(MAKE) -C enet clean

liblua-clean:
	cd lua/src && $(MAKE) clean

clean: libenet-clean liblua-clean linux-clean
