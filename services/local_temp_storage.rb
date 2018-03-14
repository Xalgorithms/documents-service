require 'tempfile'

module Services
  class LocalTempStorage
    def store(id, f)
      fn = File.join(Dir.tmpdir, "#{id}.ubl")
      puts "# storing (fn=#{fn})"
      File.write(fn, f.read)
    end

    def get(id)
      fn = Dir.glob("#{Dir.tmpdir}/*.ubl").find do |fn|
        m = /^(.+).ubl$/.match(File.basename(fn))
        m && m[1] == id
      end
      fn ? File.read(fn) : nil
    end
  end
end
