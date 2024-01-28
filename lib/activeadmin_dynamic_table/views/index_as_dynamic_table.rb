# frozen_string_literal: true

module ActiveAdmin::Views
  class IndexAsDynamicTable < IndexAsTable
    class IndexDynamicTableFor < IndexTableFor
      def build(configurator, *args, &block)
        @configurator = configurator
        super(*args, &block)
      end

      def build_table_header(col)
        sort_key = sortable? && col.sortable? && col.sort_key
        params = request.query_parameters.except :page, :order, :commit, :format
        options = options_for_col(col, sort_key)

        if sort_key
          th options do
            span do
              link_to col.pretty_title, params: params, order: "#{sort_key}_#{order_for_sort_key(sort_key)}"
            end
          end
        else
          th options do
            span col.pretty_title
          end
        end
      end

      def options_for_col(col, sort_key)
        classes = Arbre::HTML::ClassList.new
        classes << "sortable" if sort_key
        classes << "sorted-#{current_sort[1]}" if sort_key && current_sort[0] == sort_key
        classes << "reorder"
        classes << col.html_class

        options = col.instance_variable_get(:@options)
        style = options[:style] || ''
        style = "width: #{@configurator.width_for(options[:key])}px" if options[:key].present?

        {
          class: classes,
          style: style,
          'data-column-key': options[:key],
        }
      end

      # Display a column for checkbox
      def selectable_column
        return unless active_admin_config.batch_actions.any?

        options = {
          style: "width: 30px",
          class: "col-selectable",
          sortable: false,
        }

        column resource_selection_toggle_cell, options do |resource|
          resource_selection_cell resource
        end
      end

      # Display a column for the id
      def id_column(*args)
        raise "#{resource_class.name} has no primary_key!" unless resource_class.primary_key
        data = args[1] || args[0]

        options = {
          sortable: resource_class.primary_key,
          'data-column-key': data[:key],
          **data,
        }

        column(resource_class.human_attribute_name(resource_class.primary_key), options) do |resource|
          if controller.action_methods.include?("show")
            link_to resource.id, resource_path(resource), class: "resource_id_link"
          elsif controller.action_methods.include?("edit")
            link_to resource.id, edit_resource_path(resource), class: "resource_id_link"
          else
            resource.id
          end
        end
      end

      def index_column(*args)
        data = args[1] || args[0]
        start_value = data.delete(:start_value) || 1

        options = {
          class: "col-index",
          sortable: false,
          **data,
        }

        column "#", options do |resource|
          @collection.offset_value + @collection.index(resource) + start_value
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
      @configurator.register_column(:column, *args, &block)
    end

    def register_id_column(*args, &block)
      @configurator.register_column(:id_column, *args, &block)
    end

    def register_index_column(*args, &block)
      @configurator.register_column(:index_column, *args, &block)
    end

    def register_actions(*args, &block)
      @configurator.register_column(:actions, *args, &block)
    end

    private

    def apply_columns
      @configurator.columns
    end

    def apply_configuration
      apply_columns
      column "⚙️", style: "width: 30px", class: 'col-table-preferences', & proc { '' }
    end

    def columns_list
      ul class: 'dynamic_table_configuration hidden' do
        @configurator.registered_columns.each do |col|
          args = col[:args]

          options = args.extract_options!
          title = args[0]
          data = args[1] || args[0]

          column = ::ActiveAdmin::Views::TableFor::Column.new(title, data, @resource_class, options)

          li do
            label do
              input type: :checkbox, name: col[:key], checked: col[:selected]
              span column.pretty_title
            end
          end
        end
      end
    end
  end
end
