class Env
  GET_BOOL = lambda do |k, dv|
    v = ENV[k]
    v ? (v == 'true' || v == 'TRUE' || v == 'True') : dv
  end
  
  GETS = {
    TrueClass  => GET_BOOL,
    FalseClass => GET_BOOL,
  }
  
  def self.fetch(k, dv)
    fn = GETS.fetch(dv.class, lambda { |k, dv| dv })
    fn.call(k, dv)
  end
end
