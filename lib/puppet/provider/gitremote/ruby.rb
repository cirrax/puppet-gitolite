
Puppet::Type.type(:gitremote).provide(:ruby) do
  desc "gitclone for posix"

  commands :gitcommand => "git",
           :chowncommand => "chown"

  def create
    # initialy add the git remote
    gitcommand "-C", resource[:directory],  "remote", "add", resource[:name],  resource[:url]
    # now we need to set the correct fetchers
    begin
      (gitcommand "-C", resource[:directory],  "config", "--unset-all", "remote." + resource[:name] + ".fetch")
      rescue Puppet::ExecutionFailure => e
    end
    resource[:fetches].each do | fetch |
      (gitcommand "-C", resource[:directory],  "config", "--add", "remote." + resource[:name] + ".fetch", fetch)
    end
    chowncommand resource[:confowner], resource[:directory] + "/config"
  end

  def destroy
    # remove the git remote
    gitcommand "-C", resource[:directory],  "remote", "remove", resource[:name]
    chowncommand resource[:confowner], resource[:directory] + "/config"
  end

  def exists?
    # check if the remote  already exists
    (gitcommand "-C", resource[:directory],  "remote", "show", "-n").split("\n").include?(resource[:name])
  end

  def url # the ’getter’
    # return the current url of remote, without newline
    (gitcommand "-C", resource[:directory],  "remote", "get-url", resource[:name]).gsub("\n",'')
  end

  def url=(value) # the ’setter’
    #  the correct the remote url
    gitcommand "-C", resource[:directory],  "remote", "set-url", resource[:name], resource[:url]
    chowncommand resource[:confowner], resource[:directory] + "/config"
  end

  def fetches # the ’getter’
    # return the current fetches
    begin
      (gitcommand "-C", resource[:directory],  "config", "--get-all", "remote." + resource[:name] + ".fetch").split("\n")
    rescue Puppet::ExecutionFailure => e
      []
    end
  end

  def fetches=(value) # the ’setter’
    #  set the fetches
    begin
      (gitcommand "-C", resource[:directory],  "config", "--unset-all", "remote." + resource[:name] + ".fetch")
      rescue Puppet::ExecutionFailure => e
    end
    resource[:fetches].each do | fetch |
      (gitcommand "-C", resource[:directory],  "config", "--add", "remote." + resource[:name] + ".fetch", fetch)
    end
    chowncommand resource[:confowner], resource[:directory] + "/config"
  end
end
