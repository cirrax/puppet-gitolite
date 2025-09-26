# frozen_string_literal: true

require 'spec_helper'

describe 'gitolite::user' do
  let(:pre_condition) { 'class {"::gitolite": user => "gitolite", userhome => "/tmp/gitolite" }' }

  shared_examples 'gitolite::user define' do
    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end

    it { is_expected.to contain_class('gitolite') }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'whith defaults' do
        let(:title) { 'testuser' }

        it_behaves_like 'gitolite::user define'
      end
    end
  end
end
