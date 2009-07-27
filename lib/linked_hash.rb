class LinkedHash < Hash
  alias_method :assign_without_link, :'[]='
  def initialize
    @linked_keys=Array.new
  end
  
  
  def assign_with_link(key,value)
    @linked_keys << key unless self.has_key?(key)
    assign_without_link(key,value)
  end
  alias_method :'[]=', :assign_with_link
  
  def linked_keys
    @linked_keys & self.keys
  end
  
  def each_linked_pair(&block)
    linked_keys.each do |key|
      yield(key,self[key])
    end
  end
end