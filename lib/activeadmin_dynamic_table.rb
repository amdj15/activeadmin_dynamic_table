# frozen_string_literal: true

require "active_admin"
require_relative "activeadmin_dynamic_table/version"
require_relative "activeadmin_dynamic_table/configurator"
require_relative "activeadmin_dynamic_table/setting_string_parser"
require_relative "activeadmin_dynamic_table/column_settings"
require_relative "activeadmin_dynamic_table/resource_dsl"
require_relative "activeadmin_dynamic_table/dynamic_csv_builder"
require_relative "activeadmin_dynamic_table/views/index_as_dynamic_table"

module ActiveadminDynamicTable
  class Error < StandardError; end
  class Engine < ::Rails::Engine; end
end
