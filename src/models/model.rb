module Model

  def initialize(**params)
    params.each do |key, value|
      self.class.send(:attr_reader, key)
      instance_variable_set("@#{key}", value)
    end
  end

  def to_json(*a)
    {
      self.class.name => 
        instance_variables.inject({}) do |data, iv|
          data.merge(iv.to_s.sub('@', '') => instance_variable_get(iv))
        end
    }.to_json(*a)
  end

end