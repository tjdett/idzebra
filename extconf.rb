#!/usr/bin/env ruby

# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

IDZEBRA_CFLAGS = `idzebra-config-2.0 --cflags` or `idzebra-config --cflags`
$CFLAGS = $CFLAGS.sub('$(cflags) ', '')
$CFLAGS += " " + IDZEBRA_CFLAGS

# Give it a name
extension_name = 'idzebra'

# The destination
dir_config(extension_name)

# Do the work
create_makefile(extension_name)
