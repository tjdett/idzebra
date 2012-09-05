require 'ffi'

module IdZebra
  module Native
    extend FFI::Library
    
    ffi_lib_flags :now, :global
    ffi_lib ['libyaz'],
      ['libyaz_server'],
      ['libidzebra-2.0', 'libidzebra']
    
    attach_function :zebra_start, [:string], :pointer
    attach_function :zebra_stop, [:pointer], :short
    attach_function :zebra_open, [:pointer, :pointer], :pointer
    attach_function :zebra_close, [:pointer], :short
    
    attach_function :zebra_init, [:pointer], :short
    attach_function :zebra_clean, [:pointer], :short
    attach_function :zebra_commit, [:pointer], :short
    attach_function :zebra_compact, [:pointer], :short
  end
  
end
