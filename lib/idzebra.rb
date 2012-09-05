require 'ffi'

module IdZebra
  
  module Native
    extend FFI::Library
    
    UPDATE_ACTIONS = enum [
      :action_insert, 1,
      :action_replace,
      :action_delete,
      :action_update,
      :action_a_delete ]
    
    ffi_lib_flags :now, :global
    ffi_lib ['libyaz'],
      ['libyaz_server'],
      ['libidzebra-2.0', 'libidzebra']
      
    typedef :pointer, :zebra_handle
    typedef :pointer, :zebra_service
    typedef :short,   :zebra_res
    
    # Yaz functions to set logging level
    attach_function :yaz_log_init_level, [:int], :void
    attach_function :yaz_log_mask_str, [:string], :int
    
    attach_function :zebra_start, [:string], :zebra_service
    attach_function :zebra_stop, [:zebra_service], :zebra_res
    attach_function :zebra_open, [:zebra_service, :pointer], :zebra_handle
    attach_function :zebra_close, [:zebra_handle], :zebra_res
    
    attach_function :zebra_init,    [:zebra_handle], :zebra_res
    attach_function :zebra_clean,   [:zebra_handle], :zebra_res
    attach_function :zebra_commit,  [:zebra_handle], :zebra_res
    attach_function :zebra_compact, [:zebra_handle], :zebra_res
    
    attach_function :zebra_add_record, [
      :zebra_handle,
      :string,        # buf
      :int],          # buf_size
      :zebra_res
    attach_function :zebra_update_record, [
      :zebra_handle,
      UPDATE_ACTIONS, # action
      :string,        # recordType
      :long,          # sysno
      :string,        # match
      :string,        # fname
      :string,        # buf
      :int],          # buf_size
      :zebra_res
  end
  
  class << self
    
    def API(config_file, &block)
      extend Native
      log_level = :error
      zs = zebra_start(config_file)
      zh = zebra_open(zs, nil)
      log_level = :default
      yield Repository.new(zh)
      log_level = :error
      zebra_close zh
      zebra_stop zs
    end
    
    def log_level=(log_level)
      extend Native
      case log_level
      when :default
        yaz_log_init_level(yaz_log_mask_str('default'))
      when :error
        yaz_log_init_level(yaz_log_mask_str('none,error'))
      when :warn
        yaz_log_init_level(yaz_log_mask_str('none,error,warn'))
      when :info
        yaz_log_init_level(yaz_log_mask_str('default'))
      when :debug
        yaz_log_init_level(yaz_log_mask_str('debug'))
      end
    end
    
  end
  
  class Repository < Struct.new(:zebra_handle)
    include Native
    
    def init
      zebra_init(zebra_handle)
    end
    
    def compact
      zebra_compact(zebra_handle)
    end
    
    def clean
      zebra_clean(zebra_handle)
    end
    
    def commit
      zebra_commit(zebra_handle)
    end
    
    def add_record(record_str)
      zebra_add_record(zebra_handle, record_str, 0)
    end
    
    def update_record(record_str)
      zebra_update_record(zebra_handle, 
        :action_update, nil, 0, nil, nil, record_str, 0)
    end
    
    def delete_record(record_str)
      zebra_update_record(zebra_handle, 
        :action_delete, nil, 0, nil, nil, record_str, 0)
    end
    
  end
  
end
