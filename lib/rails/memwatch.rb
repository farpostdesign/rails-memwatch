require 'rails/memwatch/version'
require 'rails/memwatch/middleware'

module Rails
  # = Gem main module
  module Memwatch
    module_function

    # Return the memory watch middleware
    def middleware
      Rails::Memwatch::Middleware
    end
  end
end
