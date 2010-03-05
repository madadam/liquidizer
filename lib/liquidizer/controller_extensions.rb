require 'liquid'
require 'liquidizer/support'
require 'liquidizer/file_system'

module Liquidizer
  module ControllerExtensions
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        alias_method_chain :render, :liquid

        class_inheritable_accessor :liquify_actions
        class_inheritable_hash     :liquid_template_names_for_actions
        class_inheritable_accessor :liquid_template_name_for_layout

        before_filter :set_liquid_file_system
      end
    end

    def render_with_liquid(options = {}, &block)
      if action_template = liquid_template_for_action(options)
        assigns = assigns_for_liquify
        content = action_template.render!(assigns)

        if layout_template = liquid_template_for_layout(options)
          content = layout_template.render!(assigns.merge('content_for_layout' => content))
          options[:layout] = false
        end

        render_without_liquid(options.merge(:text => content))
      else
        if layout_template = liquid_template_for_layout(options)
          assigns = assigns_for_liquify

          content = render_to_string(options.merge(:layout => false))
          content = layout_template.render!(assigns.merge('content_for_layout' => content))

          render_without_liquid(options.merge(:text => content, :layout => false))
        else    
          render_without_liquid(options, &block)
        end
      end
    end

    private

    def liquid_template_for_action(options)
      action = extract_action_for_render(options)
      
      if action && liquify?(action)
        name = liquid_template_name_for_action(action)
        find_and_parse_liquid_template(name)
      else
        nil
      end
    end
    
    def liquify?(action)
      self.class.liquify_actions == :all ||
      self.class.liquify_actions &&
      self.class.liquify_actions.include?(action.to_sym)
    end

    def liquid_template_for_layout(options)
      if liquify_layout?(options)
        find_and_parse_liquid_template(self.class.liquid_template_name_for_layout)
      else
        nil
      end
    end
    
    def liquify_layout?(options)
      if options[:layout] == true ||
         options[:layout].nil? && liquifiable_options?(options)
        self.class.liquid_template_name_for_layout.present?
      else
        false
      end
    end
    
    def extract_action_for_render(options)
      if options.nil?
        action_name
      elsif options[:action]
        options[:action]
      elsif liquifiable_options?(options)
        action_name
      else
        nil
      end 
    end

    UNLIQUIFIABLE_OPTIONS = [:partial, :template, :file, :text, :xml, :json, :js, :inline]

    def liquifiable_options?(options)
      (options.keys.map(&:to_sym) & UNLIQUIFIABLE_OPTIONS).empty?
    end
    
    def find_and_parse_liquid_template(name)
      if template_record = find_liquid_template(name)
        template = Liquid::Template.parse(template_record.content)
        prepare_liquid_template(template)

        template
      else
        nil
      end
    end

    def liquid_template_name_for_action(action)
      liquid_template_names_for_actions[action.to_sym] || infer_liquid_template_name(action)
    end

    def infer_liquid_template_name(action)
      "#{controller_path}/#{action}"
    end

    def find_liquid_template(name)
      current_liquid_templates.find_by_name(name)
    end

    # This can be overriden to do some nasty things to the template before it's rendered.
    # For example, +assigns+ and +registers+ can be set here. The +template+ is an
    # instance of Liquid::Template.
    def prepare_liquid_template(template)
    end

    def assigns_for_liquify
      variable_names = instance_variable_names
      variable_names -= protected_instance_variables
      
      variable_names.inject({}) do |memo, name|
        assign_name = name[/^@(.*)$/, 1]           # strip @
        next memo if assign_name.starts_with?('_') # skip "private" ivars

        value = dropify(instance_variable_get(name))

        memo[assign_name] = value if value
        memo
      end
    end

    # Wrap the value in a drop, if it exists. Drop class is infered from the value class:
    #
    #   Foo::Bar -> Foo::BarDrop
    def dropify(value)
      if value.respond_to?(:to_liquid)
        if value.is_a?(Array)
          value.map { |element| dropify(element) }
        else
          value
        end
      else
        drop_class = infer_drop_class(value)
        drop_class && drop_class.new(value)
      end
    end

    def infer_drop_class(value)
      name = value.class.name + 'Drop'
      name = Liquidizer.drop_module.to_s + '::' + name if Liquidizer.drop_module

      Support.constant_defined?(name) ? name.constantize : nil
    end

    def set_liquid_file_system
      Liquid::Template.file_system = FileSystem.new { current_liquid_templates }
    end

    module ClassMethods
      # Define actions to liquify (render with liquid templates).
      #
      # == Examples
      #
      #     # liquify all actions
      #     liquify
      #
      #     # also liquify all actions
      #     liquify :all
      #
      #     # liquify only show and index
      #     liquify :show, :index  
      #
      #     # liquify only edit, but use template called awesome_edit
      #     liquify :edit, :as => 'awesome_edit'
      #
      # Unless you specify template name with the :as options, the name will be
      # inferend from controller and action names thusly:
      #
      # controller Blog, action :index        - blogs/index
      # controller Blog, action :show         - blogs/show
      # controller Blog, action :edit         - blogs/edit
      #
      # controller Blog::Post, action :index  - blog/posts/index
      # controller Blog::Post, action :show   - blog/posts/show
      # controller Blog::Post, action :edit   - blog/posts/edit
      #
      # You've got the idea.
      #
      def liquify(*actions)
        options = actions.extract_options!
        actions = actions.map(&:to_sym)

        self.liquify_actions = actions.empty? ? :all : actions
        self.liquid_template_names_for_actions = {}

        if options[:as]
          actions.each do |action|
            self.liquid_template_names_for_actions[action] = options[:as]
          end        
        end
      end

      # Liquify the layout.
      #
      # == Examples
      #
      #     # Uses layout template "layout"
      #     liquify_layout
      #
      #     # Uses layout template "wicked_layout"
      #     liquify_layout :as => 'wicked_layout'
      #
      def liquify_layout(options = {})
        self.liquid_template_name_for_layout = options[:as] || 'layout'
      end
    end
  end
end

if defined?(ActionController::Base)
  ActionController::Base.send(:include, Liquidizer::ControllerExtensions)
end
