require File.expand_path(File.dirname(__FILE__) + '/test_helper')

module Foo
  class Bar
  end

  class Awesomeness
  end
end

class Bar
end

class SupportTest < ActiveSupport::TestCase
  test 'constant_defined? with non-namespaced constant' do
    assert  Liquidizer::Support.constant_defined?('Bar')
    assert !Liquidizer::Support.constant_defined?('Baz')
  end
  
  test 'constant_defined? with namespaced constant' do
    assert  Liquidizer::Support.constant_defined?('Foo::Bar')
    assert !Liquidizer::Support.constant_defined?('Foo::Baz')
  end
end
