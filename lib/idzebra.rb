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
    ffi_lib ['yaz', 'libyaz.so.4'],
      ['yaz_icu', 'libyaz_icu.so.4'],
      ['yaz_server', 'libyaz_server.so.4'],
      ['idzebra-2.0', 'libidzebra-2.0.so.0']

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

    def log_level
      extend Native
      mask = yaz_log_mask_str('')
      case mask
      when yaz_log_mask_str('none,error')
        :error
      when yaz_log_mask_str('none,error,warn')
        :warn
      when yaz_log_mask_str('log')
        :info
      when yaz_log_mask_str('all')
        :default
      else
        mask
      end
    end

    def log_level=(log_level)
      extend Native
      case log_level
      when Numeric
        yaz_log_init_level(log_level)
      when :error
        yaz_log_init_level(yaz_log_mask_str('none,error'))
      when :warn
        yaz_log_init_level(yaz_log_mask_str('none,error,warn'))
      when :info, :default
        yaz_log_init_level(yaz_log_mask_str('log'))
      when :debug, :all
        yaz_log_init_level(yaz_log_mask_str('all'))
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
