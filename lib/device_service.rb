class ObscureChineseWifiDeviceService

  attr_accessor :listener, :callbacks
  attr_reader :socket, :listener, :username, :password, :devices, :write_thread, :read_thread

  def initialize(host, port)
    @socket = Socket.new(host, port)
    @devices, @callbacks = [], {}
  end

  def helper
    @helper ||= begin
      helper = ClientCMDHelper.getInstance
      helper.setCommandListener(listener)
      helper
    end
  end

  # Implementors can provide their own listener, or we use the default that does the bare minimum
  def listener
    @listener ||= DeviceAPIListener.new(self)
  end

  # Initiate the connection to the server and authenticate with the given username/password
  def connect(username, password)
    @username, @password = username, password

    @read_thread = self.class.start_read_thread(helper, @socket.getInputStream)
    @write_thread = self.class.start_write_thread(helper, @socket.getOutputStream)
    @write_thread.send_cmd CMD00_ConnectRequest.new
  end

  # Set up some callbacks that get fired based on incoming messages
  # from the server. Pass each a block:
  #
  #    service.auth_successful do |service, cmd|
  #      puts "Yay we got in"
  #    end
  #
  %w(auth_successful received_devices server_idle).each do |cb|
    define_method(cb) { |&blk| @callbacks[cb.to_sym] = blk }
  end

  def callback(type, cmd = nil)
    func = @callbacks[type.to_sym]
    func.call(self, cmd) if func
  end

  private

  def self.start_write_thread(helper, output_stream)
    thread = WriteThread.new helper, output_stream
    thread.start
    thread
  end

  def self.start_read_thread(helper, input_stream)
    Thread.new { helper.parseCMD(input_stream) }
  end

end
