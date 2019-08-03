
Puppet::Type.newtype(:gitremote) do
  @doc = 'add a remote to a git repository'

  ensurable

  # parameters: change the way how the provider work
  newparam(:name) do
    desc 'the title'
  end

  newparam(:remotename) do
    desc 'the name of the remote to create'
  end

  newparam(:directory) do
    desc 'the the directory the repository is'
  end

  newparam(:confowner) do
    desc 'the the owner of the config file'
  end

  newproperty(:url) do
    desc 'the url of the remote repository'
  end

  newproperty(:fetches, array_matching: :all) do
    desc 'Array of fetch definitions'
  end
end
