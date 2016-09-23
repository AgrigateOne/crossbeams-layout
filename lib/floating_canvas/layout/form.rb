module FloatingCanvas
  module Layout

    class Form
      attr_reader :sequence, :nodes, :page_config, :form_action, :form_method, :got_row, :no_row

      def initialize(page_config, section_sequence, sequence)
        @sequence = sequence
        @form_action = '/' # work out from page_config.object?
        @nodes  = []
        @page_config = page_config
        @form_method = :create
        @got_row     = false
        @no_row      = false
      end

      def action(act)
        @form_action = act
      end

      def method(method)
        raise ArgumentError, "Invalid form method \"#{method}\"" unless [:create, :update].include?(method)
        @form_method = method
      end

      def row
        @got_row = true
        raise 'Cannot mix row and non-row text or fields' if no_row
        row = Row.new(page_config, sequence, nodes.length+1)
        yield row
        @nodes << row
      end

      def add_field(name, options={})
        @no_row = true
        raise 'Cannot mix row and fields' if got_row
        @nodes << Field.new(page_config, name, options)
      end

      def add_text(text)
        @no_row = true
        raise 'Cannot mix row and text' if got_row
        @nodes << Text.new(page_config, text)
      end

      def form_method_str
        case form_method
        when :create
          ''
        when :update
          '<input type="hidden" name="_method" value="PATCH">'
        end
      end

      def render
        # <form class="pure-form pure-form-aligned edit_user" id="edit_user_1" action="http://localhost:3002/users/1" accept-charset="UTF-8" method="post">
        # <input name="utf8" type="hidden" value="✓">
        # <input type="hidden" name="_method" value="patch"><input type="hidden" name="authenticity_token" value="XARxNVBl3eHsDuTDdLURzS3aTgDSaBOZGer6TMVgqmxEt6rj4LZ9Z1SWvta7jPFM3TT55OESF6Z4bdcoVkIX5A==">
        # <form class="pure-form pure-form-aligned edit_user" id="edit_user_1" action="#{form_action.sub(/\/(\d+)$/, "?id=#{1}")}" accept-charset="utf-8" method="POST">
        unless got_row
          # wrap nodes in row & cols.
          row = Row.make_row(page_config, sequence, 1)
          col = Column.make_column(page_config)
          nodes.each do |node|
            col.add_node( node)
          end
          row.add_node(col)
          renders = row.render << "\n"
        else
          renders = nodes.map {|s| s.render }.join("\n<!-- End Row -->\n")
        end
        <<-EOS
      <form class="pure-form pure-form-aligned edit_user" id="edit_user_1" action="#{form_action}" accept-charset="utf-8" method="POST">
        #{form_method_str}
        #{renders}
      <div class="actions pure-controls">
        <input type="submit" name="commit" value="Submit" data-disable-with="Submit" class="pure-button pure-button-primary">
      </div>
      </form>
        EOS
      end

    end

  end

end
