require 'puppet/util/windows'

module PDK::Util::Windows
  require 'ffi'
  extend FFI::Library

  STD_INPUT_HANDLE  = 0xFFFFFFF6
  STD_OUTPUT_HANDLE = 0xFFFFFFF5
  STD_ERROR_HANDLE  = 0xFFFFFFF4

  ENABLE_PROCESSED_OUTPUT            = 0x0001
  ENABLE_WRAP_AT_EOL_OUTPUT          = 0x0002
  ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004

  # https://msdn.microsoft.com/en-us/library/ms683231(v=vs.85).aspx
  #
  # HANDLE WINAPI GetStdHandle(
  #   _In_ DWORD nStdHandle
  # );
  ffi_lib :kernel32
  attach_function_private :GetStdHandle,
    [:dword], :handle

  # https://msdn.microsoft.com/en-us/library/ms683167(v=vs.85).aspx
  #
  # BOOL WINAPI GetConsoleMode(
  #   _In_  HANDLE  hConsoleHandle,
  #   _Out_ LPDWORD lpMode
  # );
  ffi_lib :kernel32
  attach_function_private :GetConsoleMode,
    [:handle, :lpdword], :win32_bool

  # https://msdn.microsoft.com/en-us/library/ms686033(v=vs.85).aspx
  #
  # BOOL WINAPI SetConsoleMode(
  #   _In_ HANDLE hConsoleHandle,
  #   _In_ DWORD  dwMode
  # );
  ffi_lib :kernel32
  attach_function_private :SetConsoleMode,
    [:handle, :dword], :win32_bool


  def get_std_handle(nStdHandle)
    result = GetStdHandle(nStdHandle)
    # if result == FFI::Pointer::NULL
    #   raise "error from GetStdHandle"
    # end
    result
  end
  module_function :get_std_handle

  def get_console_mode(hConsoleHandle)
    currentMode = nil
    FFI::MemoryPointer.new(:dword, 1) do |mode|
      result = GetConsoleMode(hConsoleHandle, mode)

      if result == FFI::WIN32_FALSE
        raise "error from GetConsoleMode"
      end

      currentMode = mode.read(:dword)
    end
    currentMode
  end
  module_function :get_console_mode

  def set_console_mode(hConsoleHandle, mode)
    result = SetConsoleMode(hConsoleHandle, mode)

    if result == FFI::WIN32_FALSE
      raise Puppet::Util::Windows::Error, "Error from SetConsoleMode"
    end

    nil
  end
  module_function :set_console_mode

  def set_vt_processing
    handle = get_std_handle(STD_OUTPUT_HANDLE)
    currentMode = get_console_mode(handle)
    puts "currentMode: #{currentMode.inspect}"
    set_console_mode(handle, ENABLE_PROCESSED_OUTPUT|ENABLE_WRAP_AT_EOL_OUTPUT|ENABLE_VIRTUAL_TERMINAL_PROCESSING)
  end
  module_function :set_vt_processing
end
