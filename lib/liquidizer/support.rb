module Liquidizer
  module Support
    # This is like Object.const_defined?, but works with namespaced constants (Foo::Bar::Baz).
    def self.constant_defined?(name)
      base = Object
      name.split('::').each do |name|
        if base.const_defined?(name)
          base = base.const_get(name)
        else
          return false
        end
      end

      true
    end
  end
end
