#--
# Copyright (c) 2009 Christoph Petschnig
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module ConstantRecord
  # ConstantRecord::Base is a tiny ActiveRecord substitute for small, never
  # changing database tables.
  #
  # == Usage:
  # 
  #   class Currency < ConstantRecord::Base
  #     data 'EUR', 'USD', 'CAD', 'GBP', 'CHF'
  #   end
  #
  # or
  #
  #   class MoreDetailedCurrency < ConstantRecord::Base
  #     columns :short, :description
  #     data ['EUR', 'Euro'],
  #          ['USD', 'US Dollar'],
  #          ['CAD', 'Canadian Dollar'],
  #          ['GBP', 'British Pound sterling'],
  #          ['CHF', 'Swiss franc']
  #   end
  #
  # To show all records in a HTML select field, use:
  #
  #   <%= f.select :currency_id, Currency.options_for_select %>
  #
  class Base

  private
    attr_writer :id, :name

  public
    attr_reader :id, :name

    # Set the column names of the constant table.
    # Default is one column called `name`
    def self.columns(*args)
      # remove the default column name
      undef_method :name

      i = 0
      col_ar = args.collect do |column|
        raise TypeError.new("You can only pass Symbol or String object to #{self}::columns.") unless column.kind_of?(Symbol) || column.kind_of?(String)

        class_eval do
          private
              attr_writer column
          public
              attr_reader column
        end

        i += 1
        [column.to_sym, i - 1]
      end.flatten

      @columns = Hash[*col_ar]
    end

    # Set the data. Arguments must be an Array.
    def self.data(*args)
      @data = args.collect{|arg| arg.kind_of?(Array) ? arg : [arg]}
    end

    # Constructor; call with
    #   MyConstantRecord.new(1, 'value_of_name')
    # or
    #   MyConstantRecord.new(1, 'values of column 1', 2, 3.333)
    def initialize(id, *values)
      @id = id

      return if values.empty?

      #  set the instance variables
      get_columns.each do |key, value|
        instance_variable_set("@#{key}", values[value])
      end
    end

    # Implement +find+. Warning: conditions are only supported with+:first+!
    def self.find(*args)
      selector = args[0]

      #  find might get called on constant_record_id.nil? == true
      return nil if selector.nil?

      raise TypeError.new("#{self}.find failed!\nArguments:#{args.inspect}") unless selector.kind_of?(Symbol) || selector.kind_of?(Fixnum)

      if selector == :first
        conditions = args[1][:conditions]

        raise TypeError.new("#{self}.find failed!\nArguments:#{args.inspect}") unless conditions.kind_of?(Hash) && conditions.size == 1

        compare_col_nr = get_columns[conditions.keys[0]]
        raise "Unknown column :#{conditions.keys[0]}" unless compare_col_nr

        @data.each_with_index do |datum, i|
          return self.new(i, *datum) if datum[compare_col_nr] == conditions.values[0]
        end

        return nil
      end

      #  ignore conditions on :all
      return find_all if selector == :all

      #  ignore conditions if id is given as the first argument
      return find_by_id(selector) if selector.kind_of?(Fixnum)

      raise "#{self}.find failed!\nArguments:#{args.inspect}"
    end

    # Implement +count+. Warning: conditions are not supported!
    def self.count(*args)
      selector = args[0] || :all
      raise TypeError.new("#{self}.find failed!\nArguments:#{args.inspect}") unless selector.kind_of?(Symbol)

      #  ignore conditions on :all
      return @data.size if selector == :all

      raise "#{self}.find failed!\nArguments:#{args.inspect}"
    end

    # A ConstantRecord will never be a new record
    def new_record?
      false
    end

    # A ConstantRecord should never be empty
    def empty?
      false
    end

    # Keep this to spot problems in integration with ActiveRecord
    def method_missing(symbol, *args)  #:nodoc:
      p "ConstantRecord::Base#method_missing(#{symbol})"
      super symbol, *args
    end

    # Keep this to spot problems in integration with ActiveRecord
    def respond_to?(symbol)  #:nodoc:
      result = super(symbol)
      p "ConstantRecord::Base#respond_to?(#{symbol}) => #{result}(#{self.class})" unless result
      result
    end

    # Handle +find_by_xxx+ calls on the class
    def self.method_missing(symbol, *args)  #:nodoc:
      if /^find_by_([_a-zA-Z]\w*)$/ =~ (symbol.to_s)
        return find(:first, :conditions => {$1.to_sym => args[0]})
      end
      p "ConstantRecord::Base::method_missing(#{symbol})"
      super symbol, *args
    end

    # Keep this to spot problems in integration with ActiveRecord
    def self.respond_to?(symbol)  #:nodoc:
      result = super symbol
      p "ConstantRecord::Base::respond_to?(#{symbol}) => #{result}(#{self.class})" unless result
      result
    end

    # Creates options for a select box in a form
    # options:
    # <tt>:display</tt> The attribute to call to display the text in the select box or
    # a Proc object:
    #   :display => Proc.new{ |obj| "#{obj.name} (#{obj.description})" }
    # <tt>:value</tt> The value to use for the option value. Default is the id of the record.
    # <tt>:include_null</tt> Make an entry with the value 0 in the selectbox. Default is +false+.
    # <tt>:null_text</tt> The text to show with on value 0. Default is '-'.
    # <tt>:null_value</tt> The value of the null option. Default is 0.
    def self.options_for_select(options = {})
      display = options[:display] || get_columns.keys[0]
      raise "#{self}.options_for_select: :display must be either Symbol or Proc." unless display.kind_of?(Symbol) ||display.kind_of?(Proc)

      if display.kind_of?(Symbol)
        display_col_nr = get_columns[display]
        raise "Unknown column :#{conditions.keys[0]}" unless display_col_nr
      end

      value = options[:value] || :id

      i = 0
      result = @data.collect do |datum|
        i += 1
        obj = self.new(i, *datum)
        option_show = display.kind_of?(Symbol) ? datum[display_col_nr] : display.call(obj)
        option_value = value == :id ? i : obj.send(value)

        [option_show, option_value]
      end

      if options[:include_null] == true
        result.unshift [ options[:null_text] || '-', options[:null_value] || 0 ]
      end

      result
    end

    private

    # Get the name of the columns or the default value
    def self.get_columns
      #  if columns were not set, the default value is one column
      #  with the name of "name"
      @columns || { :name => 0 }
    end

    def get_columns  #:nodoc:
      self.class.get_columns
    end

    # Implementation of +find+(:all)
    def self.find_all  #:nodoc:
      i = 0
      @data.collect do |datum|
        i += 1
        self.new(i, *datum)
      end
    end

    # Implementation of +find+(:id)
    def self.find_by_id(id)  #:nodoc:
      # check for valid range of selector
      return nil if id <= 0 || id > @data.size

      self.new(id, *@data[id - 1])
    end

  end
end