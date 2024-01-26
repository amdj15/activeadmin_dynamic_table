# frozen_string_literal: true
module ActiveadminDynamicTable
  class RegisteredColumn
    attr_reader :key, :args, :block, :config, :method

    def initialize(options)
      @is_default = options[:is_default]
      @key = options[:key]
      @args = options[:args]
      @block = options[:block]
      @config = options[:config]
      @method = options[:method]
    end

    def default?
      @is_default
    end
  end

  class ColumnSettings
    def initialize(column, options = [])
      @column = column
      @options = options
    end

    def column
      @column.to_sym
    end

    def width
      raw_width = @options.detect { |o| o[0] == 'w' }

      return default_width if raw_width.nil?

      width = raw_width[1..-1]
      width.to_i if Float(width)
    rescue
      default_width
    end

    def default_width
      @default_width || 50
    end

    def default_width=(value)
      @default_width = value
    end
  end
end
