class Device
  attr_accessor :device_id, :sensor_type, :value, :category

  def Device.parse_csv(data)
    device = Device.new
    device.device_id   = data[0]
    device.sensor_type = data[1]
    device.set_category(device, data[1])
    device.value       = data[2]
    device
  end

  def Device.parse_json(data)
    device = Device.new
    device.device_id   = data["device_id"]
    device.sensor_type = data["sensor_type"]
    device.set_category(device, data["sensor_type"])
    device.value       = data["value"]
    device
  end

  def Device.parse_xml(data)
    device = Device.new
    device.device_id   = data[0][:id]
    device.sensor_type = data[1][:type]
    device.value       = data[2][:value]
    device.set_category(device, data[1][:type])
    device
  end

  def set_category(device, sensor_type)
    device.category = case sensor_type.to_s
    when "0" then "Temperature sensor"
    when "1" then "Humidity sensor"
    when "2" then "Motion sensor"
    when "3" then "Alien Presence detector"
    when "4" then "Dark Matter detector"
    else
      "Unknown"
    end
  end

  def show_values
    puts "device_id   = #{device_id}", "sensor_type = #{sensor_type}", "value       = #{value}"
  end
end
