# encoding: utf-8
module Uploader
  class AttachmentsController < ActionController::Metal
    include AbstractController::Callbacks
  
    before_filter :find_klass
    
    def create
      @asset = @klass.new(params[:asset])
      @asset.uploader_create(params, request)
      render_resourse(@asset, 201)
    end
    
    def destroy
      @asset = @klass.find(params[:id])
      @asset.uploader_destroy(params, request)
      render_resourse(@asset, 200)
    end

    def sort
      @model = params[:assetable_type].safe_constantize

      sort = params[:sort].split('|')
      if params[:assetable_id].blank?
        @finder = @klass.where(guid: params[:guid])
      else
        @finder = @klass.where(assetable_id: params[:assetable_id])
      end

      @finder.each do |asset|
        if asset.respond_to?(:sort=)
          asset.sort = sort.index(asset.id.to_s)
          asset.save!
        end
      end

      self.status = 200
      self.content_type = "application/json"
      self.response_body = '{"ok": true}'
    end
    
    protected


      def airbrake_request_data
        {
            :controller       => params[:controller],
            :action           => params[:action],
        }
      end

      def find_klass
        @klass = params[:klass].blank? ? nil : params[:klass].safe_constantize
        raise ActionController::RoutingError.new("Class not found #{params[:klass]}") if @klass.nil?
      end
      
      def render_resourse(record, status = 200)
        if record.errors.empty?
          if record.respond_to?(:to_jq_upload)
            render_json(record.to_jq_upload.to_json(:root => false), status)
          else
            render_json([record].to_json(:root => false), status)
          end

        else
          render_json([record.errors].to_json, 422)
        end
      end
      
      def render_json(body, status = 200)
        self.status = status
        self.content_type = "application/json"
        self.response_body = body
      end
  end
end
