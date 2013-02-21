# this fork adds mongoid support, and works when both simple form and formtastic are loaded

Also nested associations seem to be working

a little howto for mongoid / carrierwave:

    # models/asset.rb
    class Asset
      include Mongoid::Document
      include Uploader::Asset

      field :guid, type: String
      belongs_to :assetable, polymorphic: true
    end

    # models/cover.rb
    class Cover < Asset
      belongs_to :post

      mount_uploader :data, CoverUploader

      validates :data,
          :presence => true,
          :file_size => {
              :maximum => 5.megabytes.to_i
          }

      def to_jq_upload
        [{
            'id'  => id.to_s,
            "filename" => File.basename(data.path),
            "url" => data.url,
            'thumb_url' => data.thumb.url,
        }]
      end
    end

    # models/post.rb
    class Post
      include Mongoid::Document
      include Uploader::Fileuploads
      has_one :image, as: :assetable
      fileuploads :image

      def to_jq_upload
        [{
            'id'  => id.to_s,
            "name" => File.basename(image.path),
            "url" => image.url,
            'thumbnail_url' => image.thumb.url,
        }]
      end
    end

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


# HTML5 File uploader for rails

This gem use https://github.com/blueimp/jQuery-File-Upload for upload files.

Preview:

![Uploader in use](http://img39.imageshack.us/img39/2206/railsuploader.png)

## Install

In Gemfile:

  gem "rails-uploader"

In routes:  

``` ruby
mount Uploader::Engine => '/uploader'
```

## Usage

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
