module Simulacre
  module Awestruct
    module Extensions
      class Categorizer < ::Awestruct::Extensions::Tagger

        module CategoryLinker
          attr_accessor :categories
          def category_links(delimiter = ', ', style_class = nil)
            class_attr = (style_class ? ' class="' + style_class + '"' : '')
            categories.map{|tag| %Q{<a#{class_attr} href="#{tag.primary_page.url}">#{tag}</a>}}.join(delimiter)
          end
        end # module::CategoryLinker

        link_helper CategoryLinker
        page_accessor :categories

        def initialize(tagged_items_property, input_path = '/index', output_path='/category', pagination_opts={})
          super(tagged_items_property, input_path, output_path, pagination_opts)
        end

      end # class::Categorize < ::Awestruct::Extensions::Tagger
    end # module::Extensions
  end # module::Awestruct
end # module::Simulacre
