require '../app'
require '../models/foobot_observation'
require 'httpclient'

desc 'Fetch data from Foobot API'
task :fetch do
  http = HTTPClient.new
  http.set_auth('https://api.foobot.io/', ENV['USERNAME'], ENV['PASSWORD'])

  res = http.get("https://api.foobot.io/v2/user/#{ENV['USERNAME']}/login/")

  if res.status != 200
    puts 'Response: ' + res.body
    abort('!!! Foobor authentication failed with status ' + res.status)
  end

  token = res.header['X-AUTH-TOKEN']

  latest_obs = FoobotObservation.latest

  if !ENV['START'].nil?
    start = Time.parse(ENV['START']).utc.iso8601
  else
    if latest_obs.nil?
      start = '86400' # Fetch the last day if no observations have been recorded yet
    else
      start = (latest_obs.ts + 1).utc.iso8601
    end
  end

  if start == '86400'
    finish = 'last'
  else
    finish = Time.now.utc.iso8601
  end

  res = http.get("https://api.foobot.io/v2/device/#{ENV['FOOBOT_UUID']}/datapoint/#{start}/#{finish}/0/")

  if res.status != 200
    puts 'Response: ' + res.body
    abort('!!! Foobot fetch failed with status ' + res.status)
  end

  res_json = JSON.parse(res.body)

  # Confirm sensors are as expected
  if res_json['sensors'] != %w(time allpolu gaspolu tmp hum pm pm100 voc100)
    puts('Sensors array: ' + res_json['sensors'].inspect)
    abort('!!! Response sensors array doesn\'t match expectation')
  end

  # Confirm units are as expected
  if res_json['units'] != ['s', 'ppm', 'ppm', '°C', '%', 'mugm3', '%', '%']
    puts('Units array: ' + res_json['units'].inspect)
    abort('!!! Response units array doesn\'t match expectation')
  end

  dup_count = 0

  FoobotObservation.transaction do
    res_json['datapoints'].each do |dp|
      begin
        FoobotObservation.create_from_api_json! res_json['sensors'], dp
      rescue ActiveRecord::RecordNotUnique => ex
        dup_count += 1
      end
    end
  end

  puts "Inserted #{res_json['datapoints'].length} datapoints."
  puts "Did not insert #{dup_count} duplicates." if dup_count > 0

end
