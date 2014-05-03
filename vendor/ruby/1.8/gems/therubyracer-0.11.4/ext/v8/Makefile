
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/lib/ruby/1.8/x86_64-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
prefix = $(DESTDIR)/usr
exec_prefix = $(prefix)
infodir = $(prefix)/share/info
sbindir = $(exec_prefix)/sbin
localedir = $(datarootdir)/locale
psdir = $(docdir)
archdir = $(rubylibdir)/$(arch)
localstatedir = $(DESTDIR)/var
sitearchdir = $(sitelibdir)/$(sitearch)
libdir = $(exec_prefix)/lib
datadir = $(datarootdir)
htmldir = $(docdir)
includedir = $(prefix)/include
rubylibdir = $(libdir)/ruby/$(ruby_version)
sysconfdir = $(DESTDIR)/etc
sharedstatedir = $(prefix)/com
vendorarchdir = $(vendorlibdir)/$(sitearch)
sitelibdir = $(sitedir)/$(ruby_version)
mandir = $(prefix)/share/man
dvidir = $(docdir)
libexecdir = $(prefix)/lib/ruby1.8
oldincludedir = $(DESTDIR)/usr/include
vendordir = $(libdir)/ruby/vendor_ruby
sitedir = $(DESTDIR)/usr/local/lib/site_ruby
vendorlibdir = $(vendordir)/$(ruby_version)
pdfdir = $(docdir)
bindir = $(exec_prefix)/bin
docdir = $(datarootdir)/doc/$(PACKAGE)
datarootdir = $(prefix)/share

CC = gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fPIC -fno-strict-aliasing -g -g -O2  -fPIC $(cflags) 
INCFLAGS = -I. -I/usr/local/conbase/vendor/ruby/1.8/gems/libv8-3.11.8.17-x86_64-linux/vendor/v8/include -I. -I/usr/lib/ruby/1.8/x86_64-linux -I.
DEFS     = 
CPPFLAGS =  -D_FORTIFY_SOURCE=2  -D_FORTIFY_SOURCE=2 -Wall -g -rdynamic
CXXFLAGS = $(CFLAGS) 
ldflags  = /usr/local/conbase/vendor/ruby/1.8/gems/libv8-3.11.8.17-x86_64-linux/vendor/v8/out/x64.release/obj.target/tools/gyp/libv8_base.a /usr/local/conbase/vendor/ruby/1.8/gems/libv8-3.11.8.17-x86_64-linux/vendor/v8/out/x64.release/obj.target/tools/gyp/libv8_snapshot.a -L. -Wl,-Bsymbolic-functions -Wl,-z,relro -rdynamic -Wl,-export-dynamic
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CXX) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby1.8
RUBY_SO_NAME = ruby1.8
arch = x86_64-linux
sitearch = x86_64-linux
ruby_version = 1.8
ruby = /usr/bin/ruby1.8
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = /v8
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED) -lpthread  -lpthread -lrt -ldl -lcrypt -lm   -lc
SRCS = trycatch.cc v8.cc script.cc object.cc heap.cc constants.cc invocation.cc gc.cc string.cc stack.cc signature.cc date.cc array.cc template.cc locker.cc backref.cc primitive.cc function.cc message.cc accessor.cc constraints.cc init.cc context.cc exception.cc handles.cc rr.cc external.cc value.cc
OBJS = trycatch.o v8.o script.o object.o heap.o constants.o invocation.o gc.o string.o stack.o signature.o date.o array.o template.o locker.o backref.o primitive.o function.o message.o accessor.o constraints.o init.o context.o exception.o handles.o rr.o external.o value.o
TARGET = init
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /usr/local/conbase/vendor/ruby/1.8/gems/therubyracer-0.11.4/lib$(target_prefix)
RUBYARCHDIR = /usr/local/conbase/vendor/ruby/1.8/gems/therubyracer-0.11.4/lib$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h
