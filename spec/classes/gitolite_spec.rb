# frozen_string_literal: true

require 'spec_helper'

describe 'gitolite' do
  let :default_params do
    { user: 'gitolite',
      userhome: '/var/lib/gitolite',
      reporoot: '/var/lib/gitolite/repositories',
      user_ensure: true,
      umask: '0077',
      git_config_keys: '.*',
      log_extra: false,
      log_dest: ['normal'],
      roles: %w[READERS WRITERS],
      site_info: false,
      gitolite_hostname: 'myhostname',
      additional_gitoliterc: {},
      additional_gitoliterc_notrc: {},
      commands: %w[
        help
        desc
        info
        perms
        writable
        ssh-authkeys
        git-config
        daemon
        gitweb
      ],
      package_ensure: 'present',
      packages: ['gitolite3'],
      additional_packages: [],
      fetch_cron: false }
  end

  shared_examples 'gitolite shared examples' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_package('gitolite3')
        .with_ensure(params[:package_ensure])
        .with_tag('gitolite')
    }

    it {
      is_expected.to contain_exec('gitolite_setup')
        .with_command(%r{^su })
        .with_unless(%r{^test -d})
        .with_unless(%r{.gitolite$})
        .with_creates(%r{.gitolite$})
        .with_require(['Package[gitolite3]'])
    }

    it {
      is_expected.to contain_exec('gitolite_compile')
        .with_command(%r{^su })
        .with_refreshonly(true)
    }

    it {
      is_expected.to contain_exec('gitolite_trigger_post_compile')
        .with_command(%r{^su })
        .with_refreshonly(true)
    }

    it {
      is_expected.to contain_file("#{params[:userhome]}/.gitolite.rc")
        .with_mode('0700')
        .with_owner(params[:user])
        .with_notify(['Exec[gitolite_compile]', 'Exec[gitolite_trigger_post_compile]'])
    }

    it {
      is_expected.to contain_file("#{params[:userhome]}/scripts")
        .with_ensure('directory')
        .with_mode('0755')
        .with_owner(params[:user])
    }

    it {
      is_expected.to contain_concat("#{params[:userhome]}/upgrade-repos.sh")
        .with_mode('0700')
        .with_owner('root')
        .with_group('root')
    }

    it {
      is_expected.to contain_concat__fragment("#{params[:userhome]}/upgrade-repos.sh header")
        .with_target("#{params[:userhome]}/upgrade-repos.sh")
        .with_order('00')
    }
  end

  shared_examples 'gitolite shared example user creation' do
    it {
      is_expected.to contain_user(params[:user])
        .with_ensure('present')
        .with_comment('gitolite user')
        .with_home(params[:userhome])
        .with_managehome(true)
        .with_system(true)
        .with_before('Exec[gitolite_setup]')
    }

    it {
      is_expected.to contain_file("#{params[:userhome]}/.ssh")
        .with_ensure('directory')
        .with_owner(params[:user])
        .with_group(params[:user])
        .with_mode('0700')
        .with_require("User[#{params[:user]}]")
    }

    it {
      is_expected.to contain_class('gitolite::ssh_key')
        .with_filename("#{params[:userhome]}/.ssh/id_ed25519")
        .with_type('ed25519')
        .with_user(params[:user])
        .with_require("File[#{params[:userhome]}/.ssh]")
    }
  end

  on_supported_os.each do |_os, _os_facts|
    context "on #{os}, with defaults" do
      let :params do
        default_params
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'

      it {
        is_expected.to contain_cron('fetch gitolite repos upstream')
          .with_ensure('absent')
      }

      it {
        is_expected.not_to contain_file("#{params[:userhome]}/.gitolite/keydir/admin@init1.pub")
      }
    end

    context "on #{os}, without user_ensure" do
      let :params do
        default_params.merge(user_ensure: false)
      end

      it_behaves_like 'gitolite shared examples'

      it {
        is_expected.not_to contain_user(params[:user])
      }

      it {
        is_expected.not_to contain_file("#{params[:userhome]}/.ssh")
      }

      it {
        is_expected.not_to contain_class('gitolite::ssh_key')
      }
    end

    context "on #{os}, with reporoot not in userhome" do
      let :params do
        default_params.merge(reporoot: '/srv/gitolite')
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'

      it {
        is_expected.to contain_file(params[:reporoot])
          .with_ensure('directory')
          .with_owner(params[:user])
          .with_mode('0700')
      }

      it {
        is_expected.to contain_exec('gitolite: move repositories')
          .with_command(%r{^mv })
      }

      it {
        is_expected.to contain_exec('gitolite: remove repositories directory')
          .with_command(%r{^rmdir})
      }
    end

    context "on #{os}, with additional packages" do
      let :params do
        default_params.merge(additional_packages: ['somepackage'])
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'

      it {
        is_expected.to contain_package('somepackage')
      }
    end

    context "on #{os}, with non default user" do
      let :params do
        default_params.merge(user: 'better_user')
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'
    end

    context "on #{os}, with non default userhome" do
      let :params do
        default_params.merge(userhome: '/tmp/git')
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'
    end

    context "on #{os}, with admin_key_source" do
      let :params do
        default_params.merge(admin_key_source: 'file://somewhere')
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'

      it {
        is_expected.to contain_file("#{params[:userhome]}/.gitolite/keydir/admin@init0.pub")
          .with_source(params[:admin_key_source])
      }
    end

    context "on #{os}, with admin_key" do
      let :params do
        default_params.merge(admin_key: 'blah_fasel')
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'

      it {
        is_expected.to contain_file("#{params[:userhome]}/.gitolite/keydir/admin@init1.pub")
          .with_content(params[:admin_key])
      }
    end

    context "on #{os}, with fetch_cron enabled" do
      let :params do
        default_params.merge(fetch_cron: true)
      end

      it_behaves_like 'gitolite shared examples'
      it_behaves_like 'gitolite shared example user creation'

      it {
        is_expected.to contain_cron('fetch gitolite repos upstream')
          .with_user('root')
          .with_command("#{params[:userhome]}/upgrade-repos.sh")
      }
    end
  end
end
