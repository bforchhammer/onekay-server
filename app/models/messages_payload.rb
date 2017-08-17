require 'securerandom'
require 'active_model'
require 'net/http'
require 'uri'
require 'json'

class MessagesPayload
  include ActiveModel::Validations

  attr_accessor :uuid, :channel_id, :message_type, :message_content, :timestamp, :creator_uuid, :creator_handle

  validates :channel_id, presence: true
  validates :message_type, inclusion: %w(text image)
  validates :message_content, presence: true
  validates :creator_uuid, presence: true

  def initialize(channel, type, content, creator_uuid, creator_handle)
    @channel_id = channel
    @uuid = SecureRandom.uuid
    @message_id = nil # Set after successful send()
    @message_type = type
    @message_content = content
    @timestamp = (Time.now.to_f * 1000).to_i
    @creator_uuid = creator_uuid
    @creator_handle = creator_handle
    @creator_avatar = nil
  end

  def fcm_data
    {
        to: "/topic/#{@channel_id}",
        data: {
            payload: {
                type: :ADD,
                payload: serialized_payload,
            }
        }
    }
  end

  def serialized_payload
    {
        uuid: @uuid,
        channel_id: @channel_id,
        content: {
            type: @message_type,
            value: @message_content,
        },
        timestamp: @timestamp,
        creator: {
            uuid: @creator_uuid,
            name: @creator_handle,
            avatar: @creator_avatar,
        }
    }
  end

  def send_message(firebase_key)
    uri = URI.parse('https://fcm.googleapis.com/fcm/send')
    headers = {
        'Content-Type': 'application/json',
        'Authorization': "key=#{firebase_key}"
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
      @message_id = r['message_id']
      true
    elsif response.kind_of? Net::HTTPForbidden
      # Todo Log as server exception somewhere (sentry?)
      halt 500, 'Firebase permission denied'
    else
      halt 500, 'Firebase server error'
    end
  end

end
