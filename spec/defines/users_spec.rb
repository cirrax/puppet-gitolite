# frozen_string_literal: true

require 'spec_helper'

describe 'gitolite::users' do
  shared_examples 'gitolite::users define' do
    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'users' }

        it_behaves_like 'gitolite::users define'
      end
    end
  end
end
