# frozen_string_literal: true

require 'bigdecimal'
require 'diffy'
require 'json'
require 'ostruct'
require 'rouge'
require 'dry/configurable'

require 'crossbeams/layout/version'
require 'crossbeams/layout/styles_config'
require 'crossbeams/layout/method_builder'
require 'crossbeams/layout/examples_generator'
require 'crossbeams/layout/utils'

require 'crossbeams/layout/callback_section'
require 'crossbeams/layout/collection'
require 'crossbeams/layout/column'
require 'crossbeams/layout/diff'
require 'crossbeams/layout/dropdown_button'
require 'crossbeams/layout/expand_collapse_folds'
require 'crossbeams/layout/field'
require 'crossbeams/layout/fold_up'
require 'crossbeams/layout/form'
require 'crossbeams/layout/form_button'
require 'crossbeams/layout/grid'
require 'crossbeams/layout/help_link'
require 'crossbeams/layout/horizontal_group'
require 'crossbeams/layout/icon'
require 'crossbeams/layout/link'
require 'crossbeams/layout/list'
require 'crossbeams/layout/loading_message'
require 'crossbeams/layout/notice'
require 'crossbeams/layout/page'
require 'crossbeams/layout/page_config'
require 'crossbeams/layout/progress_step'
require 'crossbeams/layout/row'
require 'crossbeams/layout/section'
require 'crossbeams/layout/table'
require 'crossbeams/layout/address'
require 'crossbeams/layout/contact_method'
require 'crossbeams/layout/repeating_request'
require 'crossbeams/layout/sortable_list'
require 'crossbeams/layout/tab_set'
require 'crossbeams/layout/text'
require 'crossbeams/layout/renderer/base'
require 'crossbeams/layout/renderer/base_select'
require 'crossbeams/layout/renderer/checkbox'
require 'crossbeams/layout/renderer/datetime'
require 'crossbeams/layout/renderer/grid'
require 'crossbeams/layout/renderer/hidden'
require 'crossbeams/layout/renderer/input'
require 'crossbeams/layout/renderer/label'
require 'crossbeams/layout/renderer/list'
require 'crossbeams/layout/renderer/lookup'
require 'crossbeams/layout/renderer/multi'
require 'crossbeams/layout/renderer/radio_group'
require 'crossbeams/layout/renderer/select'
require 'crossbeams/layout/renderer/select_multiple'
require 'crossbeams/layout/renderer/textarea'
require 'crossbeams/layout/renderer/field_factory'
require 'crossbeams/layout/renderer/field_types'

# Load the Dashboard components
base = File.expand_path('layout/dashboard', __dir__)
Dir[File.join(base, '*.rb')].sort.each { |f| require f }

module Crossbeams
  # Layout an HTML page using DSL.
  module Layout
    class Error < StandardError; end

    # Serve local developer documentation (ASCIIDoc)
    class DeveloperDocumentation
      DOCUMENTATION_FILES = %w[page_layout.adoc non_field_renderers.adoc field_renderers.adoc dashboards.adoc].freeze

      def self.content(file)
        File.read(File.join(File.dirname(__FILE__), '../../developer_documentation', "#{file.chomp('.adoc')}.adoc"))
      end
    end
  end
end
