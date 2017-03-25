module Crossbeams
  module Layout
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
        false
      end

      def render
        # Needs another pass of config to resolve if we're doing a view/edit etc.
        renderer = Renderer::FieldFactory.new(name, {renderer: :text}, page_config)
        # renderer.configure(page_config)
        renderer.render

      #   <<-EOS
      # <div class="field pure-control-group">
      #   <label for="#{page_config.name}_#{name}">#{caption}</label>
      #   <input type="text" value="#{page_config.form_object.send(name)}" name="#{page_config.name}[#{name}]" id="#{page_config.name}_#{name}">
      # </div>
      #   EOS
      end

      private
      # def renderer
      #   renderer = Renderer::Factory.new(page_config[:fields][name]) # pass object and rules and config....
      #   renderer.configure(page_config)
      #   renderer
      #   # #render_klass = page_config[:renderer] || InputRenderer
      #   # render_klass = case page_config[:renderer]
      #   #                when String
      #   #                  self.const_get(page_config[:renderer])
      #   #                when Constant
      #   #                  page_config[:renderer]
      #   #                else
      #   #                  InputRenderer
      #   #                end
      #   # render_klass.new(page_config[:fields][name.to_sym])
      # end
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


