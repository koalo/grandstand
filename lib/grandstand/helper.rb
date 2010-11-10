module Grandstand
  # The Grandstand::Helper module will give you a number of ways to render page content
  # in your layouts, thus simplifying (considerably!) the headaches you may experience
  # with optional columns, etc.
  module Helper
    # Adds section-oriented class names if a current_page exists. Useful for styling your site to account for the presence
    # of various content sections; e.g. if a CMS user adds a page with content in the "left" column but not a page with
    # content in the "right" column, you can add:
    # 
    #   <body<%= page_class_name %>>
    # 
    # and end up with:
    # 
    #   <body class="has-left">
    # 
    # Likewise, you can add your own classes to the page_class_name method if you want to add other classes to the BODY tag, like so:
    # 
    #   <body<%= page_class_name :simple, 'another-class-name' %>>
    # 
    # Which might produce something like:
    # 
    #   <body class="simple another-class-name has-left has-right">
    # 
    # Using this, you can really dig deep into your stylesheets to hide empty columns and more
    def page_class_name(*extras)
      class_names = (extras.map(&:to_s) + Array(current_page.try(:class_names))).reject(&:blank?)
      unless class_names.empty?
        %( class="#{class_names.join(' ')}")
      end
    end

    # Displays formatted content for a page section based on its 'filter' attribute. Useful for rendering individual
    # page sections (if you're feeling so bold). It's probably easier to user page_section instead.
    def page_content(page_section)
      case page_section.filter
      when 'markdown'
        markdown(page_section.content)
      when 'textfile'
        textile(page_section.content)
      else
        simple_format(page_section.content)
      end
    end

    # page_section can be used to check for content in a certain area of your layout, and to render it as well. It will
    # return nil if there is no content for that section - so use it to quickly scope out sections and add them to your
    # layout when present, e.g.:
    # 
    #   <% if page_section(:left) -%>
    #   <div id="left">
    #     <%= page_section(:left) %>
    #     <!-- Add other content that might go here -->
    #   </div>
    #   <% end -%>
    # 
    def page_section(section_name)
      return nil unless current_page
      section_name = section_name.to_sym
      @_page_sections ||= {}
      return @_page_sections[section_name] if @_page_sections.has_key?(section_name)
      if current_page.page_sections.respond_to?(section_name) && !current_page.page_sections.send(section_name).empty?
        @_page_sections[section_name] = current_page.page_sections.send(section_name).map {|page_section| page_content(page_section) }.join("\n\n")
      else
        @_page_sections[section_name] = nil
      end
    end

    def page_title(separator = '|')
      if object = @post || current_page
        "#{object.name} #{separator}"
      end
    end
  end
end
