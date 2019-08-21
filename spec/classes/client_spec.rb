
require 'spec_helper'

describe 'gitolite::client' do
  shared_examples 'gitolite::client shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_package('git') }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it_behaves_like 'gitolite::client shared examples'
      end
    end
  end
end
