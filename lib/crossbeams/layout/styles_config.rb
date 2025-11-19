# frozen_string_literal: true

module Crossbeams
  module Layout
    # Configured classes for styling HMTL elements
    class StylesConfig
      extend Dry::Configurable

      setting :h1, default: 'text-xl tracking-normal font-medium leading-none'  # title-large
      setting :h2, default: 'text-lg tracking-normal font-medium leading-tight' # title-medium
      setting :h3, default: 'text-base tracking-normal leading-4 font-semibold' # title-small
      setting :h4, default: 'text-sm tracking-normal font-semibold leading-6'   # title-x-small
      setting :em, default: 'italic'
      setting :strong, default: 'font-semibold'
      setting :p, default: 'text-base tracking-normal leading-6 font-normal'
      setting :bodycopy, default: 'text-base tracking-normal leading-6 font-normal'
      setting :bodycopy_small, default: 'text-sm tracking-normal leading-6 font-normal'

      setting :row_maxwidth, default: 'max-width: 1200px;'
      setting :ul, default: 'list-disc list-inside'
      setting :ol, default: 'list-decimal list-inside'
      setting :li, default: 'list-item'
      setting :link, default: 'text-ocean-600 text-base tracking-normal leading-6 font-normal underline hover:text-slate-800'
      setting :label, default: 'text-base font-normal tracking-normal leading-6 mb-1'
      setting :label_in_err, default: 'text-base font-normal tracking-normal leading-6 mb-1 text-red-600 disabled:slate-400'
      # setting :label_inline, default: 'text-base font-normal tracking-normal leading-6 mb-1'
      # setting :label_inline_in_err, default: 'text-base font-normal tracking-normal leading-6 mb-1 text-red-600'

      # setting :input, default: 'w-full rounded border border-slate-300 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-offset-0 focus:border-blue-600 focus-visible:border-blue-600'
      setting :input, default: 'w-full rounded border border-slate-300 bg-white outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:ring-ocean-700 focus:border-ocean-700 text-slate-800'
      # setting :input_in_err, default: 'w-full rounded border border-red-600 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-red-600 focus:ring-offset-0 focus:border-red-600 focus-visible:border-red-600 text-red-600'
      setting :input_in_err, default: 'w-full rounded border border-red-200 bg-white outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline-2 focus:ring-red-500 focus:border-red-500 text-red-600'

      setting :checkbox, default: 'cursor-pointer rounded mr-2 w-5 h-5 outline-none checked:text-ocean-500 hover:text-ocean-700 focus:ring-0 focus:ring-transparent focus:ring-offset-0 focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-ocean-700 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:text-slate-400 accent-ocean-700'
      setting :checkbox_in_err, default: 'border-red-600 ring-red-600 cursor-pointer rounded mr-2 w-5 h-5 outline-none checked:text-ocean-500 hover:text-ocean-700 focus:ring-0 focus:ring-transparent focus:ring-offset-0 focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-ocean-700 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:text-slate-400 accent-ocean-700'

      setting :select, default: 'bg-white border border-slate-300 outline-none px-3 py-2 text-slate-900 rounded selection:bg-ocean-700 selection:text-white focus-visible:ring-ocean-700 focus-visible:border-ocean-700 disabled:text-slate-400 disabled:placeholder:text-slate-400 disabled:cursor-not-allowed placeholder:!text-slate-500'

      setting :textarea, default: 'w-full rounded border border-slate-300 bg-white outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-offset-0 focus:border-blue-600 focus-visible:border-blue-600'

      # setting :rmd_input, default: 'w-full rounded border border-slate-300 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-offset-0 focus:border-blue-600 focus-visible:border-blue-600'
      setting :rmd_input, default: 'w-full rounded border border-slate-300 bg-white outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline-2 focus:ring-ocean-700 focus:border-ocean-700 text-slate-800'
      # setting :rmd_input_in_err, default: 'w-full rounded border border-red-600 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-red-600 focus:ring-offset-0 focus:border-red-600 focus-visible:border-red-600 text-red-600'
      setting :rmd_input_in_err, default: 'w-full rounded border border-red-200 bg-white outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline-2 focus:ring-red-500 focus:border-red-500 text-red-600'

      # setting :icon, default: 'inline-block w-5 h-5 fill-current relative top-0.5'
      setting :icon, default: 'w-4 h-4 fill-current'
      # setting :icon_s, default: 'inline w-5 h-5 stroke-current relative top-0.5'
      setting :icon_s, default: 'w-4 h-4 stroke-current'
      setting :hover_row, default: 'hover:bg-slate-100'

      setting :button_secondary, default: 'flex items-center justify-left gap-3 flex-row rounded border-2 border-$:secondary_bg$ h-[2.75rem] min-w-[2.75rem] px-4 py-2 outline-none select-none whitespace-nowrap cursor-pointer font-normal text-$:secondary_colour$ bg-$:secondary_bg$ active:bg-ocean-700 active:border-$:primary_h_colour$ hover:text-$:primary_h_colour$ hover:bg-$:secondary_h_bg$ focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 focus-visible:ring-ocean-500'

      setting :button_primary, default: 'flex items-center justify-left gap-3 flex-row font-normal select-none whitespace-nowrap rounded border-2 border-ocean-700 cursor-pointer outline-none focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 px-4 py-2 h-[2.75rem] min-w-[2.75rem] bg-ocean-700 text-white border-ocean-700 active:bg-ocean-700 active:border-$:primary_h_colour$ hover:bg-$:primary_h_colour$ hover:border-$:primary_h_colour$ disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-400 disabled:border-slate-200 disabled:hover:bg-slate-200 disabled:hover:border-slate-200 focus-visible:ring-ocean-500'
      setting :button_tertiary, default: 'flex items-center justify-left gap-3 flex-row mt-2 rounded h-[2.75rem] min-w-[2.75rem] px-4 py-2 outline-none select-none whitespace-nowrap cursor-pointer font-normal text-slate-800 active:bg-zinc-200 active:border-$:primary_h_colour$ hover:text-$:primary_h_colour$ hover:bg-$:secondary_h_bg$ focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 focus-visible:ring-ocean-500'
      setting :file_input_button, default: 'file:rounded file:border-2 file:h-[2.75rem] file:min-w-[2.75rem] file:px-4 file:py-2 file:outline-none file:select-none file:whitespace-nowrap file:cursor-pointer file:font-normal file:text-$:secondary_colour$ file:bg-$:secondary_bg$ file:active:bg-ocean-700 file:active:border-$:primary_h_colour$ file:hover:text-$:primary_h_colour$ file:hover:bg-$:secondary_h_bg$ file:focus-visible:ring file:focus-visible:ring-offset-white file:focus-visible:ring-offset-2 file:focus-visible:ring-ocean-500 file:border-none'

      setting :primary_colour, default: 'slate-800'
      setting :primary_bg, default: 'slate-300'
      setting :primary_h_colour, default: 'ocean-700'
      setting :primary_h_bg, default: 'ocean-100'
      setting :secondary_h_bg, default: 'ocean-50'
      setting :show_check_on, default: 'text-green-700'
      setting :show_check_off, default: 'text-red-600'
      setting :bg_green, default: 'bg-green-500'
      setting :bg_amber, default: 'bg-yellow-500'
      setting :bg_red, default: 'bg-red-500'
      setting :bg_blue, default: 'bg-blue-500'

      setting :secondary_colour, default: 'slate-800'
      setting :secondary_bg, default: 'slate-200'

      setting :text_warning, default: 'text-orange-600'
      setting :bg_warning, default: 'bg-orange-100'
      setting :text_error, default: 'text-red-600'
      # setting :notice, default: 'm-2 p-1.5 border border-ocean-700'
      setting :notice, default: 'm-2 flex flex-row justify-start items-center gap-2 px-3 py-4 mb-4 rounded'
      setting :note_info, default: 'bg-sky-100 text-sky-800'
      setting :note_success, default: 'bg-green-100 text-green-600'
      setting :note_warning, default: '$:bg_warning$ $:text_warning$'
      setting :note_error, default: 'bg-red-100 text-red-600'

      setting :table_div, default: 'border border-slate-300 rounded-lg overflow-hidden'
      setting :table_div_no_b, default: 'overflow-hidden'
      setting :table, default: 'w-full h-full border-collapse overflow-auto'
      setting :table_row_odd, default: '$:hover_row$'
      setting :table_row_even, default: '$:hover_row$ bg-slate-50'
      # setting :table_info_th, default: 'p-4 border-r border-b border-slate-200 text-slate-500'
      # setting :table_info_td, default: 'px-4 py-2'
      setting :table_th, default: 'p-5 py-2 border-t border-slate-300 text-slate-800 font-semibold'
      setting :table_th_no_b, default: 'p-5 py-2 text-slate-800 font-semibold'
      setting :table_td, default: 'px-5 py-2 border-t border-slate-300'
      setting :table_td_no_b, default: 'px-5 py-2'
      setting :table_caption, default: 'p-5 py-2 border-b border-slate-300 text-slate-800 font-semibold'

      setting :rmd_table_div, default: 'w-full mt-1 border border-slate-300 rounded-lg overflow-hidden'
      setting :rmd_table, default: 'w-full h-full border-collapse overflow-auto'
      setting :rmd_table_row_odd, default: '$:hover_row$'
      setting :rmd_table_row_even, default: '$:hover_row$ bg-slate-50'
      setting :rmd_table_td_label, default: 'px-5 py-2 w-1/2 border-t border-slate-300 text-slate-800 font-semibold'
      setting :rmd_table_td_value, default: 'px-5 py-2 w-1/2 border-t border-slate-300'
      setting :rmd_select, default: 'bg-white border border-slate-300 outline-none px-3 py-2 text-slate-900 rounded selection:bg-ocean-700 selection:text-white focus-visible:ring-ocean-700 focus-visible:border-ocean-700 disabled:text-slate-400 disabled:placeholder:text-slate-400 disabled:cursor-not-allowed placeholder:!text-slate-500'

      setting :rmd_button_primary, default: 'font-normal select-none whitespace-nowrap rounded border-2 cursor-pointer outline-none focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 px-4 py-7 min-w-[2.75rem] bg-ocean-700 text-white border-ocean-700 active:bg-ocean-700 active:border-$:primary_h_colour$ hover:bg-$:primary_h_colour$ hover:border-$:primary_h_colour$ disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-400 disabled:border-slate-200 disabled:hover:bg-slate-200 disabled:hover:border-slate-200 focus-visible:ring-ocean-500 w-fit'

      # Translate values of "colour_rule" grid columns to css classes:
      setting :grid_row_colours, default: { 'black' => 'text-blue-600',
                                            'blue' => 'text-blue-600',
                                            'brown' => 'text-yellow-800',
                                            'dark-pink' => 'text-fuscia-600',
                                            'error' => 'text-red-600',
                                            'gray' => 'text-stone-400',
                                            'grey' => 'text-stone-400',
                                            'green' => 'text-green-600',
                                            'inactive' => 'text-stone-400 italic',
                                            'inprogress' => 'text-purple-900',
                                            'ok' => 'text-green-600',
                                            'orange' => 'text-orange-500',
                                            'pink' => 'text-fuscia-400',
                                            'purple' => 'text-purple-900',
                                            'ready' => 'text-green-600',
                                            'red' => 'text-red-600',
                                            'warning' => 'text-orange-500',
                                            'yellow' => 'text-yellow-400' }

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
