require 'google/cloud/storage'
require 'multi_json'
require 'tempfile'
require 'uuid'

# By default, this service will simply store the incoming UBL in a
# tempfile and send back the path of that file. In order to test
# against GCLOUD STORAGE, you will need to run the service as:
#
# $ GOOGLE_APPLICATION_CREDENTIALS=<path to creds json> GCLOUD_PROJECT_ID=<project_id> GCLOUD_USE_STORAGE=true bundle exec rackup
module Services
  class Documents
    def self.create(f)
      use_gcs = ENV.fetch('GCLOUD_USE_STORAGE', '') == 'true'
      use_gcs ? store_in_gcs(f) : store_locally(f)
    end

    private

    def self.store_in_gcs(f)
      project_id = ENV.fetch('GCLOUD_PROJECT_ID', nil)
      id = UUID.generate
      if project_id
        bkt_name = ENV.fetch('GCLOUD_STORAGE_BUCKET', 'lichen-documents')
        st = Google::Cloud::Storage.new(project_id: project_id)
        bkt = st.bucket(bkt_name)
        bkt.create_file(f, "#{id}.ubl")
      else
        # TODO
      end

      id
    end

    def self.store_locally(f)
      tf = Tempfile.create('xadf')
      tf.write(f.read)
      tf.path
    end
  end
end
