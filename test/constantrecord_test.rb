require 'constantrecord'
require 'test/unit'

class SimpleClass < ConstantRecord::Base
  data 'Lithuania', 'Latvia', 'Estonia'
end

class SimpleClass2 < ConstantRecord::Base
  columns :album
  data 'Sgt. Pepper', 'Magical Mystery Tour', 'Abbey Road'
end

class MultiColumnClass < ConstantRecord::Base
  columns :short, :description
  data ['EUR', 'Euro'],
       ['USD', 'US Dollar'],
       ['CAD', 'Canadian Dollar'],
       ['GBP', 'British Pound sterling'],
       ['CHF', 'Swiss franc']
end

# A table/class that makes no sense, but has integers and booleans
class MultiColumnClassNotString < ConstantRecord::Base
  columns :prime, :bool
  data [11, false],
       [13, false],
       [17, true],
       [19, false]
end

class TestConstantRecord < Test::Unit::TestCase
  def test_simple_finder
    assert_equal 'Estonia', SimpleClass.find(3).name
    assert_equal 3, SimpleClass.find(3).id
    assert_nil SimpleClass.find(4)
    assert_nil SimpleClass.find(0)
    assert_nil SimpleClass.find(nil)
    assert_equal 'Estonia', SimpleClass.find_by_name('Estonia').name
    assert_equal 3, SimpleClass.find_by_name('Estonia').id
    assert_raise (RuntimeError) { SimpleClass.find_by_foo('bar') }
    assert_equal [ 'Lithuania', 'Latvia', 'Estonia' ], SimpleClass.find(:all).collect{|o| o.name}
    assert_equal [ 1, 2, 3 ], SimpleClass.find(:all).collect{|o| o.id}
    assert_equal 3, SimpleClass.count
    assert_equal 'Lithuania', SimpleClass.find(:first).name
    assert_equal 'Estonia', SimpleClass.find(:last).name
  end

  def test_simple_finder_with_custom_column_name
    assert_equal 'Abbey Road', SimpleClass2.find(3).album
    assert_equal 3, SimpleClass2.find(3).id
    assert_nil SimpleClass2.find(4)
    assert_nil SimpleClass2.find(0)
    assert_nil SimpleClass2.find(nil)
    assert_equal 'Sgt. Pepper', SimpleClass2.find_by_album('Sgt. Pepper').album
    assert_equal 1, SimpleClass2.find_by_album('Sgt. Pepper').id
    assert_raise (RuntimeError) { SimpleClass2.find_by_name('Sgt. Pepper') }
    assert_equal [ 'Sgt. Pepper', 'Magical Mystery Tour', 'Abbey Road' ], SimpleClass2.find(:all).collect{|o| o.album}
    assert_equal [ 1, 2, 3 ], SimpleClass2.find(:all).collect{|o| o.id}
    assert_equal 3, SimpleClass2.count
  end

  def test_multi_column_finder
    all = MultiColumnClass.find(:all)
    chf = all[4]
    assert 5 == chf.id && chf.short && 'Swiss franc' == chf.description

    assert_equal 'Canadian Dollar', MultiColumnClass.find_by_short('CAD').description
    assert_equal 3, MultiColumnClass.find_by_short('CAD').id

    assert_nil MultiColumnClass.find(6)
    assert_nil MultiColumnClass.find(0)
    assert_nil MultiColumnClass.find(nil)
    assert_raise (RuntimeError) { MultiColumnClass.find_by_name('EUR') }
    assert_equal [ 'EUR', 'USD', 'CAD', 'GBP', 'CHF' ], MultiColumnClass.find(:all).collect{|o| o.short}
    assert_equal [ 1, 2, 3, 4, 5 ], MultiColumnClass.find(:all).collect{|o| o.id}
    assert_equal 5, MultiColumnClass.count
  end

  def test_multi_column_not_string_finder
    assert_equal 4, MultiColumnClassNotString.find_by_prime(19).id
    assert_equal 4, MultiColumnClassNotString.find_by_prime('19').id
    assert_equal 3, MultiColumnClassNotString.find_by_bool(true).id
  end

  def test_options_for_select
    assert_equal [['Lithuania', 1], ['Latvia', 2], ['Estonia', 3]], SimpleClass.options_for_select
    assert_equal [['n/a', 0], ['Lithuania', 1], ['Latvia', 2], ['Estonia', 3]],
      SimpleClass.options_for_select(:include_null => true, :null_text => 'n/a')
    assert_equal [['-', nil], ['Lithuania', 1], ['Latvia', 2], ['Estonia', 3]],
      SimpleClass.options_for_select(:include_null => true, :null_value => nil)
    assert_equal [['Euro', 1], ['US Dollar', 2], ['Canadian Dollar', 3],
      ['British Pound sterling', 4], ['Swiss franc', 5]],
      MultiColumnClass.options_for_select(:display => :description)
    assert_equal [['-', "nothn'"], ['Euro', 'EUR'], ['US Dollar', 'USD'],
      ['Canadian Dollar', 'CAD'], ['British Pound sterling', 'GBP'], ['Swiss franc', 'CHF']],
      MultiColumnClass.options_for_select(:display => :description, :value => :short,
        :include_null => true, :null_value => "nothn'")
    assert_equal [['*Sgt. Pepper*', 1], ['*Magical Mystery Tour*', 2], ['*Abbey Road*', 3]],
      SimpleClass2.options_for_select(:display => Proc.new{|obj| "*#{obj.album}*"})
  end
end