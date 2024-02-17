module ActiveAdmin
  class DynamicCSVBuilder < CSVBuilder
    def exec_columns(view_context = nil)
      @view_context = view_context
      settings = ActiveadminDynamicTable::SettingStringParser.new(@view_context.params[:columns])

      @configurator = ActiveadminDynamicTable::Configurator.new(self, settings.parse)
      @columns = [] # we want to re-render these every instance

      instance_exec &@block
      @configurator.columns

      columns
    end

    def build_row(resource, columns, options)
      columns.map do |column|
        content = call_method_or_proc_on(resource, column.data)
        encode view_context.strip_tags(content.to_s), options
      end
    end

    def register_column(*args, &block)
      @configurator.register_column(:column, *args, &block)
    end

    def register_id_column(*args, &block)
      @configurator.register_column(:column, :id, key: :id)
    end

    def register_actions(*args, &block); end
    def selectable_column; end
  end
end
