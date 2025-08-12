# frozen_string_literal: true

module Crossbeams
  module Layout
    # Configured classes for styling HMTL elements
    class StylesConfig
      extend Dry::Configurable

      setting :h1, default: 'text-lg tracking-normal font-medium leading-none' # title-large
      setting :h2, default: 'text-base tracking-normal font-medium leading-tight' # title-medium
      setting :h3, default: 'text-sm tracking-normal leading-4 font-semibold' # title-small
      setting :h4, default: 'text-xs tracking-normal font-semibold leading-6' # title-x-small
      setting :em, default: 'italic'
      setting :strong, default: 'font-semibold'
      setting :p, default: 'text-base tracking-normal leading-6 font-normal'
      setting :bodycopy, default: 'text-base tracking-normal leading-6 font-normal'
      setting :bodycopy_small, default: 'text-sm tracking-normal leading-6 font-normal'

      setting :ul, default: 'list-disc list-inside'
      setting :ol, default: 'list-decimal list-inside'
      setting :li, default: 'list-item'
      setting :link, default: 'text-french-blue-500 text-base tracking-normal leading-6 font-normal underline hover:text-slate-800'
      setting :label, default: 'text-base font-normal tracking-normal leading-6 mb-1'
      setting :label_in_err, default: 'text-base font-normal tracking-normal leading-6 mb-1 text-red-700 disabled:slate-400'
      # setting :label_inline, default: 'text-base font-normal tracking-normal leading-6 mb-1'
      # setting :label_inline_in_err, default: 'text-base font-normal tracking-normal leading-6 mb-1 text-red-700'

      setting :input, default: 'w-full rounded border border-slate-300 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-offset-0 focus:border-blue-600 focus-visible:border-blue-600'
      setting :input_in_err, default: 'w-full rounded border border-red-700 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-red-600 focus:ring-offset-0 focus:border-red-600 focus-visible:border-red-600 text-red-700'

      setting :checkbox, default: 'cursor-pointer rounded mr-2 w-5 h-5 outline-none checked:text-french-blue-500 hover:text-french-blue-600 focus:ring-0 focus:ring-transparent focus:ring-offset-0 focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-steel-blue-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:text-slate-400 accent-french-blue-600'
      setting :checkbox_in_err, default: 'border-red-600 ring-red-600 cursor-pointer rounded mr-2 w-5 h-5 outline-none checked:text-french-blue-500 hover:text-french-blue-600 focus:ring-0 focus:ring-transparent focus:ring-offset-0 focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-steel-blue-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:text-slate-400 accent-french-blue-600'

      setting :icon, default: 'inline-block w-5 h-5 fill-current relative top-0.5'
      setting :hover_row, default: 'hover:bg-slate-100'

      setting :button_secondary, default: 'flex items-center justify-center gap-3 flex-row rounded border-2 h-[2.75rem] min-w-[2.75rem] px-4 py-2 outline-none select-none whitespace-nowrap cursor-pointer font-normal text-$:secondary_colour$ bg-$:secondary_bg$ active:bg-french-blue-600 active:border-$:primary_h_colour$ hover:text-$:primary_h_colour$ hover:bg-$:secondary_h_bg$ focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 focus-visible:ring-french-blue-500'

      setting :button_primary, default: 'font-normal select-none whitespace-nowrap rounded border-2 cursor-pointer outline-none focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 px-4 py-2 h-[2.75rem] min-w-[2.75rem] bg-french-blue-600 text-white border-french-blue-600 active:bg-french-blue-600 active:border-$:primary_h_colour$ hover:bg-$:primary_h_colour$ hover:border-$:primary_h_colour$ disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-400 disabled:border-slate-200 disabled:hover:bg-slate-200 disabled:hover:border-slate-200 focus-visible:ring-french-blue-500'
      setting :button_tertiary, default: 'mt-2 rounded h-[2.75rem] min-w-[2.75rem] px-4 py-2 outline-none select-none whitespace-nowrap cursor-pointer font-normal text-slate-800 active:bg-zinc-200 active:border-$:primary_h_colour$ hover:text-$:primary_h_colour$ hover:bg-$:secondary_h_bg$ focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 focus-visible:ring-french-blue-500'

      setting :primary_colour, default: 'slate-800'
      setting :primary_bg, default: 'slate-300'
      setting :primary_h_colour, default: 'french-blue-600'
      setting :primary_h_bg, default: 'steel-blue-100'
      setting :secondary_h_bg, default: 'french-blue-50'

      setting :secondary_colour, default: 'slate-800'
      setting :secondary_bg, default: 'slate-200'

      setting :text_warning, default: 'text-orange-600'
      setting :bg_warning, default: 'bg-orange-100'
      # setting :notice, default: 'm-2 p-1.5 border border-steel-blue-500'
      setting :notice, default: 'm-2 flex flex-row justify-start items-center gap-2 px-3 py-4 mb-4 rounded'
      setting :note_info, default: 'bg-blue-100 text-sky-800'
      setting :note_success, default: 'bg-green-100 text-green-600'
      setting :note_warning, default: '$:bg_warning$ $:text_warning$'
      setting :note_error, default: 'bg-red-100 text-red-700'

      setting :table_info_th, default: 'p-4 border-r border-b border-slate-200 text-slate-500'
      setting :table_info_td, default: 'px-4 py-2'
      setting :table_th, default: 'p-1 border-r border-b border-slate-200 text-slate-500'
      setting :table_td, default: 'px-1 py-1'

      def self.css_class(setting_name)
        str = config[setting_name]
        return str unless str.include?('$:')

        tokens = str.split('$').select { |s| s.start_with?(':') }.map { |s| ["$#{s}$", config[s.delete_prefix(':').to_sym]] }
        str.gsub(/#{tokens.map(&:first).join('|').gsub('$', '\$')}/, Hash[tokens])
      end

      def self.important_css_class(setting_name) # rubocop:disable Metrics/AbcSize
        str = config[setting_name]
        return "!#{str.gsub(' ', ' !')}" unless str.include?('$:')

        tokens = str.split('$').select { |s| s.start_with?(':') }.map { |s| ["$#{s}$", config[s.delete_prefix(':').to_sym]] }
        "!#{str.gsub(/#{tokens.map(&:first).join('|').gsub('$', '\$')}/, Hash[tokens]).gsub(' ', ' !')}"
      end
    end
  end
end
