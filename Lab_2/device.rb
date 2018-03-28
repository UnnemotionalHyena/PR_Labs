class Device
  attr_accessor :device_id, :sensor_type, :value

  def Device.parse_csv(data)
    device = Device.new
    device.device_id   = data[0]
    device.sensor_type = data[1]
    device.value       = data[2]
    device
  end

  def Device.parse_json(data)
    device = Device.new
    device.device_id   = data["device_id"]
    device.sensor_type = data["sensor_type"]
    device.value       = data["value"]
    device
  end

  def Device.parse_xml(data)
    device = Device.new
    device.device_id   = data[:id]
    device.sensor_type = data[:type]
    device.value       = data[:value]
    device
  end
end
