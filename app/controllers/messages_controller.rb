require 'sinatra/json'

class MessagesController < ApplicationController
  get '/messages' do
    "You don't GET anything! 😊"
  end

  post '/messages' do
    request.body.rewind # in case someone already read it
    data = JSON.parse request.body.read
    payload = MessagesPayload.new(data['channel'],
                                  data['type'],
                                  data['message'],
                                  request.env['HTTP_USER_UUID'],
                                  request.env['HTTP_USER_NAME'],
                                  request.env['HTTP_USER_AVATAR'])
    if payload.invalid?
      status 400
      json :status => 400, :errors => payload.errors.messages
    else
      payload.send_message(settings.firebase_key)
      status 201
      json :status => 201, :data => payload.serialized_payload
    end
  end

  options '/messages/subscribe' do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST'

    halt 200
  end

  post '/messages/subscribe' do
    request.body.rewind # in case someone already read it
    data = JSON.parse request.body.read
    channel = data['channel']
    registration_token = data['registration_token']

    if channel.nil? or registration_token.nil?
      status 400
      json status: 400, errors: ['Missing channel or registration_token']
    else
      uri = URI.parse("https://iid.googleapis.com/iid/v1/#{registration_token}/rel/topics/#{channel}")
      headers = {
          'Content-Type': 'application/json',
          'Authorization': "key=#{settings.firebase_key}"
      }

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri, headers)

      # Send the request
      response = http.request(request)

      # Evaluate response and propagate error if necessary
      if response.kind_of? Net::HTTPSuccess
        status 200
        json status: 200
      elsif response.kind_of? Net::HTTPForbidden
        # Todo Log as server exception somewhere (sentry?)
        status 500
        json status: 500, errors: ['Firebase permission denied']
      else
        status 500
        json status: 500, errors: ['Firebase server error']
      end
    end

  end
end
