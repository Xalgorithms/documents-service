require 'tempfile'

module Services
  class LocalTempStorage
    def store(id, f)
      tf = Tempfile.create("xa_#{id}")
      puts "# storing in #{tf.path}"
      tf.write(f.read)
    end
  end
end
