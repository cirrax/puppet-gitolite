
require 'spec_helper'

describe 'gitolite::user' do
  let(:pre_condition) { 'class {"::gitolite": user => "gitolite", userhome => "/tmp/gitolite" }' }
  let(:facts) { { osfamily: 'Debian' } }

  shared_examples 'gitolite::user define' do
    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    it { is_expected.to contain_class('gitolite') }
  end

  context 'whith defaults' do
    let(:title) { 'testuser' }

    it_behaves_like 'gitolite::user define'
  end
end
