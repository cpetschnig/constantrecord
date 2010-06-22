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

module ConstantRecord  #:nodoc:
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
    attr_writer :id, :name  #:nodoc:

  public
    attr_reader :id, :name  #:nodoc:

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

    # Constructor. Call with the <tt>id</tt> plus a list of the values.
    #
    #   MyConstantRecord.new(1, 'value of column #1', 2, 3.333)
    #
    def initialize(id, *values)
      @id = id

      return if values.empty?

      #  set the instance variables
      get_columns.each do |key, value|
        instance_variable_set("@#{key}", values[value])
      end
    end

    # Implement +find+. Warning: <tt>:conditions</tt> are only supported with <tt>:first</tt>!
    def self.find(*args)
      selector = args[0]

      #  find might get called on constant_record_id.nil? == true
      return nil if selector.nil?

      raise TypeError.new("#{self}.find failed!\nArguments: #{args.inspect}") unless selector.kind_of?(Symbol) || selector.kind_of?(Fixnum)

      if selector == :first
        #  no conditions given, return the first record
        return self.new(1, *@data[0]) if args.size == 1

        conditions = args[1][:conditions]

        raise TypeError.new("#{self}.find failed!\nArguments: #{args.inspect}") unless conditions.kind_of?(Hash) && conditions.size == 1

        compare_col_nr = get_columns[conditions.keys[0]]
        raise "Unknown column :#{conditions.keys[0]}" unless compare_col_nr

        @data.each_with_index do |datum, i|
          #  some special handling to integers
          cond_compare = if datum[compare_col_nr].kind_of?(Integer)
            conditions.values[0].to_i
          else
            #  leave anything else as it is
            conditions.values[0]
          end
          return self.new(i + 1, *datum) if datum[compare_col_nr] == cond_compare
        end

        return nil
      end

      return self.new(@data.size, *@data[-1]) if selector == :last

      #  ignore conditions on :all
      return find_all if selector == :all

      #  ignore conditions if id is given as the first argument
      return find_by_id(selector) if selector.kind_of?(Fixnum)

      raise "#{self}.find failed!\nArguments: #{args.inspect}"
    end

    # shortcut to #find(:all)
    def self.all
      find_all
    end

    # Implement +count+. Warning: <tt>:conditions</tt> are not supported!
    def self.count(*args)
      selector = args[0] || :all
      raise TypeError.new("#{self}.count failed!\nArguments: #{args.inspect}") unless selector.kind_of?(Symbol)

      #  ignore conditions on :all
      return @data.size if selector == :all

      raise "#{self}.count failed!\nArguments: #{args.inspect}"
    end

    # A ConstantRecord will never be a new record
    def new_record?  #:nodoc:
      false
    end

    # A ConstantRecord should never be empty
    def empty?  #:nodoc:
      false
    end

    # Show output in the form of `SELECT * FROM tablename;`
    def self.table
      #  get columns in the form of {0 => :id, 1 => :name, ...}
      cols = {:id => 0}.merge(Hash[*(get_columns.collect{|col_name, index| [col_name, index + 1]}.flatten)]).invert.sort

      #  calculate the maximum width of each column
      max_size = []
      cols.each do |index, name|
        woci = with_of_column(index)
        max_size << (woci > name.to_s.length ? woci : name.to_s.length)
      end

      output = ''
      #  build table header
      output += '+-' + max_size.collect{|o| '-' * o}.join('-+-') + "-+\n"
      output += '| ' + cols.collect{|o| o[1].to_s.ljust(max_size[o[0]])}.join(' | ') + " |\n"
      output += '+-' + max_size.collect{|o| '-' * o}.join('-+-') + "-+\n"
      #  build table data
      @data.each_with_index do |row, row_number|
        output += '| ' + (row_number + 1).to_s.ljust(max_size[0]) + ' | '
        index = 0
        output += row.collect{|o| index += 1; o.to_s.ljust(max_size[index])}.join(' | ') + " |\n"
      end
      output += '+-' + max_size.collect{|o| '-' * o}.join('-+-') + "-+\n"
    end

    # Keep this to spot problems in integration with ActiveRecord
    def method_missing(symbol, *args)  #:nodoc:
      Rails.logger.debug "#{self.class}#method_missing(:#{symbol})" if defined?(Rails)
      super symbol, *args
    end

    # Keep this to spot problems in integration with ActiveRecord
    def respond_to?(symbol)  #:nodoc:
      result = super(symbol)
      Rails.logger.debug "#{self.class}#respond_to?(:#{symbol}) => #{result}" if !result && defined?(Rails)
      result
    end

    # Handle +find_by_xxx+ calls on the class
    def self.method_missing(symbol, *args)  #:nodoc:
      if /^find_by_([_a-zA-Z]\w*)$/ =~ (symbol.to_s)
        return find(:first, :conditions => {$1.to_sym => args[0]})
      end
      Rails.logger.debug "#{self}::method_missing(:#{symbol})" if defined?(Rails)
      super symbol, *args
    end

    # Keep this to spot problems in integration with ActiveRecord
    def self.respond_to?(symbol)  #:nodoc:
      result = super symbol
      Rails.logger.debug "#{self}::respond_to?(:#{symbol}) => #{result}" if !result && defined?(Rails)
      result
    end

    # Creates options for a select box in a form. The result is basically the same as
    # the following code with ActiveRecord:
    #
    #  MyActiveRecord.find(:all).collect{|obj| [obj.name, obj.id]}
    #
    # === Usage
    #
    # With the class:
    #
    #  class Currency < ConstantRecord::Base
    #    columns :short, :description
    #    data ['EUR', 'Euro'],
    #         ['USD', 'US Dollar']
    #  end
    #
    # The following erb code:
    #
    #  <%= f.select :currency_id, Currency.options_for_select %>
    #
    # Results to:
    #
    #  <select id="invoice_currency_id" name="invoice[currency_id]">
    #    <option value="1">EUR</option>
    #    <option value="2">USD</option>
    #  </select>
    #
    # While:
    #
    #  <%= f.select :currency_id, Currency.options_for_select(
    #    :display => Proc.new { |obj| "#{obj.short} (#{obj.description})" },
    #    :value => :short, :include_null => true,
    #    :null_text => 'Please choose one', :null_value => nil ) %>
    #
    # Results to:
    #
    #  <select id="invoice_currency_id" name="invoice[currency_id]">
    #    <option value="">Please choose one</option>
    #    <option value="EUR">EUR (Euro)</option>
    #    <option value="USD">USD (US Dollar)</option>
    #  </select>
    #
    # === Options
    #
    # [:display]
    #   The attribute to call to display the text in the select box or a Proc object.
    # [:value]
    #   The value to use for the option value. Default is the id of the record.
    # [:include_null]
    #   Make an entry with the value 0 in the selectbox. Default is +false+.
    # [:null_text]
    #   The text to show with on value 0. Default is '-'.
    # [:null_value]
    #   The value of the null option. Default is 0.
    def self.options_for_select(options = {})
      display = options[:display] || get_columns.invert[0]
      raise "#{self}.options_for_select: :display must be either Symbol or Proc." unless display.kind_of?(Symbol) ||display.kind_of?(Proc)

      if display.kind_of?(Symbol)
        display_col_nr = get_columns[display]
        raise "Unknown column :#{display}" unless display_col_nr
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
        result.unshift [ options[:null_text] || '-', options.key?(:null_value) ? options[:null_value] : 0 ]
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

    def self.with_of_column(index)
      return @data.size.to_s.length if index == 0
      result = 0
      @data.each do |row|
        size = row[index - 1].to_s.length
        result = size if size > result
      end
      result
    end

  end
end