# frozen_string_literal: true

require_relative "../../domain/pto"
require_relative "../base"

module Mapper
  module Notion
    ##
    # This class implementats the methods of the Mapper::Base module, specifically designed for preparing or
    # shaping PTO's data coming from a Fetcher::Base implementation.
    #
    class Pto
      include Base

      # Implements the logic for shaping the results from a fetcher response.
      #
      # <br>
      # <b>Params:</b>
      # * <tt>Fetcher::Notion::Types::Response</tt> notion_response: Notion response object.
      #
      # <br>
      # <b>returns</b> <tt>List<Domain::Pto></tt> ptos_list, mapped PTO's to be used by a Formatter::Base
      # implementation.
      #
      def map(notion_response)
        return [] if notion_response.results.empty?

        normalized_notion_data = normalize_response(notion_response.results)
        normalized_notion_data.map do |pto|
          Domain::Pto.new(pto["name"], format_date(pto["start"]), format_date(pto["end"]))
        end
      end

      private

      def normalize_response(response)
        return [] if response.nil?

        normalized_response = []

        response.map do |value|
          properties = value["properties"]
          properties.delete("Name")

          normalized_value = normalize(properties)

          normalized_response.append(normalized_value)
        end

        normalized_response
      end

      def normalize(properties)
        normalized_value = {}

        properties.each do |k, v|
          extract_pto_fields(k, v, normalized_value)
        end

        normalized_value
      end

      def extract_pto_fields(key, value, normalized_value)
        case key
        when "Person"
          user_name = extract_person_field_value(value)
          normalized_value["name"] = user_name
        when "Desde?"
          normalized_value["start"] = extract_date_field_value(value)
        when "Hasta?"
          normalized_value["end"] = extract_date_field_value(value)
        end
      end

      def extract_person_field_value(data)
        data["people"][0]["name"]
      end

      def extract_date_field_value(data)
        data["date"]["start"]
      end

      def format_date(str_date)
        return "" if str_date.nil?

        if str_date.include?("T")
          format = "%Y-%m-%d|%I:%M %p"
          datetime = Time.new(str_date)
          datetime.strftime(format)
        else
          str_date
        end
      end
    end
  end
end
