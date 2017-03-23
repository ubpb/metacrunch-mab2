require_relative "document/controlfield"
require_relative "document/datafield"
require_relative "document/datafield_set"
require_relative "document/subfield"
require_relative "document/subfield_set"

module Metacrunch
  module Marcxml
    class Document
      def initialize
        @controlfields_map = {}
        @datafields_map = {}
      end

      # ------------------------------------------------------------------------------
      # Control fields
      # ------------------------------------------------------------------------------

      #
      # Returns the control field matching the given tag or nil if a control field
      # with the tag does not exists.
      #
      # @param [String] tag of the control field
      # @return [Controlfield, nil] control field with the given tag or nil if the
      #   tag does not exists.
      #
      def controlfield(tag)
        @controlfields_map[tag.to_s]
      end

      #
      # Adds a new control field to the document.
      #
      # @param [Metacrunch::Marcxml::Document::Controlfield] controlfield
      #
      def add_controlfield(controlfield)
        @controlfields_map[controlfield.tag] = controlfield
      end

      # ------------------------------------------------------------------------------
      # Data fields
      # ------------------------------------------------------------------------------

      #
      # Returns the data fields matching the given tag(s) and/or ind1/ind2.
      #
      # @param [String, nil, Array<String>] tag(s) of the data field. Can be nil to match
      #   all data fields.
      # @param [String, nil, Array<String>] ind1 filter for ind1. Can be nil to match any indicator 1.
      # @param [String, nil, Array<String>] ind2 filter for ind2. Can be nil to match any indicator 2.
      #
      # @return [Metacrunch::Marcxml::Document::DatafieldSet] Set of data fields with the
      #  given tag(s) and ind1/ind2. The set is empty if a matching field doesn't exists.
      #
      def datafields(tag = nil, ind1: nil, ind2: nil)
        matched_datafields = case tag
        when nil
          @datafields_map.values.flatten(1)
        when Enumerable
          tag.map{ |_tag| @datafields_map[normalize_tag(_tag)] }.compact.flatten(1)
        else
          @datafields_map[normalize_tag(tag)]
        end

        matched_datafields = (matched_datafields || []).select do |datafield|
          match_indicator(ind1, datafield.ind1) && match_indicator(ind2, datafield.ind2)
        end

        DatafieldSet.new(matched_datafields)
      end

      #
      # Adds a new data field.
      #
      # @param [Metacrunch::Marcxml::Document::Datafield] datafield
      #
      def add_datafield(datafield)
        (@datafields_map[datafield.tag] ||= []) << datafield
        datafield
      end

    private

      def match_indicator(requested_ind, datafield_ind)
        [*[requested_ind]].flatten.map do |_requested_ind|
          if !_requested_ind
            true
          elsif _requested_ind == :blank && (datafield_ind == " " || datafield_ind == "-" || datafield_ind.nil?)
            true
          elsif _requested_ind == datafield_ind
            true
          else
            false
          end
        end.any?
      end

      def normalize_tag(tag)
        case tag
        when Integer then tag.to_s.rjust(3, "0")
        when String  then tag
        else tag.to_s
        end
      end

    end
  end
end
