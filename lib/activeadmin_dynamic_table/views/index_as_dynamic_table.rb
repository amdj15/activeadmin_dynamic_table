# frozen_string_literal: true

module ActiveAdmin::Views
  class IndexAsDynamicTable < IndexAsTable
    class IndexDynamicTableFor < IndexTableFor
      def build(configurator, *args, &block)
        @configurator = configurator
        super(*args, &block)
      end

      def build_table_header(col)
        classes = Arbre::HTML::ClassList.new
        sort_key = sortable? && col.sortable? && col.sort_key
        params = request.query_parameters.except :page, :order, :commit, :format

        classes << "sortable" if sort_key
        classes << "sorted-#{current_sort[1]}" if sort_key && current_sort[0] == sort_key
        classes << col.html_class

        style = ""
        options = col.instance_variable_get(:@options)
        style = "width: #{@configurator.width_for(options[:key])}px" if options[:key].present?

        if sort_key
          th class: classes, style: style do
            span do
              link_to col.pretty_title, params: params, order: "#{sort_key}_#{order_for_sort_key(sort_key)}"
            end
          end
        else
          th class: classes, style: style do
            span do
              col.pretty_title
            end
          end
        end
      end
    end

    def build(page_presenter, collection)
      settings = ActiveadminDynamicTable::SettingStringParser.new(params[:columns])
      @configurator = ActiveadminDynamicTable::Configurator.new(self, settings.parse)

      table_options = {
        id: "index_table_#{active_admin_config.resource_name.plural}",
        sortable: true,
        class: "index_table index dynamic_table",
        i18n: active_admin_config.resource_class,
        paginator: page_presenter[:paginator] != false,
        row_class: page_presenter[:row_class]
      }

      table_for collection, table_options do |t|
        table_config_block = page_presenter.block || default_table
        instance_exec(t, &table_config_block)

        apply_configuration
      end

      columns_list
    end

    def table_for(*args, &block)
      insert_tag IndexDynamicTableFor, @configurator, *args, &block
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
