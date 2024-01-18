# frozen_string_literal: true

module ActiveAdmin::Views
  class Configurator
    def initialize(context, settings)
      @context = context
      @settings = settings
      @api_calls = []
    end

    def register_column(*args, &block)
      data = args[1]

      api_call = {
        key: data[:key],
        args: args,
        block: block,
      }

      @api_calls << api_call
    end

    def columns
      applicable_columns.each do |applicable_column|
        @context.public_send(:column, *applicable_column[:args], &applicable_column[:block])
      end
    end

    def applicable_columns
      applicable_columns = []

      @settings.each do |config|
        applicable_column = @api_calls.detect do |register_call|
          register_call[:key] == config[:column]
        end

        applicable_columns << applicable_column if applicable_column.present?
      end

      applicable_columns
    end

    def registered_columns
      @api_calls.map do |api_call|
        args = api_call[:args]

        {
          label: args[0],
          key: api_call[:key],
          selected: selected?(api_call[:key]),
        }
      end
    end

    def selected?(key)
      settings_hash[key].present?
    end

    def settings_hash
      @settings_hash ||= @settings.inject({}) do |acc, item|
        acc[item[:column]] = item
        acc
      end
    end
  end
end
