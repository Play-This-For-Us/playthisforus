require 'rails_helper'

RSpec.describe 'Home' do
  it 'contains our application name' do
    visit root_path
    expect(page).to have_content 'Play This'
  end
end
