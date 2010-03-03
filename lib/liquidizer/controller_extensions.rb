require 'liquid'

module Liquidizer
  module ControllerExtensions
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        alias_method_chain :render, :liquid

        class_inheritable_accessor :liquify_actions
        class_inheritable_hash     :liquid_template_names_for_actions
        class_inheritable_accessor :liquid_template_name_for_layout
      end
    end

    def render_with_liquid(options = {}, &block)
      action   = extract_action_for_render(options)
      template = action && liquify?(action) && liquid_template_for(action)

      if template = liquid_template_for(action)
        assigns = assigns_for_liquify
        content = template.render!(assigns)

        layout_template = liquify_layout?(options) && liquid_template_for_layout

        if layout_template
          content = layout_template.render!(assigns.merge('content_for_layout' => content))
          options[:layout] = false
        end

        render_without_liquid(options.merge(:text => content))
      else
        layout_template = liquify_layout?(options) && liquid_template_for_layout

        if layout_template
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

      # TODO: options can be hash not containing :action, neither any other render mode
      # (:text, :file, :template, :json, :xml, :inline, ...) in which case it should be
      # interpreted as :action => action_name
    end

    UNLIQUIFIABLE_OPTIONS = [:partial, :template, :file, :text, :xml, :json, :js, :inline]

    def liquifiable_options?(options)
      (options.keys.map(&:to_sym) & UNLIQUIFIABLE_OPTIONS).empty?
    end

    def liquify?(action)
      self.class.liquify_actions == :all ||
      self.class.liquify_actions.include?(action.to_sym)
    end

    def liquify_layout?(options)
      (options[:layout].nil? || options[:layout] == true) &&
        self.class.liquid_template_name_for_layout.present?
    end

    def liquid_template_for(action)
      name = liquid_template_name_for_action(action)
      find_and_parse_liquid_template(name)
    end

    def liquid_template_for_layout
      find_and_parse_liquid_template(self.class.liquid_template_name_for_layout)
    end
    
    def find_and_parse_liquid_template(name)
      template = find_liquid_template(name)
      template && parse_liquid_template(template)
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

    def parse_liquid_template(template)
      Liquid::Template.parse(template.content)
    end

    def assigns_for_liquify
      variable_names = instance_variable_names
      variable_names -= protected_instance_variables
      
      variable_names.inject({}) do |memo, name|
        assign_name = name[/^@(.*)$/, 1]           # strip @
        next memo if assign_name.starts_with?('_') # skip "private" ivars

        # TODO: liquify the variable

        memo[assign_name] = instance_variable_get(name)
        memo
      end
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

        self.liquify_actions = actions || :all
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
