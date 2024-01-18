# frozen_string_literal: true

module ActiveAdmin::Views
  class IndexAsDynamicTable < IndexAsTable
    def build(page_presenter, collection)
      settings = ActiveadminDynamicTable::SettingStringParser.new(params[:columns])

      @configurator = Configurator.new(self, settings.parse)

      table_options = {
        id: "index_table_#{active_admin_config.resource_name.plural}",
        sortable: true,
        class: "index_table index dynamic_table",
        i18n: active_admin_config.resource_class,
        paginator: page_presenter[:paginator] != false,
        row_class: page_presenter[:row_class]
      }

      div class: 'dynamic_table_wrapper' do
        table_for collection, table_options do |t|
          table_config_block = page_presenter.block || default_table
          instance_exec(t, &table_config_block)

          apply_configuration
        end

        columns_list
      end
    end

    def register_column(*args, &block)
      @configurator.register_column(*args, &block)
    end

    private

    def apply_columns
      @configurator.columns
    end

    def apply_configuration
      id_column
      apply_columns
      actions

      column "⚙️", class: 'col-table-preferences', & proc { '' }
    end

    def columns_list
      ul class: 'dynamic_table_configuration hidden' do
        @configurator.registered_columns.each do |col|
          li do
            label do
              input type: :checkbox, name: col[:key], checked: col[:selected]
              span col[:label]
            end
          end
        end
      end
    end
  end
end
