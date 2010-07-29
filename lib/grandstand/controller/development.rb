module Grandstand
  module Controller
    module Development
      def self.included(base)
        base.before_filter :generate_css_from_less
      end

      protected
      def generate_css_from_less
        Less::More.generate_all
      end
      protected :generate_css_from_less
    end
  end
end
