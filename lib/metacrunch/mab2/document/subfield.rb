module Metacrunch
  module Mab2
    class Document
      class Subfield

        attr_reader :code
        attr_reader :value

        def initialize(code, value)
          @code  = code
          @value = value
        end

      end
    end
  end
end
