module Liquidizer
  module Support
    # This is like Object.const_defined?, but works with namespaced constants (Foo::Bar::Baz).
    def self.constant_defined?(name)
      name.constantize && true
    rescue NameError
      false
    end
  end
end
