module Metacrunch
  module Mab2
    class Document
      require_relative "document/mab_xml_parser"
      require_relative "document/controlfield"
      require_relative "document/datafield"
      require_relative "document/datafield_set"
      require_relative "document/subfield"
      require_relative "document/subfield_set"

      #
      # @param [String] xml repesenting a MAB document in Aleph MAB XML format
      # @return [Metacrunch::Mab2::Document]
      #
      def self.from_mab_xml(xml)
        MabXmlParser.new.parse(xml)
      end

      def initialize
        @controlfields_map = {}
        @datafields_map = {}
      end

      # ------------------------------------------------------------------------------
      # Control fields
      # ------------------------------------------------------------------------------

      #
      # Returns the control field matching the given tag.
      #
      # @param [String] tag of the control field
      # @return [Controlfield] control field with the given tag.
      #
      def controlfield(tag)
        @controlfields_map[tag] || Controlfield.new(tag)
      end

      #
      # Adds a new control field.
      #
      # @param [Metacrunch::Mab2::Document::Controlfield] controlfield
      #
      def add_controlfield(controlfield)
        @controlfields_map[controlfield.tag] = controlfield
      end

      # ------------------------------------------------------------------------------
      # Data fields
      # ------------------------------------------------------------------------------

      #
      # Returns the data fields matching the given tag and/or ind1/ind2.
      #
      # @param [String] tag of the data field.
      # @param [String, nil] ind1 filter for ind1. Can be nil to match any indicator 1.
      # @param [String, nil] ind2 filter for ind2. Can be nil to match any indicator 2.
      #
      # @return [Metacrunch::Mab2::Document::DatafieldSet] Set of data fields with the
      #  given tag and ind1/ind2. The set is empty if a matching field doesn't exists.
      #
      def datafields(tag, ind1: nil, ind2: nil)
        matched_datafields = (@datafields_map[tag] || []).select do |datafield|
          match_indicator(ind1, datafield.ind1) && match_indicator(ind2, datafield.ind2)
        end

        DatafieldSet.new(matched_datafields)
      end

      #
      # Adds a new data field.
      #
      # @param [Metacrunch::Mab2::Document::Datafield] datafield
      #
      def add_datafield(datafield)
        (@datafields_map[datafield.tag] ||= []) << datafield
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

    end
  end
end
