class Article
  include Mongoid::Document
  include Uploader::Fileuploads

  field :content
  field :title
  
  has_one :picture, as: :assetable, dependent: :destroy

  fileuploads :picture
end
