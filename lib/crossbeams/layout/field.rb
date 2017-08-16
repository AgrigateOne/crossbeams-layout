# frozen_string_literal: true

module Crossbeams
  module Layout
    # Field object which is rendered by a specific field renderer.
    class Field
      attr_reader :name, :caption, :page_config

      def initialize(page_config, name, options = {})
        @name        = name
        @caption     = options[:caption] || name
        @page_config = page_config
      end

      def invisible?
        false
      end

      def hidden?
        field_config[:renderer] == :hidden
      end

      def render
        # Needs another pass of config to resolve if we're doing a view/edit etc.
        renderer = Renderer::FieldFactory.new(name, field_config, page_config)
        # renderer.configure(page_config)
        renderer.render
      end

      private

      def field_config
        (page_config.options[:fields] || {})[name]
      end
    end
  end
end
__END__

module Env ##### Crossbeams::Layout::Renderer
class Default
  def render
    "    render from Default"
  end
end

class Input
  def render
    "    render from Input"
  end
end

class Select
  def render
    "    render from Select"
  end
end

class Factory

  RENDS = {email: Input, text: Input, select: Select}

  def render(renderer=nil)
    puts "- #{renderer.class}: #{renderer}"
    ren = case renderer # Could simplify to: nil / symbol else expect instantiated object
                   when nil
                     Default.new
                   when String
                     Env.const_get(renderer).new
                   when Symbol
                     RENDS[renderer].new
                   when Class
                     renderer.new
                   else
                     renderer
                   end
    # render_klass.new.render #(page_config[:fields][name.to_sym])
    ren.render #(page_config[:fields][name.to_sym])
  end

end
end

factory = Env::Factory.new
puts factory.render 'Input'
puts factory.render 'Select'
puts factory.render Env::Input
puts factory.render Env::Input.new
puts factory.render

class Plugin
  def render
    "    render from Plugin"
  end
end
puts factory.render Plugin.new
puts factory.render :email
puts factory.render :text
puts factory.render :select


