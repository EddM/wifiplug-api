class DeviceAPIListener
  include ClientCMDHelper::CommandListener
  
  attr_reader :service

  def initialize(service)
    @service = service
  end

  # onReceiveCommand is the only interface method we need to define. 
  # Accepts a ServiceCommand object, whose CMDByte property determines
  # what kind of message we got from the server
  def onReceiveCommand(cmd)
    case cmd.CMDByte

    # CMD01: When server requests login, send username and password (and gmt time offset in hours)
    when CMD01_ServerLoginPermit::Command
      service.write_thread.send_cmd CMD02_Login.new(service.username, service.password, 0.0, 0)

    # CMD03: Login was successful so request all registered devices
    when CMD03_ServerLoginRespond::Command
      service.write_thread.send_cmd CMD04_GetAllDeviceList.new
      service.callback(:auth_successful, cmd)

    # CMD05: Received a list of devices so populate our list
    when CMD05_ServerRespondAllDeviceList::Command
      for device in cmd.deviceList
        service.devices << device if device.is_a?(DeviceStatus)
      end
      service.callback(:received_devices, cmd)

    # CMD09: Device control status successfully changed
    when CMD09_ServerControlResult::Command
      service.callback(:device_state_changed, cmd)

    # CMDFB: "Are you still there?"
    when CMDFB_ServerIdle::Command
      service.write_thread.send_cmd CMDFC_IdleSucc.new
      service.callback(:server_idle, cmd)

    # CMDFF: Exception occurred
    when CMDFF_ServerException::Command
      raise "ErrorCode: #{cmd.code} (#{cmd.info})"

    end

  end
end
