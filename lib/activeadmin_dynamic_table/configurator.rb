# frozen_string_literal: true

module  ActiveadminDynamicTable
  class Configurator
    def initialize(context, settings)
      @context = context
      @settings = settings
      @api_calls = []
    end

    def register_column(*args, &block)
      options = args[1]

      default_width = options[:width]
      config = settings_hash[options[:key]] || ColumnSettings.new(options[:key], ["w#{default_width}"])

      api_call = RegisteredColumn.new key: options[:key],
                                      is_default: options[:default],
                                      args: args,
                                      block: block,
                                      config: config

      @api_calls << api_call
    end

    def columns
      applicable_columns.each do |applicable_column|
        @context.public_send(:column, *applicable_column.args, &applicable_column.block)
      end
    end

    def applicable_columns
      applicable_columns = []

      settings.each do |config|
        applicable_column = @api_calls.detect do |register_call|
          register_call.key == config.column
        end

        applicable_columns << applicable_column if applicable_column.present?
      end

      applicable_columns
    end

    def registered_columns
      @api_calls.map do |api_call|
        args = api_call.args

        {
          label: args[0],
          key: api_call.key,
          selected: selected?(api_call.key),
        }
      end
    end

    def width_for(key)
      col = settings_hash[key]

      return ColumnSettings.new(nil).width if col.nil?

      col.width
    end

    private

    def selected?(key)
      settings_hash[key].present?
    end

    def settings_hash
      settings.inject({}) do |acc, item|
        acc[item.column] = item
        acc
      end
    end

    def settings
      return @settings if @settings.size > 0

      @api_calls.select { |rc| rc.default? }.map { |rc| rc.config }
    end
  end
end
