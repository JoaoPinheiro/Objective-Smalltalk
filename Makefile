#
# Generated by the Apple Project Builder.
#
# NOTE: Do NOT change this file -- Project Builder maintains it.
#
# Put all of your customizations in files called Makefile.preamble
# and Makefile.postamble (both optional), and Makefile will include them.
#

NAME = MPWTalk

PROJECTVERSION = 2.8
PROJECT_TYPE = Framework

CLASSES = MPWStCompiler.m MPWStScanner.m MPWMessageExpression.m

HFILES = MPWStCompiler.h MPWStScanner.h MPWMessageExpression.h

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble m.template\
            h.template

MAKEFILEDIR = $(MAKEFILEPATH)/pb_makefiles
CURRENTLY_ACTIVE_VERSION = YES
DEPLOY_WITH_VERSION_NAME = A
CODE_GEN_STYLE = DYNAMIC
MAKEFILE = framework.make
NEXTSTEP_INSTALLDIR = /Local/Library/Frameworks
WINDOWS_INSTALLDIR = /Local/Library/Frameworks
PDO_UNIX_INSTALLDIR = /Local/Library/Frameworks
LIBS = 
DEBUG_LIBS = $(LIBS)
PROF_LIBS = $(LIBS)


FRAMEWORK_PATHS = -F/Local/Library/Frameworks
FRAMEWORKS = -framework Foundation -framework MPWFoundation
PUBLIC_HEADERS = MPWStCompiler.h

PROJECT_HEADERS = MPWStCompiler.h



NEXTSTEP_OBJCPLUS_COMPILER = /usr/bin/cc
WINDOWS_OBJCPLUS_COMPILER = $(DEVDIR)/gcc
PDO_UNIX_OBJCPLUS_COMPILER = $(NEXTDEV_BIN)/gcc
NEXTSTEP_JAVA_COMPILER = /usr/bin/javac
WINDOWS_JAVA_COMPILER = $(JDKBINDIR)/javac.exe
PDO_UNIX_JAVA_COMPILER = $(JDKBINDIR)/javac

include $(MAKEFILEDIR)/platform.make

-include Makefile.preamble

include $(MAKEFILEDIR)/$(MAKEFILE)

-include Makefile.postamble

-include Makefile.dependencies
