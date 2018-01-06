# Visual C++ NMakefile for PDCurses library - Win32 VC++ 2.0+
#
# Usage: nmake -f [path\]vcwin32.mak [DEBUG=] [DLL=] [WIDE=] [UTF8=] [target]
#
# where target can be any of:
# [all|demos|pdcurses.lib|testcurs.exe...]

O = obj
E = .exe
RM = del

!ifndef PDCURSES_SRCDIR
PDCURSES_SRCDIR = ..
!endif

!include $(PDCURSES_SRCDIR)\version.mif
!include $(PDCURSES_SRCDIR)\libobjs.mif

osdir		= $(PDCURSES_SRCDIR)\win32

PDCURSES_WIN_H	= $(osdir)\pdcwin.h

CC		= cl.exe -nologo

!ifdef DEBUG
CFLAGS		= -Z7 -DPDCDEBUG
LDFLAGS		= -debug -pdb:none
!else
CFLAGS		= -O1
LDFLAGS		=
!endif

!ifdef WIDE
WIDEOPT		= -DPDC_WIDE
!endif

!ifdef UTF8
UTF8OPT		= -DPDC_FORCE_UTF8
!endif

SHL_LD = link $(LDFLAGS) /NOLOGO /DLL /OUT:pdcurses.dll

LINK		= link.exe -nologo

CCLIBS		= user32.lib advapi32.lib
# may need to add msvcrt.lib for VC 2.x, VC 5.0 doesn't want it
#CCLIBS		= msvcrt.lib user32.lib advapi32.lib

LIBEXE		= lib -nologo

LIBCURSES	= pdcurses.lib
CURSESDLL	= pdcurses.dll

!ifdef DLL
DLLOPT		= -DPDC_DLL_BUILD
PDCLIBS		= $(CURSESDLL)
!else
PDCLIBS		= $(LIBCURSES)
!endif

BUILD		= $(CC) -I$(PDCURSES_SRCDIR) -c $(CFLAGS) $(DLLOPT) \
$(WIDEOPT) $(UTF8OPT)

all:	$(PDCLIBS) $(DEMOS)

clean:
	-$(RM) *.obj
	-$(RM) *.lib
	-$(RM) *.exe
	-$(RM) *.dll
	-$(RM) *.exp
	-$(RM) *.res

DEMOOBJS = $(DEMOS:.exe=.obj) tui.obj

$(LIBOBJS) $(PDCOBJS) : $(PDCURSES_HEADERS)
$(PDCOBJS) : $(PDCURSES_WIN_H)
$(DEMOOBJS) : $(PDCURSES_CURSES_H)
$(DEMOS) : $(LIBCURSES)
panel.obj : $(PANEL_HEADER)
terminfo.obj: $(TERM_HEADER)

!ifndef DLL
$(LIBCURSES) : $(LIBOBJS) $(PDCOBJS)
	$(LIBEXE) -out:$@ $(LIBOBJS) $(PDCOBJS)
!endif

$(CURSESDLL) : $(LIBOBJS) $(PDCOBJS) pdcurses.obj
	$(SHL_LD) $(LIBOBJS) $(PDCOBJS) pdcurses.obj $(CCLIBS)

pdcurses.res pdcurses.obj: $(osdir)\pdcurses.rc $(osdir)\pdcurses.ico
	rc /r /fopdcurses.res $(osdir)\pdcurses.rc
	cvtres /NOLOGO /OUT:pdcurses.obj pdcurses.res

{$(srcdir)\}.c{}.obj::
	$(BUILD) $<

{$(osdir)\}.c{}.obj::
	$(BUILD) $<

{$(demodir)\}.c{}.obj::
	$(BUILD) $<

.obj.exe:
	$(LINK) $(LDFLAGS) $< $(LIBCURSES) $(CCLIBS)

tuidemo.exe: tuidemo.obj tui.obj
	$(LINK) $(LDFLAGS) $*.obj tui.obj $(LIBCURSES) $(CCLIBS)

tui.obj: $(demodir)\tui.c $(demodir)\tui.h
	$(BUILD) -I$(demodir) $(demodir)\tui.c

tuidemo.obj: $(demodir)\tuidemo.c
	$(BUILD) -I$(demodir) $(demodir)\tuidemo.c

PLATFORM1 = Visual C++
PLATFORM2 = Microsoft Visual C/C++ for Win32
ARCNAME = pdc$(VER)_vc_w32

!include $(PDCURSES_SRCDIR)\makedist.mif
