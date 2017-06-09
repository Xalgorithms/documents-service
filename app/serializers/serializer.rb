class Serializer
  def self.many(ms)
    ms.map(&method(:one))
  end
end
