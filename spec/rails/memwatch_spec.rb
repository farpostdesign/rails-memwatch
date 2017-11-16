require 'rails_helper'

RSpec.describe Rails::Memwatch do
  it 'has a version number' do
    expect(Rails::Memwatch::VERSION).not_to be nil
  end

  it 'includeable to rails middlewares stack' do
    # middleware included in rails_helper.rb
    expect(
      Rails.configuration.middleware
    ).to include(Rails::Memwatch::Middleware)
  end
end
