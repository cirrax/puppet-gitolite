
require 'spec_helper'

describe 'gitolite::admin' do

  let(:pre_condition) { 'class {"::gitolite": user => "gitolite", userhome => "/tmp/gitolite" }' }

  let(:facts) {{:osfamily => 'Debian' }}

  let :default_params do
     { :remove_admin_repo => true,
       :repos             => {},
       :users             => {},
       :add_testing_repo  => true,
     }
  end

  shared_examples 'gitolite::admin shared examples' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('gitolite::params') }

    it { is_expected.to contain_concat('/tmp/gitolite/.gitolite/conf/gitolite.conf')
      .with_ensure('present')
    }

    it { is_expected.to contain_concat__fragment('gitolite_conf_main_header')
      .with_order('00')
    }
    it { is_expected.to contain_concat__fragment('gitolite_conf_user_group_header')
      .with_order('30')
    }
    it { is_expected.to contain_concat__fragment('gitolite_conf_repo_group_header')
      .with_order('50')
    }
    it { is_expected.to contain_concat__fragment('gitolite_conf_repo_header')
      .with_order('80')
    }

    it { is_expected.to contain_file('/tmp/gitolite/.puppet_userkeys')
      .with_ensure('directory')
      .with_force(true)
      .with_recurse(true)
      .with_purge(true)
      .with_notify('Exec[gitolite update user keys from source]')
    }

    it { is_expected.to contain_exec('gitolite update user keys from source')
      .with_command(/^\/bin\/true/)
      .with_refreshonly(true)
      .with_before('File[/tmp/gitolite/.gitolite/keydir]')
      .with_require('File[/tmp/gitolite/.puppet_userkeys]')
    }
  end

  context 'with defaults' do
    let :params do
      default_params
    end
    it_behaves_like 'gitolite::admin shared examples'

    it { is_expected.to contain_gitolite__repo('testing')
      .with_rules({"RW+"=>"@all"})
      .with_comments(['default for testing repo'])
    }

    it { is_expected.to contain_file('/tmp/gitolite/repositories/gitolite-admin.git')
    }
  end

  context 'with removal of admin_repo' do
    let :params do
      default_params.merge(:remove_admin_repo => true)
    end
    it_behaves_like 'gitolite::admin shared examples'

    it { is_expected.to contain_file('/tmp/gitolite/repositories/gitolite-admin.git')
      .with_ensure('absent')
      .with_force(true)
      .with_backup(false)
    }
  end

  context 'without creation of testing repo' do
    let :params do
      default_params.merge(:add_testing_repo => false)
    end
    it_behaves_like 'gitolite::admin shared examples'

    it { is_expected.not_to contain_gitolite__repo('testing')
    }
  end

  context 'with users' do
    let :params do
      default_params.merge(:users => { 'someuser' => {} })
    end
    it_behaves_like 'gitolite::admin shared examples'

    it { is_expected.to contain_gitolite__user('someuser')
    }
  end

  context 'with repos' do
    let :params do
      default_params.merge(:repos => { 'myrepo' => {} })
    end
    it_behaves_like 'gitolite::admin shared examples'

    it { is_expected.to contain_gitolite__repo('myrepo')
    }
  end


end


