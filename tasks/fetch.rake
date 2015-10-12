require_relative '../app'
require_relative '../models/foobot_observation'
require 'faraday'

desc 'Fetch data from Foobot API'
task :fetch do

  conn = Faraday.new(:url => 'https://api.foobot.io/') do |faraday|
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    faraday.basic_auth ENV['USERNAME'], ENV['PASSWORD']
  end


  res = conn.get("https://api.foobot.io/v2/user/#{ENV['USERNAME']}/login/")

  if res.status != 200
    puts 'Response: ' + res.body
    abort('!!! Foobor authentication failed with status ' + res.status)
  end

  token = res.headers['x-auth-token']

  conn = Faraday.new(:url => 'https://api.foobot.io/') do |faraday|
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    faraday.headers['x-auth-token'] = token
  end

  res = conn.get("https://api.foobot.io/v2/owner/#{ENV['USERNAME']}/device/")

  if res.status != 200
    puts 'Response: ' + res.body
    abort('!!! Could not fetch devices. Failed with status: ' + res.status)
  end

  res_json = JSON.parse(res.body)

  foobot = res_json.find { |f| f['name'] == ENV['FOOBOT_NAME'] }

  if foobot.nil?
    abort('!!! Could not find Foobot with name ' + ENV['FOOBOT_NAME'])
  end

  foobot_uuid = foobot['uuid']

  latest_obs = FoobotObservation.latest

  if !ENV['START'].nil?
    start = Time.parse(ENV['START']).utc.iso8601
  else
    if latest_obs.nil?
      start = (Time.now - 86400).utc.iso8601 # Fetch the last day if no observations have been recorded yet
    else
      start = (latest_obs.ts + 1).utc.iso8601
    end
  end

  finish = Time.now.utc.iso8601

  res = conn.get("https://api.foobot.io/v2/device/#{foobot_uuid}/datapoint/#{start}/#{finish}/0/")

  if res.status != 200
    puts 'Response: ' + res.body
    abort('!!! Foobot fetch failed with status ' + res.status.to_s)
  end

  res_json = JSON.parse(res.body)

  # Confirm sensors are as expected
  expected_sensors = %w(time allpollu tmp hum pm voc co2)

  # Find all where they are not included in the response
  not_included = expected_sensors.find_all { |s| !res_json['sensors'].include?(s) }
  if not_included.length > 0
    abort('!!! Response sensors array doesn\'t include ' + not_included.inspect)
  end

  # Confirm units are as expected
  expected_units = {
      'time' => 's',
      'allpollu' => '%',
      'co2' => 'ppm',
      'tmp' => 'C',
      'hum' => 'pc',
      'pm' => 'ugm3',
      'voc' => 'ppb'
  }
  expected_units.each do |measure,unit|
    measure_index = res_json['sensors'].find_index measure
    if res_json['units'][measure_index] != unit
      abort("!!! Unit for measure #{measure} does not match expectation of #{unit}. Instead is " +
            "#{res_json['units'][measure_index]}")
    end
  end

  dup_count = 0

  res_json['datapoints'].each do |dp|
    begin
      FoobotObservation.create_from_api_json! res_json['sensors'], foobot_uuid, dp
    rescue ActiveRecord::RecordNotUnique => ex
      dup_count += 1
    end
  end

  puts "Inserted #{(res_json['datapoints'].length - dup_count)} datapoints."
  puts "Did not insert #{dup_count} duplicates." if dup_count > 0

end
