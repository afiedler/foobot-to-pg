require 'active_record'

class FoobotObservation < ActiveRecord::Base

  SENSOR_TO_ATTRIBUTE_MAPPING = {
    'allpollu' => :all_pollution,
    'tmp' => :temperature,
    'hum' => :humidity,
    'pm' => :pm,
    'co2' => :co2,
    'voc' => :voc
  }

  #
  # Return most recent observation, nil if no observations
  #
  def self.latest
    self.order(:ts).first
  end

  #
  # Create from the Foobot API JSON
  #
  # @param [Array] sensors list of sensors from API
  # @param [Array] row data row
  def self.create_from_api_json!(sensors, uuid, row)
    time_index = sensors.find_index('time')
    ts = Time.at(row[time_index])
    fo = self.new(ts: ts, uuid: uuid)
    SENSOR_TO_ATTRIBUTE_MAPPING.each do |k,v|
      idx = sensors.find_index(k)
      fo.send("#{v}=", row[idx])
    end
    fo.save!
  end

end