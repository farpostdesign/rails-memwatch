require 'rails'
require 'action_controller'
require 'rails/memwatch'
require 'sentry-raven-without-integrations'

# module SpecSupport
#   # = Spec extension to mem watch middleware
#   module Middleware
#     @_messages = []

#     def included(middleware)
#       middleware.send(:alias_method, :prev_call, :call)
#       middleware.send(:alias_method, :call, :extended_call)
#     end

#     def self.messages
#       @_messages
#     end

#     def self.store_message(msg)
#       @_messages.push(msg)
#     end

#     def extended_call(*args)

#     end
#   end
# end
# Rails::Memwatch::Middleware.send(:include, SpecSupport::Middleware)

ENV['RAILS_ENV'] = 'test'
abort('Wrong Rails environment in tests') if Rails.env.production?

class TestApp < Rails::Application
  routes.append do
    get '/exceeding-mem-usage', to: 'application#exceeding'
    get '/normal-mem-usage', to: 'application#normal'
  end

  config.eager_load = false
  # memory limit 3 megabyte
  config.middleware.use Rails::Memwatch.middleware, 3, ::Raven

  config.secret_key_base = 'testsectret'
end

class ApplicationController < ActionController::Base
  def normal
    render text: ''
  end

  def exceeding
    render text: 'a' * 31000000
  end
end

TestApp.initialize!

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.after(:each, memory: true) do
    # memory = Rails::Memwatch::Middleware::GetProcessMem.new(PID)
    # puts "#{memory.mb} Mb used"
  end
end
