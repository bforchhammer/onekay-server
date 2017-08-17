require 'securerandom'
require 'active_model'

class MessagesPayload
  include ActiveModel::Validations

  attr_accessor :uuid, :message_type, :message_content, :timestamp, :creator_uuid, :creator_handle

  validates :message_type, inclusion: %w(text image)
  validates :message_content, presence: true
  validates :creator_uuid, presence: true

  def initialize(type, content, creator_uuid, creator_handle)
    @uuid = SecureRandom.uuid
    @message_type = type
    @message_content = content
    @timestamp = (Time.now.to_f * 1000).to_i
    @creator_uuid = creator_uuid
    @creator_handle = creator_handle
  end

  def serialized
    {
        uuid: @uuid,
        channel: '/topics/channel_general',
        message: {
            type: @message_type,
            content: @message_content,
        },
        timestamp: @timestamp,
        creator: {
            uuid: @creator_uuid,
            name: @creator_handle,
            avatar: nil,
        }
    }
  end
end
