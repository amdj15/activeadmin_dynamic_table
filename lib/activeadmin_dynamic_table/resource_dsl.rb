module ActiveAdmin
  class ResourceDSL
    def use_dynamic_csv(options = {})
      options[:resource] = config

      presenter = config.page_presenters[:index][:table]

      config.csv_builder = DynamicCSVBuilder.new(options, &presenter.block)
    end
  end
end
