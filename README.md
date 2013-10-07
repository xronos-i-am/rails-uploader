## this fork adds mongoid and rails_admin support

This fork works when both simple form and formtastic are loaded

Also nested associations are working

## HTML5 File uploader for rails

This gem use https://github.com/blueimp/jQuery-File-Upload for upload files.

Preview:

![Uploader in use](http://img39.imageshack.us/img39/2206/railsuploader.png)


## Install

In Gemfile:
``` ruby
gem "glebtv-rails-uploader"
```

In routes:

``` ruby
mount Uploader::Engine => '/uploader'
```

## HowTo for mongoid / carrierwave:

### Asset Parent Model (common)
``` ruby
    # models/asset.rb
    class Asset
      include Mongoid::Document
      include Uploader::Asset

      field :guid, type: String
      belongs_to :assetable, polymorphic: true

      # this workaround is sometimes needed so IDs are ObjectIDs not strings  
      before_save do
        if !assetable_id.blank? && assetable_id.class.name != "Moped::BSON::ObjectId" && Moped::BSON::ObjectId.legal?(assetable_id)
          self.assetable_id = Moped::BSON::ObjectId.from_string(assetable_id)
        end
        true
      end
    end
  ```

### Your asset model
``` ruby
    # models/cover.rb
    class Cover < Asset
      # DO NOT add this!
      # belongs_to :post

      # optional built-in sorting for rails_admin
      field :sort, type: Integer

      # field name must be 'data'
      mount_uploader :data, CoverUploader

      validates :data,
          :presence => true,
          :file_size => {
              :maximum => 5.megabytes.to_i
          }

      def to_jq_upload
        {
            'id'  => id.to_s,
            "filename" => File.basename(data.path),
            "url" => data.url,
            'thumb_url' => data.thumb.url,
        }
      end
    end
```

### Model to which you want to add assets
```ruby
    # models/post.rb
    class Post
      include Mongoid::Document

      field :fileupload_guid, type: String

      include Uploader::Fileuploads
      has_one :cover, as: :assetable
      fileuploads :cover
    end
```

### has_many

```ruby
class Album
  has_many :pictures, as: :assetable, dependent: :destroy
  fileuploads :pictures

  accepts_nested_attributes_for :pictures

  rails_admin do
    edit do
      ...
      field :fileupload_guid, :hidden # this is needed or else rails_admin sanitizes it away
      field :pictures, :rails_uploader
    end
  end
end

```

### CarrierWave uploader - all like usual
```ruby
    # uploades/cover_uploader.rb
    class CoverUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick

      storage :file

      def store_dir
        "uploads/covers/#{model.id}"
      end

      version :thumb do
        process resize_to_limit: [50, 50]
      end
    end
```

# Active Admin and RailsAdmin are both working

# RailsAdmin Integration
``` ruby
    rails_admin do
        edit do
          ...
          field :fileupload_guid, :hidden # this is needed or else rails_admin sanitizes it away
          field :pictures, :rails_uploader
        end
    end
```

## Usage (Original description)

Architecture to store uploaded files (cancan integration):

``` ruby
class Asset < ActiveRecord::Base
  include Uploader::Asset

  def uploader_create(params, request = nil)
    ability = Ability.new(request.env['warden'].user)

    if ability.can? :create, self
      self.user = request.env['warden'].user
      super
    else
      errors.add(:id, :access_denied)
    end
  end

  def uploader_destroy(params, request = nil)
    ability = Ability.new(request.env['warden'].user)

    if ability.can? :delete, self
      super
    else
      errors.add(:id, :access_denied)
    end
  end
end

class Picture < Asset
  mount_uploader :data, PictureUploader

  validates_integrity_of :data
  validates_filesize_of :data, :maximum => 2.megabytes.to_i
end
```

For example user has one picture:

``` ruby
class User < ActiveRecord::Base
  has_one :picture, :as => :assetable, :dependent => :destroy

  fileuploads :picture

  # If your don't use strong_parameters, uncomment next line
  # attr_accessible :fileupload_guid
end
```

Find asset by foreign key or guid:

``` ruby
@user.fileupload_asset(:picture)
```

### Include assets

Javascripts:

``` ruby
//= require uploader/application
```

Stylesheets:

``` ruby
*= require uploader/application
```

### Views

``` ruby
<%= uploader_field_tag :article, :photo %>
```

or FormBuilder:

``` ruby
<%= form.uploader_field :photo %>
```

### Formtastic

``` ruby
<%= f.input :picture, :as => :uploader %>
```

### SimpleForm

``` ruby
<%= f.input :picture, :as => :uploader %>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright (c) 2013 Fodojo, released under the MIT license
