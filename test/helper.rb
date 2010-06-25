require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'constantrecord'

class Test::Unit::TestCase
end

# simply count, how often each log type gets called
class MyTestLogger
  TYPES = %w{debug info warn error fatal}
  def initialize
    TYPES.each{|type|instance_variable_set "@#{type}_count", 0}
  end
  TYPES.each do |type|
    attr_reader "#{type}_count"
    eval "def #{type}(*args); @#{type}_count += 1; end"
    #eval "def #{type}(*args); puts *args; @#{type}_count += 1; end"    # print out log messages for better debugging!
  end
end


ConstantRecord::Base.logger = MyTestLogger.new

