#
# Copyright 2005-2006 Timo Hirvonen
#
# This file is licensed under the GPLv2.
#
# cmd macro copied from kbuild (Linux kernel build system)

# Build verbosity:
#   make V=0    silent
#   make V=1    clean (default)
#   make V=2    verbose
#
# Source code checking with sparse:
#   make C=1

# build verbosity (0-2), default is 1
ifneq ($(origin V),command line)
  V := 1
endif
ifneq ($(findstring s,$(MAKEFLAGS)),)
  V := 0
endif

# check source code with sparse?
ifneq ($(origin C),command line)
  C := 0
endif

ifeq ($(V),2)
  quiet =
  Q =
else
  ifeq ($(V),1)
    quiet = quiet_
    Q = @
  else
    quiet = silent_
    Q = @
  endif
endif

# simple wrapper around install(1)
#
#  - creates directories automatically
#  - adds $(DESTDIR) to front of files
INSTALL		:= @$(topdir)/scripts/install
INSTALL_LOG	:= $(topdir)/.install.log

SPARSE		?= sparse
SPARSE_FLAGS	?= -D__i386__

dependencies	:= $(wildcard .dep-*)
clean		:= $(dependencies)
distclean	:=

LC_ALL		:= C
LANG		:= C

export INSTALL_LOG LC_ALL LANG

# remove files generated by make
clean:
	rm -f $(clean)

# remove files generated by make and configure
distclean: clean
	rm -f $(distclean)

uninstall:
	@$(topdir)/scripts/uninstall

%.o: %.S
	$(call cmd,as)

# object files for programs and static libs
%.o: %.c
	$(call cmd,sparse)
	$(call cmd,cc)

%.o: %.cc
	$(call cmd,cxx)

%.o: %.cpp
	$(call cmd,cxx)

# object files for shared libs
%.lo: %.c
	$(call cmd,sparse)
	$(call cmd,cc_lo)

%.lo: %.cc
	$(call cmd,cxx_lo)

%.lo: %.cpp
	$(call cmd,cxx_lo)

# CC for programs and shared libraries
quiet_cmd_cc    = CC     $@
quiet_cmd_cc_lo = CC     $@
      cmd_cc    = $(CC) -c $(CFLAGS) -o $@ $<
      cmd_cc_lo = $(CC) -c $(CFLAGS) $(SOFLAGS) -o $@ $<

# LD for programs, optional parameter: libraries
quiet_cmd_ld = LD     $@
      cmd_ld = $(LD) $(LDFLAGS) -o $@ $^ $(1)

# LD for shared libraries, optional parameter: libraries
quiet_cmd_ld_so = LD     $@
      cmd_ld_so = $(LD) -shared $(LDFLAGS) -o $@ $^ $(1)

# CXX for programs and shared libraries
quiet_cmd_cxx    = CXX    $@
quiet_cmd_cxx_lo = CXX    $@
      cmd_cxx    = $(CXX) -c $(CXXFLAGS) -o $@ $<
      cmd_cxx_lo = $(CXX) -c $(CXXFLAGS) $(SOFLAGS) -o $@ $<

# CXXLD for programs, optional parameter: libraries
quiet_cmd_cxxld = CXXLD  $@
      cmd_cxxld = $(CXXLD) $(CXXLDFLAGS) -o $@ $^ $(1)

# CXXLD for shared libraries, optional parameter: libraries
quiet_cmd_cxxld_so = CXXLD  $@
      cmd_cxxld_so = $(CXXLD) -shared $(LDFLAGS) -o $@ $^ $(1)

# create archive
quiet_cmd_ar = AR     $@
      cmd_ar = $(AR) $(ARFLAGS) $@ $^

# assembler
quiet_cmd_as = AS     $@
      cmd_as = $(AS) -c $(ASFLAGS) -o $@ $<

# source code checker
ifneq ($(C),0)
quiet_cmd_sparse = SPARSE $<
      cmd_sparse = $(SPARSE) $(CFLAGS) $(SPARSE_FLAGS) $<
endif

cmd = @$(if $($(quiet)cmd_$(1)),echo '   $(call $(quiet)cmd_$(1),$(2))' &&) $(call cmd_$(1),$(2))

ifneq ($(dependencies),)
-include $(dependencies)
endif

.SECONDARY:

.PHONY: clean distclean uninstall
