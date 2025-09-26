# frozen_string_literal: true

Puppet::Type.type(:gitremote).provide(:ruby) do
  desc 'gitclone for posix'

  def create
    # initialy add the git remote
    gitopts = { uid: resource[:confowner] }
    Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'remote', 'add', resource[:remotename], resource[:url]], gitopts)
    # now we need to set the correct fetchers
    begin
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--unset-all', "remote.#{resource[:remotename]}.fetch"], gitopts)
    rescue Puppet::ExecutionFailure
      []
    end
    resource[:fetches].each do |fetch|
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--add', "remote.#{resource[:remotename]}.fetch", fetch], gitopts)
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
    cmd = ['git', '-C', resource[:directory], 'remote', 'show', '-n']
    Puppet::Util::Execution.execute(cmd, gitopts).split("\n").include?(resource[:remotename])
  end

  # the 'getter'
  def url
    # return the current url of remote, without newline
    gitopts = { uid: resource[:confowner] }
    cmd = ['git', '-C', resource[:directory], 'remote', 'get-url', resource[:remotename]]
    Puppet::Util::Execution.execute(cmd, gitopts).delete("\n")
  end

  # the 'setter'
  def url=(_value)
    gitopts = { uid: resource[:confowner] }
    Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'remote', 'set-url', resource[:remotename], resource[:url]], gitopts)
  end

  # the 'getter'
  def fetches
    # return the current fetches

    gitopts = { uid: resource[:confowner] }
    cmd = ['git', '-C', resource[:directory], 'config', '--get-all', "remote.#{resource[:remotename]}.fetch"]
    Puppet::Util::Execution.execute(cmd, gitopts).split("\n")
  rescue Puppet::ExecutionFailure
    []
  end

  # the 'setter'
  def fetches=(_value)
    gitopts = { uid: resource[:confowner] }
    #  set the fetches
    begin
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--unset-all', "remote.#{resource[:remotename]}.fetch"], gitopts)
    rescue Puppet::ExecutionFailure
      []
    end
    resource[:fetches].each do |fetch|
      Puppet::Util::Execution.execute(['git', '-C', resource[:directory], 'config', '--add', "remote.#{resource[:remotename]}.fetch", fetch], gitopts)
    end
  end
end
