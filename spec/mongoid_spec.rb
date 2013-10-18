require 'spec_helper'

class MongoidArticle
  include Mongoid::Document
  include Uploader::Fileuploads

  has_one :mongoid_picture, :as => :assetable

  fileuploads :mongoid_picture
end

class MongoidPicture
  include Mongoid::Document
  include Uploader::Asset

  field :guid

  belongs_to :assetable, polymorphic: true
end

describe Uploader::Asset do
  before do
    @guid = 'guid'
    @picture = MongoidPicture.create!(:guid => @guid, :assetable_type => 'MongoidArticle')
  end

  it 'should find asset by guid' do
    asset = MongoidArticle.fileupload_find("mongoid_picture", @picture.guid)
    asset.should == @picture
  end

  it "should update asset target_id by guid" do
    MongoidArticle.fileupload_update('507f1f77bcf86cd799439011', @picture.guid, :mongoid_picture)
    @picture.reload
    @picture.assetable_id.to_s.should == '507f1f77bcf86cd799439011'
    @picture.guid.should be_nil
  end

  after do
    MongoidPicture.destroy_all
  end
end
