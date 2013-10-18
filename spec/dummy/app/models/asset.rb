# encoding: utf-8

class Asset 
  include Mongoid::Document
  include Uploader::Asset

  belongs_to :assetable, polymorphic: true

  field :guid

  before_save do
    return true if self.assetable_id.nil? || !self.assetable_id.is_a?(String)
    if defined?(Moped::BSON)
      self.assetable_id = Moped::BSON::ObjectId.from_string(self.assetable_id) if Moped::BSON::ObjectId.legal?(self.assetable_id)
    else
      self.assetable_id = BSON::ObjectId.from_string(self.assetable_id) if BSON::ObjectId.legal?(self.assetable_id)
    end
    true
  end
end