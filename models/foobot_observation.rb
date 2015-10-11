require 'activerecord'

class FoobotObservation < ActiveRecord::Base
  [ "time", "allpolu", "gaspolu", "tmp", "hum", "pm", "pm100", "voc100" ]

  SENSOR_TO_ATTRIBUTE_MAPPING = {
    'allplou' => :all_pollution,
    'gaspolu' => :gas_pollution,
    'tmp' => :temperature,
    'hum' => :humidity,
    'pm' => :pm,
    'pm100' => :pm100,
    'voc100' => :voc100
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
  def self.create_from_api_json!(sensors,row)
    time_index = sensors.find_index('time')
    ts = Time.at(row[time_index])
    fo = self.new(ts: ts)
    SENSOR_TO_ATTRIBUTE_MAPPING.each do |k,v|
      idx = sensors.find_index(k)
      fo.attributes[v] = row[idx]
    end
    fo.save!
  end

end