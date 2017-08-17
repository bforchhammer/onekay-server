require 'net/http'
require 'uri'
require 'json'

def send_message(to, message, server_key)
  fcm_data = {
      to: to,
      data: {payload: {type: :ADD, payload: message}}
  }
  logger.debug "Firebase request payload: #{fcm_data}"

  uri = URI.parse('https://fcm.googleapis.com/fcm/send')
  headers = {
      'Content-Type': 'application/json',
      'Authorization': "key=#{server_key}"
  }

  # Create the HTTP objects
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = fcm_data.to_json

  # Send the request
  response = http.request(request)

  # Evaluate response and propagate error if necessary
  if response.kind_of? Net::HTTPSuccess
    r = JSON.parse response.body
    r['message_id']
  elsif response.kind_of? Net::HTTPForbidden
    # Todo as server exception somewhere (sentry?)
    halt 500, 'Firebase permission denied'
  else
    halt 500, 'Firebase server error'
  end
end
