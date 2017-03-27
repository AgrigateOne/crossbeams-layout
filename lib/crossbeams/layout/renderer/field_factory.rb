module Crossbeams
  module Layout
    module Renderer
      class FieldFactory
        attr_reader :name, :field_config

        def initialize(field_name, field_config, page_config)
          @field_name   = field_name
          @page_config  = page_config
          @field_config = field_config
        end

        def render
          renderer = make_renderer(@field_config[:renderer])
          renderer.configure(@field_name, @field_config, @page_config)
          renderer.render
        end

        private

        def make_renderer(renderer=nil)
          # puts ">>> #{renderer}"
          case renderer
          when nil
            Input.new
          when Symbol
            FieldTypes::BUILT_IN_RENDERERS[renderer].new
          else
            renderer
          end
        end
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



