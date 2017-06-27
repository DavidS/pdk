module Puppet
  class Error < RuntimeError
    attr_accessor :original
    def initialize(message, original=nil)
      # removed encoding scrubbing
      super(message)
      @original = original
    end
  end

  module Util
    module Windows
      module File; end

      if Gem.win_platform?
        # these reference platform specific gems
        # The base class for all Puppet errors. It can wrap another exception

        require 'puppet/util/windows/api_types'
        require 'puppet/util/windows/error'
        require 'puppet/util/windows/string'
        require 'puppet/util/windows/file'
      end
    end
  end
end
