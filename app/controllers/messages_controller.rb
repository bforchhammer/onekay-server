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
end
