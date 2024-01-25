module ActiveadminDynamicTable
  class SettingStringParser
    def initialize(settings_string)
      @settings_string = settings_string
    end

    def parse
      return [] if @settings_string.nil?

      columns = @settings_string.split(';')

      columns.map do |col|
        name, *options = col.split(':')

        ColumnSettings.new(name, options)
      end
    end
  end
end
