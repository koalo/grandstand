module Grandstand
  module FormBuilder #:nodoc: all
    def errors_on(*fields)
      if @object
        errors = []
        fields.each do |field|
          @object.errors[field].each do |error|
            errors.push("<li>#{error[0, 1] == error[0, 1].upcase ? error : "#{field.to_s.humanize} #{error}"}</li>")
          end
        end
        unless errors.empty?
          @template.content_tag(:ul, :class => 'errors') do
            @template.raw errors.join("\n")
          end
        end
      end
    end
  end
end
