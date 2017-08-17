require 'sinatra/json'
require_relative '../helpers/firebase'

class MessagesController < ApplicationController
  get '/messages' do
    "You don't GET anything! 😊"
  end

  post '/messages' do
    request.body.rewind # in case someone already read it
    data = JSON.parse request.body.read
    payload = MessagesPayload.new(data['type'],
                                  data['message'],
                                  request.env['HTTP_X_USER_UUID'],
                                  request.env['HTTP_X_USER_NAME'])
    if payload.invalid?
      status 400
      json :status => 400, :errors => payload.errors.messages
    else
      payload_hash = payload.serialized
      payload_hash[:message_id] = send_message('/topics/channel_general', payload_hash, settings.firebase_key)
      status 201
      json :status => 201, :data => payload_hash
    end
  end
end
