class UploadsController < ApplicationController
    require 'faraday'
    require 'zip'
  
    def new
      @upload = Upload.new
    end
  
    def create
      @upload = current_user.uploads.new(upload_params)
      if @upload.save
        params[:upload][:images].each do |image|
          @upload.images.attach(image)
        end
        zip_file_path = create_zip_file(@upload.images)
  
        # Create Faraday connection
        conn = Faraday.new(:url => 'https://app.88stacks.com')
  
        # Send the zip file to the 88stacks API
        response = conn.post do |req|
          req.url '/models'
          req.headers['Content-Type'] = 'application/zip'
          req.headers['Authorization'] = "J8xSJVC6a5fbzYY1wLbZQ6sU"
          req.body = File.read(zip_file_path)
        end
  
        if response.status == 201
          flash[:success] = "Model created successfully"
          redirect_to upload_path(@upload)
        else
          flash[:error] = "Error creating model: #{response.body}"
          render :new
        end
      else
        render :new
      end
    ensure
      File.delete(zip_file_path) if zip_file_path
    end
  
    def show
      @upload = Upload.find(params[:id])
      if @upload.images.attached?
        # images are processed and ready to be displayed
      else
        @upload.images.purge
        # images are not processed or have been purged
      end
    end
  
    def create_zip_file(images)
      zip_file_path = "#{Rails.root}/tmp/upload_#{Time.now.to_i}.zip"
      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
        images.each do |image|
          zipfile.add(image.filename, image.path)
        end
      end
      zip_file_path
    end
    private

    def upload_params
        params.require(:upload).permit(images: [:file, :filename, :content_type, :headers])
    end
  end
  


# def process_uploaded_images images
#     #TODO write job that deletes orphaned uploads
#       puts images.inspect
#       puts images.size
#       puts "GOT IMAGES"
#       files = images.collect{|x| x.path }
#       puts files
#       puts "OPOPO"

#       zip_temp_file = Tempfile.new("#{Time.now.to_f}.zip")
#       puts zip_temp_file.path
#       puts "YYYYYOPPO"
#       Zip::File.open(zip_temp_file.path, create:true) do |zipfile|
#         files.each do |filename|
#           zipfile.add(File.basename(filename), filename)
#         end
#       end
#       puts zip_temp_file.path
#       puts "OPPO"

#       client = Aws::S3::Client.new(
#         access_key_id: Rails.application.credentials.aws.access_key_id,
#         secret_access_key: Rails.application.credentials.aws.secret_access_key,
#         #endpoint: 'https://sfo3.digitaloceanspaces.com/', 
#         #force_path_style: false,
#         region: "us-east-1" # Must be "us-east-1" when creating new Spaces. Otherwise, use the region in your endpoint, such as "nyc3".
#       )
#       env_prefix = Rails.env.production? ? 'p' : 'd'
#       name = Time.now.to_f.to_s+(0...8).map { (65 + rand(26)).chr }.join
#       object_key= "#{env_prefix}/training/#{name}.zip"
#       training_link = "https://r2d2.sfo3.digitaloceanspaces.com/#%7Bobject_key%7D"
#       training_link = "https://90213.s3.amazonaws.com/#%7Bobject_key%7D"
#       o = client.put_object({
#         bucket: "90213", #TODO move this to env var
#         key: object_key,
#         body: File.new(zip_temp_file),
#         #acl: "public-read",
#         content_type: "application/zip"
#       })
#       zip_temp_file.unlink
#       training_link
#   end