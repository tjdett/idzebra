#!/usr/bin/env ruby

require 'mkmf'

IDZEBRA_CFLAGS = `idzebra-config-2.0 --cflags` or `idzebra-config --cflags`
$CFLAGS = $CFLAGS.sub('$(cflags) ', '')
$CFLAGS += " " + IDZEBRA_CFLAGS

create_makefile('idzebra/idzebra')
