class WriteThread < java.lang.Thread
  def initialize(helper, os)
    @helper, @os = helper, os
    @cmd_list = LinkedList.new
    super()
  end

  def send_cmd(cmd)
    @cmd_list.add(cmd)
    @cmd_list.synchronized { @cmd_list.notifyAll }
  end

  def run
    while !isInterrupted
      next if !self.class.has_cmd(@cmd_list)
      cmd = @cmd_list.removeFirst
      @helper.send_cmd(@os, cmd)
    end

    @cmd_list = nil
  end

  def self.has_cmd(cmd_list)
    if cmd_list.size > 0
      true
    else
      cmd_list.synchronized { cmd_list.wait }
      false
    end
  end
end
