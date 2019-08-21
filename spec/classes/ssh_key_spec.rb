
require 'spec_helper'

describe 'gitolite::ssh_key' do
  let :default_params do
    { filename: '/tmp/ssh_key',
      type: 'rsa',
      length: 2048,
      password: '',
      comment: 'undef',
      user: 'root' }
  end

  shared_examples 'gitolite::ssh_key shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_exec('key for gitolite')
        .with_path(['/usr/bin', '/usr/sbin', '/bin'])
        .with_user(params[:user])
        .with_creates(params[:filename])
        .with_command(%r{^ssh-keygen -t})
    }
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        let :params do
          default_params
        end

        it_behaves_like 'gitolite::ssh_key shared examples'
      end

      context 'with non defaults' do
        let :params do
          default_params.merge(
            filename: '/tmp/another_location',
            type: 'ecdsa',
            length: 4000,
            password: 'password',
            comment: 'somecomment',
            user: 'gitolite',
          )
        end

        it_behaves_like 'gitolite::ssh_key shared examples'
      end
    end
  end
end
