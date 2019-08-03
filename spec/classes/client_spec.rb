
require 'spec_helper'

describe 'gitolite::client' do
  let(:facts) { { osfamily: 'Debian' } }

  shared_examples 'gitolite::client shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_package('git') }
  end

  context 'with defaults' do
    it_behaves_like 'gitolite::client shared examples'
  end
end
