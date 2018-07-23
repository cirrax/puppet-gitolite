
require 'spec_helper'

describe 'gitolite::repos' do

  shared_examples 'gitolite::repos define' do

    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end
  end

  context 'whith defaults' do
    let (:title) { 'repos' }

    it_behaves_like 'gitolite::repos define'

  end
end

