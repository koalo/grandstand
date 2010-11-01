module Grandstand::MainHelper
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
