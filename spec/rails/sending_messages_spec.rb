require 'rails_helper'

# the middleware configured in spec/rails_helper.rb

RSpec.describe 'Sending messages', type: :feature do
  context 'with Sentry' do
    it 'sends a message when the memory limit exceeded', memory: true do
      expect(Raven).to receive(:capture_message)
      visit '/exceeding-mem-usage'
    end

    it 'does not send a message when the limit is not exceeded', memory: true do
      expect(Raven).to_not receive(:capture_message)
      visit '/normal-mem-usage'
    end
  end
end
