module ActiveadminDynamicTable
  class SettingStringParser
    def initialize(settings_string)
      @settings_string = settings_string
    end

    def parse
      return [] if @settings_string.nil?

      columns = @settings_string.split(';')
      columns.map { |name| { column: name.to_sym } }
    end
  end
end
