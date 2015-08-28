module Metacrunch
  module Mab2
    class Document
      require_relative "./document/aleph_mab_xml_parser"
      require_relative "./document/controlfield"
      require_relative "./document/datafield"
      require_relative "./document/datafield_set"
      require_relative "./document/subfield"
      require_relative "./document/subfield_set"

      # ------------------------------------------------------------------------------
      # Parsing
      # ------------------------------------------------------------------------------

      #
      # @param [String] xml repesenting a MAB document in Aleph MAB XML format
      # @return [Metacrunch::Mab2::Document]
      #
      def self.from_aleph_mab_xml(xml)
        AlephMabXmlParser.parse(xml)
      end

      # ------------------------------------------------------------------------------
      # Control fields
      # ------------------------------------------------------------------------------

      #
      # @return [Hash{String => Metacrunch::Mab2::Document::Controlfield}]
      # @private
      #
      def controlfields_struct
        @controlfields_struct ||= {}
      end
      private :controlfields_struct

      #
      # Returns the control field matching the given tag.
      #
      # @param [String] tag of the control field
      # @return [Controlfield] control field with the given tag.
      #
      def controlfield(tag)
        controlfields_struct[tag] || Controlfield.new(tag)
      end

      #
      # Adds a new control field.
      #
      # @param [Metacrunch::Mab2::Document::Controlfield] controlfield
      #
      def add_controlfield(controlfield)
        controlfields_struct[controlfield.tag] = controlfield
      end

      # ------------------------------------------------------------------------------
      # Data fields
      # ------------------------------------------------------------------------------

      #
      # @return [Hash{String => Metacrunch::Mab2::Document::DatafieldSet}]
      # @private
      #
      def datafields_struct
        @datafields_struct ||= {}
      end
      private :datafields_struct

      #
      # Returns the data fields matching the given tag and ind1/ind2.
      #
      # @param [String] tag of the data field
      # @param [String, nil] ind1 filter for ind1. Can be nil to match any.
      # @param [String, nil] ind2 filter for ind2. Can be nil to match any.
      # @return [Metacrunch::Mab2::Document::DatafieldSet] data field with the given tag and ind1/ind2.
      #  The set is empty if a matching field with the tag and/or ind1/ind2 doesn't exists.
      #
      def datafields(tag = nil, ind1: nil, ind2: nil)
        if tag.nil?
          datafields_struct.values.inject(DatafieldSet.new) do |_memo, _datafield_set|
            _memo.concat(_datafield_set)
          end
        else
          set = datafields_struct[tag] || DatafieldSet.new
          return set if set.empty? || (ind1.nil? && ind2.nil?)

          ind1 = ind1.is_a?(Array) ? ind1.map { |_el| _el == :blank ? [" ", "-"] : _el }.flatten(1) : ind1
          ind2 = ind2.is_a?(Array) ? ind2.map { |_el| _el == :blank ? [" ", "-"] : _el }.flatten(1) : ind2

          # not dry but combining these two does make the code harder to read
          set.select do |_datafield|
            ind1_check =
            if !ind1
              true
            elsif ind1 == :blank && (_datafield.ind1 == " " || _datafield.ind1 == "-")
              true
            elsif _datafield.ind1 == ind1
              true
            elsif ind1.is_a?(Array) && ind1.include?(_datafield.ind1)
              true
            else
              false
            end

            ind2_check =
            if !ind2
              true
            elsif ind2 == :blank && (_datafield.ind2 == " " || _datafield.ind2 == "-")
              true
            elsif _datafield.ind2 == ind2
              true
            elsif ind2.is_a?(Array) && ind2.include?(_datafield.ind2)
              true
            else
              false
            end

            ind1_check && ind2_check
          end
          .try do |_array|
            DatafieldSet.new(_array)
          end
        end
      end

      #
      # Adds a new data field.
      #
      # @param [Metacrunch::Mab2::Document::Datafield] datafield
      #
      def add_datafield(datafield)
        datafield_set  = datafields(datafield.tag)
        datafield_set << datafield

        datafields_struct[datafield.tag] = datafield_set
      end

      # ------------------------------------------------------------------------------
      # Serialization
      # ------------------------------------------------------------------------------

      def to_xml
        builder = ::Builder::XmlMarkup.new(indent: 2)
        builder.instruct!(:xml, :encoding => "UTF-8")
        builder.mab_xml do
          controlfields_struct.values.each do |_controlfield|
            _controlfield.to_xml(builder)
          end

          datafields_struct.values.each do |_datafield_set|
            _datafield_set.to_xml(builder)
          end
        end
      end

    end
  end
end
