require 'google/cloud/storage'

# In order to test against GCLOUD STORAGE, you will need to run the
# service as:
#
# $ GCLOUD_PROJECT_ID=<project_id> DOCUMENT_STORAGE_LOCATION='google-storage' bundle exec rackup

module Services
  class GoogleStorage
    def initialize
      @project_id = ENV.fetch('GCLOUD_PROJECT_ID', nil)
      @bucket_name = ENV.fetch('GCLOUD_STORAGE_BUCKET', 'lichen-documents')
    end

    def store(id, f)
      if bucket
        n = "#{id}.ubl"
        puts "> storing file (name=#{n})"
        bucket.create_file(f, n)
      else
        puts '! no bucket configured, not storing'
      end
    end

    def get(id)
      if bucket
        bucket.file("#{id}.ubl").download
      end
    end
    
    private
    
    def bucket
      @bucket ||= maybe_connect_bucket
    end

    def maybe_connect_bucket
      if @project_id
        puts "# connecting to bucket (project_id=#{@project_id}; bucket_name=#{@bucket_name})"
        st = Google::Cloud::Storage.new(project_id: @project_id)
        st.bucket(@bucket_name)        
      else
        puts '! no project id was specified, set env var GCLOUD_PROJECT_ID'
        nil
      end
    end
  end
end
