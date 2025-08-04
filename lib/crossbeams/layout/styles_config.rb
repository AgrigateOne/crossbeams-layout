# frozen_string_literal: true

module Crossbeams
  module Layout
    # Configured classes for styling HMTL elements
    class StylesConfig
      extend Dry::Configurable

      setting :h1, default: 'text-3xl font-semibold leading-none' # display/medium
      setting :h2, default: 'text-2xl leading-tight' # headings/large
      setting :h3, default: 'text-xl' # headings/medium
      setting :h4, default: 'text-lg leading-6' # headings/small
      setting :em, default: 'italic'
      setting :strong, default: 'font-semibold'

      setting :ul, default: 'list-disc list-inside'
      setting :ol, default: 'list-decimal list-inside'
      setting :li, default: 'list-item'
      setting :link, default: 'underline'
      setting :label, default: 'block text-lg font-light mb-1'
      setting :label_inline, default: 'inline text-lg font-light mb-1'

      setting :icon, default: 'inline-block w-5 h-5 fill-current relative top-0.5'
      setting :hover_row, default: 'hover:bg-slate-100'

      setting :button_secondary, default: 'flex items-center justify-center gap-3 flex-row rounded border-2 h-11 p-3 font-medium text-$:primary_colour$ bg-$:primary_bg$ hover:text-$:primary_h_colour$ hover:bg-$:primary_h_bg$'
      setting :button_primary, default: 'font-medium select-none whitespace-nowrap rounded border-2 cursor-pointer outline-none focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 bg-french-blue-600 border-french-blue-600 p-3 h-[2.75rem] min-w-[2.75rem] bg-french-blue-500 text-white border-french-blue-500 active:bg-french-blue-600 active:border-$:primary_h_colour$ hover:bg-$:primary_h_colour$ hover:border-$:primary_h_colour$ disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-400 disabled:border-slate-200 disabled:hover:bg-slate-200 disabled:hover:border-slate-200 focus-visible:ring-french-blue-500'

      setting :primary_colour, default: 'slate-800'
      setting :primary_bg, default: 'slate-300'
      setting :primary_h_colour, default: 'french-blue-600'
      setting :primary_h_bg, default: 'steel-blue-100'

      setting :notice, default: 'm-2 p-1.5 border border-steel-blue-500'
      setting :note_info, default: 'bg-french-blue-500 text-white'
      setting :note_success, default: 'bg-teal-600 text-white'
      setting :note_warning, default: 'bg-yellow-400 text-white'
      setting :note_error, default: 'bg-red-200 text-red-700'

      def self.css_class(setting_name)
        str = config[setting_name]
        return str unless str.include?('$:')

        tokens = str.split('$').select { |s| s.start_with?(':') }.map { |s| ["$#{s}$", config[s.delete_prefix(':').to_sym]] }
        str.gsub(/#{tokens.map(&:first).join('|').gsub('$', '\$')}/, Hash[tokens])
      end
    end
  end
end
