
Puppet::Type.type(:gitremote).provide(:ruby) do
  desc 'gitclone for posix'

  def create
    # initialy add the git remote
    gitopts = { uid: resource[:confowner] }
    Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'remote', 'add', resource[:remotename], resource[:url]])
    # now we need to set the correct fetchers
    begin
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--unset-all', 'remote.' + resource[:remotename] + '.fetch'], gitopts)
    rescue Puppet::ExecutionFailure
      []
    end
    resource[:fetches].each do |fetch|
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--add', 'remote.' + resource[:remotename] + '.fetch', fetch], gitopts)
    end
  end

  def destroy
    gitopts = { uid: resource[:confowner] }
    # remove the git remote
    Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'remote', 'remove', resource[:remotename]], gitopts)
  end

  def exists?
    # check if the remote  already exists
    gitopts = { uid: resource[:confowner] }
    cmd = ['git', '-C', resource[:directory], 'remote', 'show', '-n' ]
    Puppet::Util::Execution.execute(cmd, gitopts).split("\n").include?(resource[:remotename])
  end

  def url # the ’getter’
    # return the current url of remote, without newline
    gitopts = { uid: resource[:confowner] }
    cmd = ['git', '-C', resource[:directory], 'remote', 'get-url', resource[:remotename]]
    Puppet::Util::Execution.execute(cmd, gitopts).delete("\n")
  end

  def url=(_value) # the ’setter’
    gitopts = { uid: resource[:confowner] }
    Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'remote', 'set-url', resource[:remotename], resource[:url]], gitopts)
  end

  def fetches # the ’getter’
    # return the current fetches

    gitopts = { uid: resource[:confowner] }
    cmd = ['git', '-C', resource[:directory], 'config', '--get-all', 'remote.' + resource[:remotename] + '.fetch']
    Puppet::Util::Execution.execute(cmd, gitopts).split("\n")
  rescue Puppet::ExecutionFailure
    []
  end

  def fetches=(_value) # the ’setter’
    gitopts = { uid: resource[:confowner] }
    #  set the fetches
    begin
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--unset-all', 'remote.' + resource[:remotename] + '.fetch'], gitopts)
    rescue Puppet::ExecutionFailure
      []
    end
    resource[:fetches].each do |fetch|
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--add', 'remote.' + resource[:remotename] + '.fetch', fetch], gitopts)
    end
  end
end
