module ConstantRecord
  class Base

private
    attr_writer :id
public
    attr_reader :id

    def self.data=(*args)
      write_inheritable_attribute('data', args[0])

      first_attr = args[0][0]

      if first_attr.kind_of?(Hash)
        first_attr.each_key do |key|
          class_eval do #"def #{key}() @#{key} end"
            private
                attr_writer key
            public
                attr_reader key
          end
        end
      elsif first_attr.kind_of?(String)
        class_eval do #"def name() p @name; @name end"
          private
              attr_writer :name
          public
              attr_reader :name
        end
      else
        raise TypeError.new("data must be Array of Strings or Hashes.")
      end
    end

    def initialize(*values)
      values[0].each do |key, value|
        send("#{key}=", value)
      end
    end

    def self.find(*args)
      data = read_inheritable_attribute('data')

      selector = args[0]
      #  find might get called on constant_record_id.nil? == true
      return nil if selector.nil?

      raise TypeError.new("#{self}.find failed!\nArguments: #{args.inspect}") unless selector.kind_of?(Symbol) || selector.kind_of?(Fixnum)

      if selector == :first
        conditions = args[1][:conditions]

        raise TypeError.new("#{self}.find failed!\nArguments: #{args.inspect}") unless conditions.kind_of?(Hash)

        data.each_with_index do |o, i|
          if o.kind_of? Hash
            success = true
            conditions.each do |key, value|
              success &= o[key].to_s == value.to_s      #  using .to_s is a cheap trick
            end
            return self.new(o.merge( :id => i + 1 )) if success
          else
            raise TypeError.new("#{self}.find failed!\nArguments: #{args.inspect}") unless conditions.size == 1 && conditions.key?(:name)
            return self.new(:name => o, :id => i + 1) if conditions[:name].to_s == o.to_s     #  using .to_s is a cheap trick
          end
        end

        return nil
      end

      #  ignore conditions on :all
      if selector == :all
        i = 0
        return data.collect do |o|
          i += 1
          if o.kind_of? Hash
            self.new(o.merge( :id => i ))
          else
            #  it should be a string now
            self.new(:name => o, :id => i)
          end
        end
      end

      #  ignore conditions if id is given as the first argument
      if selector.kind_of?(Fixnum)
#pp data[selector - 1]
        return nil if selector == 0
        if data[selector - 1].kind_of? Hash
          return self.new(data[selector - 1].merge(:id => selector))
        end

        return self.new(:name => data[selector - 1], :id => selector)
      end

      raise Exception.new("#{self}.find failed!\nArguments: #{args.inspect}")
    end

    def self.count(*args)
      data = read_inheritable_attribute('data')

      selector = args[0]
      return nil if selector.nil?

      raise TypeError.new("#{self}.find failed!\nArguments: #{args.inspect}") unless selector.kind_of?(Symbol)

      #  ignore conditions on :all
      return data.size if selector == :all

      raise Exception.new("#{self}.find failed!\nArguments: #{args.inspect}")
    end

    def new_record?
      false
    end

    def empty?
      false
    end

    def method_missing(symbol, *args)
p "ConstantRecord::Base#method_missing(#{symbol})"
      super symbol, *args
    end

    def respond_to?(symbol)
#p "ConstantRecord::Base#respond_to?(#{symbol})"
      result = super symbol
p "ConstantRecord::Base#respond_to?(#{symbol}) => #{result} (#{self.class})" unless result
result
    end

    def self.method_missing(symbol, *args)
      if /^find_by_([_a-zA-Z]\w*)$/ =~ (symbol.to_s)
        return find(:first, :conditions => {$1.to_sym => args[0]})
      end
p "ConstantRecord::Base#method_missing(#{symbol})"

      super symbol, *args
    end

    def self.respond_to?(symbol)
      result = super symbol
p "ConstantRecord::Base#respond_to?(#{symbol}) => #{result} (#{self.class})" unless result || symbol == :inherited_without_inheritable_attributes
result
    end

    def self.options_for_select(options = {})
      data = read_inheritable_attribute('data')
      display = options[:display] || :name

      i = 0
      data.collect do |o|
        i += 1
        if o.kind_of? Hash
          [o[display], i]
        else
          [o, i]
        end
      end

    end

  end
end
