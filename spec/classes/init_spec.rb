require 'spec_helper'
describe 'sqlwebapp' do

  context 'with defaults for all parameters' do
    it { should contain_class('sqlwebapp') }
  end
end
