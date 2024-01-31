# frozen_string_literal: true

module Fetcher
  module Notion
    module Types
      class NotionResponse
        attr_reader :status_code, :message, :results

        def initialize(response)
          if response["results"].nil?
            @status_code = response["status"]
            @message = response["message"]
            @results = nil
          else
            @status_code = 200
            @message = "success"
            @results = response["results"]
          end
        end
      end
    end
  end
end