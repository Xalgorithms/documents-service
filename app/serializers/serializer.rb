class Serializer
  def self.many(ms, context=nil)
    ms.map { |m| self.one(m, context) }
  end
end
