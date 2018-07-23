
require 'spec_helper'

describe 'gitolite::params' do
  let(:facts) {{:osfamily => 'Debian' }}

  shared_examples 'gitolite::params shared examples' do
    it { is_expected.to compile.with_all_deps }
  end

  context 'with defaults' do
    it_behaves_like 'gitolite::params shared examples'
  end

end


