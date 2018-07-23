
require 'spec_helper'

describe 'gitolite::repo' do
  let(:pre_condition) { 'class {"::gitolite": user => "gitolite", userhome => "/tmp/gitolite" }' }
  let(:facts) {{:osfamily => 'Debian' }}

  let :default_params do
     { :repos       => ['testrepo'],
       :comments    => [],
       :rules       => {},
       :options     => {},
       :configs     => {},
       :add_configs => {},
       :groups      => [],
       :order       => '',
       :description => '',
       :hooks       => {},
       :group       => 'root',
       :remotes     => {},
     }
  end


  shared_examples 'gitolite::repo define' do

    context 'it compiles with all dependencies' do
      it { is_expected.to compile.with_all_deps }
    end
 
    it { is_expected.to contain_class('gitolite') }

    it { is_expected.to contain_concat__fragment('gitolite_conffile repo ' + title)
      .with_order('90' + params[:order])
    }

    it { is_expected.to contain_file('/tmp/gitolite/repositories/' + title + '.git/hooks')
      .with_ensure('directory')
      .with_mode('0700')
      .with_purge(true)
      .with_recurse(true)
    }

    it { is_expected.to contain_file('/tmp/gitolite/repositories/' + title + '.git/hooks/update')
      .with_ensure('link')
      .with_owner('gitolite')
      .with_group(params[:group])
    }
  end

  context 'whith defaults' do
    let (:title) { 'testrepo' }
    let :params do
      default_params
    end
    it_behaves_like 'gitolite::repo define'

  end

  context 'whith description' do
    let (:title) { 'anotherrepo' }
    let :params do
      default_params.merge( :description => 'my description')
    end
    it_behaves_like 'gitolite::repo define'

    it { is_expected.to contain_file('/tmp/gitolite/repositories/' + title + '.git/description')
      .with_content('my description')
      .with_group('root')
      .with_owner('gitolite')
    }
  end

  context 'whith groups' do
    let (:title) { 'grouprepo' }
    let :params do
      default_params.merge( :groups => ['blah'])
    end
    it_behaves_like 'gitolite::repo define'

    it { is_expected.to contain_concat__fragment('gitolite_conffile groups (repo) ' + title)
      .with_order('60' + params[:order])
    }
  end

  context 'with hooks' do
    let (:title) { 'hookrepo' }
    let :params do
      default_params.merge( :hooks => {'hook1' => {}})
    end
    it_behaves_like 'gitolite::repo define'

    it { is_expected.to contain_file('/tmp/gitolite/repositories/' + title + '.git/hooks/hook1')
      .with_ensure('link')
      .with_owner('gitolite')
      .with_group('root')
    }
  end

  context 'with remotes' do
    let (:title) { 'remoterepo' }
    let :params do
      default_params.merge( :remotes => {'upstream' => {'url' => 'http://blah'}, 'noup' => { 'ensure' => 'absent'}})
    end
    it_behaves_like 'gitolite::repo define'

    it { is_expected.to contain_gitremote('upstream')
      .with_ensure('present')
      .with_directory('/tmp/gitolite/repositories/' + title + '.git')
      .with_confowner('gitolite')
      .with_url('http://blah')
    }

    it { is_expected.to contain_gitremote('noup')
      .with_ensure('absent')
      .with_directory('/tmp/gitolite/repositories/' + title + '.git')
      .with_confowner('gitolite')
    }

    it { is_expected.to contain_concat__fragment('gitolite upgrade-repos.sh: ' + title + ' upstream')
    }

    it { is_expected.to_not contain_concat__fragment('gitolite upgrade-repos.sh: ' + title + ' noup')
    }
  end
end
