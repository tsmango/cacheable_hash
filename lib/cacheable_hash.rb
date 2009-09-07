class CacheableHash
  attr_accessor :cache_key, :expires_in, :hash
  
  def initialize(cache_key, *args)
    options = args.extract_options!
    
    self.cache_key = cache_key
    self.expires_in = (options[:expires_in] || 6.hours)
    
    self.hash = Hash.new
    if !options[:hash].blank?
      options[:hash].each_pair do |key, value|
        self.hash[key.to_sym] = value
      end
    end
  end
  
  def method_missing(sym, *args, &block)
    return_value = hash.send(sym, *args, &block)
    Rails.cache.write(self.cache_key, self, :expires_in => self.expires_in) unless sym.to_s == '[]'
    
    return return_value
  end
end