# if you want to build the command line version instead of the GIMP
# plug-in, uncomment the following line
#CMDLINE = YES

# if you build the command line version and want to have movie
# (quicktime) support, uncomment the following line
#MOVIES = YES

# if you are building on linux/alpha and have libffm, uncomment the
# following line
#LIBFFM = -lffm

# if you do not want localization (relevant for plug-in version only),
# comment the following line
ENABLE_NLS = YES

# directory where the localization files should be installed in
LOCALEDIR = /usr/local/share/locale

# you should not need to change anything beyond this line
# -------------------------------------------------------

CGEN_CC=-DCGEN_CC="\"gcc -O2 -c -fPIC -o\""
CGEN_LD=-DCGEN_LD="\"gcc -shared -o\""

CGEN_CFLAGS=-DUSE_CGEN $(CGEN_CC) $(CGEN_LD)
CGEN_LDFLAGS=-Wl,--export-dynamic

ifeq ($(CMDLINE),YES)
CFLAGS = -I. $(CGEN_CFLAGS) -Wall -g `glib-config --cflags` -DCMDLINE
LDFLAGS = $(LIBFFM) `glib-config --libs gmodule` -lm -ljpeg -lpng -lz
ifeq ($(MOVIES),YES)
CFLAGS += -I/usr/local/include/quicktime -DMOVIES
LDFLAGS += -lquicktime -lpthread -lz
endif
else
GIMPDIR := .gimp-$(notdir $(shell gimptool --gimpdatadir))

CFLAGS = -I. $(CGEN_CFLAGS) -Wall -g `gimp-config --cflags` -DGIMP -DLOCALEDIR=\"$(LOCALEDIR)\" $(NLS_CFLAGS)
LDFLAGS = $(LIBFFM) `gimp-config --libs`
endif

ifeq ($(ENABLE_NLS),YES)
NLS_CFLAGS = -DENABLE_NLS
MOS = fr.mo
endif

CC = gcc

COMMON_OBJECTS = mathmap_common.o builtins.o exprtree.o parser.o scanner.o postfix.o vars.o tags.o tuples.o internals.o macros.o userval.o overload.o jump.o noise.o lispreader.o spec_func.o compiler.o builtins_interpreter.o

ifeq ($(CMDLINE),YES)
OBJECTS = $(COMMON_OBJECTS) mathmap_cmdline.o readimage.o writeimage.o rwjpeg.o rwpng.o getopt.o getopt1.o
else
OBJECTS = $(COMMON_OBJECTS) mathmap.o
endif

mathmap : $(OBJECTS)
	$(CC) $(CGEN_LDFLAGS) -o mathmap $(OBJECTS) $(LDFLAGS) -lgsl -lgslcblas

compiler : $(COMMON_OBJECTS)
	$(CC) $(CGEN_LDFLAGS) -o compiler $(COMMON_OBJECTS) $(LDFLAGS)

%.o : %.c
	$(CC) $(CFLAGS) -c $<

%.mo : %.po
	msgfmt -o $@ $<

parser.c parser.h : parser.y
	bison -d parser.y
	mv parser.tab.c parser.c
	mv parser.tab.h parser.h

scanner.c : scanner.fl parser.h
	flex scanner.fl
	mv lex.yy.c scanner.c

builtins.o : builtins.c builtins.h

builtins_interpreter.c : builtins_interpreter.chc builtins.chc
	chpp $(ANSI_CHPPFLAGS) builtins_interpreter.chc >builtins_interpreter.c

builtins_compiler.c : builtins_compiler.chc builtins.chc
	chpp $(ANSI_CHPPFLAGS) builtins_compiler.chc >builtins_compiler.c

install : mathmap
	gimptool --install-bin mathmap
	if [ ! -f $(HOME)/$(GIMPDIR)/mathmaprc ] ; then cp mathmaprc $(HOME)/$(GIMPDIR)/ ; fi

install-mos : $(MOS)
	if [ ! -d $(LOCALEDIR)/fr ] ; then mkdir $(LOCALEDIR)/fr ; fi
	if [ ! -d $(LOCALEDIR)/fr/LC_MESSAGES ] ; then mkdir $(LOCALEDIR)/fr/LC_MESSAGES ; fi
	cp fr.mo $(LOCALEDIR)/fr/LC_MESSAGES/mathmap.mo

clean :
	rm -f *~ *.o mathmap compiler scanner.c parser.[ch] parser.output core

realclean : clean
	rm -f builtins_interpreter.c builtins_compiler.c
