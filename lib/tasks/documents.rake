namespace :documents do
  desc 'add a document from a file'
  task :add, [:path] => :environment do |t, args|
    src = IO.read(args.path)
    dm = Document.create(src: src)
    puts "+ created (public_id=#{dm.public_id}; id=#{dm._id.to_s}; path=#{args.path}"
  end
end
