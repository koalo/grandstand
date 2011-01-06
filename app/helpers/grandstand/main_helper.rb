module Grandstand::MainHelper
  # Returns 'active' if the current page matches the passed URL hash. This will
  # require the controller to match. If one or more action is passed, those actions
  # (or params[:return_to]) must match as well. If not, it lets the controller mean
  # it's active.
  def active_on(*conditions)
    match = lambda do |condition|
      controllers = Array(condition.delete(:controller)).compact.flatten.map(&:to_s).uniq
      actions = Array(condition.delete(:action)).compact.map(&:to_s).flatten.uniq
      controllers.include?(controller_name) && (actions.empty? || actions.include?(action_name) || actions.include?(params[:return_to]))
    end
    options = {}
    if conditions.any?(&match)
      options[:class] = 'active'
    end
    options
  end

  # Renders a <button> tag. Helpful for forms and the like.
  # 
  #   <%= button("Save Changes", :class => "blue") %>
  # 
  # ... produces
  # 
  #   <button class="button blue"><span class="inner"><span>Save Changes</span></span></button>
  def button(*args)
    label = args.shift
    options = {:name => 'submit', :value => label}.merge(args.extract_options! || {})
    options, icon = button_options(options)
    content_tag(:button, options) { content_tag(:span, :class => icon ? "#{icon} icon" : nil) { label } }
  end

  # Similar to button, but generates a link instead of a button element. Useful for providing
  # buttons to GET actions:
  # 
  #   <%= button_link_to("Get Help", support_path, :icon => "help") %>
  # 
  # ... produces
  # 
  #   <a class="button blue" href="/support"><span class="inner"><span class="help icon">Get Help</span></span></button>
  # 
  # The extra spans are for any sliding door styling you may be interested in adding. Adding :icon to the options will
  # give the inner-most span a class of "#{options[:icon]} icon", allowing you to add extra images inside of your button.
  def button_link_to(*args)
    options, icon = button_options(args.extract_options! || {})
    link_to(content_tag(:span, :class => icon ? "#{icon} icon" : nil) { args.shift }, *args.push(options))
  end

  def button_options(options)
    classes = %w(button)
    if icon = options.delete(:icon)
      classes.push('has-icon')
    end
    if options.delete(:default)
      classes.push('default')
    end
    classes.push(options[:class].to_s.split(' ')) if options[:class]
    options[:class] = classes.uniq.join(' ')
    [options, icon]
  end

  def expand(*controllers)
    options = controllers.extract_options!
    options[:class] = Array(options[:class]).compact
    options[:class].push(:expandable)
    section = controllers.first
    controllers.map!(&:to_s)
    if controllers.include?(controller_name) || !((session[:expand] ||= []) & controllers).empty?
      options[:class].push(:expanded)
    end
    raw %( class="#{options[:class].join(' ')}")
  end

  def expand_link(section)
    link_to(raw('<span></span>'), '#', :class => 'expand', :rel => section)
  end

  def hide(condition)
    raw ' style="display:none;"' if condition
  end

  # A form wrapper that's used to override the default field_error_proc in a thread-safeish way.
  # The new field_error_proc returns a <div> with class "errors" on it, instead of an irritating
  # "fieldWithErrors" classname that nobody likes or wants to use. Only used in admin at the moment.
  def wrap_grandstand_form(&block)
    field_error_proc = ActionView::Base.field_error_proc
    ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| raw("<div class=\"errors\">#{html_tag}</div>") }
    concat(capture(&block))
    ActionView::Base.field_error_proc = field_error_proc
  end
end
