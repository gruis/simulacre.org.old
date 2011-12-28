module Simulacre
  module Awestruct
    module Extensions
      class Categorizer < ::Awestruct::Extensions::Tagger

        attr_reader :categories

        def initialize(categoriezed_items_property, input_path = '/index', pagination_opts={})
          @categories      = {}
          @categorized_items_property = categoriezed_items_property
          @input_path      = input_path
          #@output_path     = output_path
          @pagination_opts = pagination_opts
        end

        def execute(site)
          all = site.send( @categorized_items_property )
          return if ( all.nil? || all.empty? )

          tails = []
          all.each do |page|
            next unless page.categories
            last        = nil
            first, rest = page.categories[0], page.categories[1..-1]
            rest.inject( (categories[first] ||= Category.new(first)) ) { |head, cat| last = head.add(cat) }
            last = categories[first] if last.nil?
            last.pages.push(page)
            page.extend(CategoryLinker)
            page.categories = last.path.reverse
            tails |= [last]
          end # page

          tails.each do |tail|
            tail.path.each do |category|
              category.primary_page = ::Awestruct::Extensions::Paginator.new(  @categorized_items_property,
                                                                             @input_path,
                                                                             { :remove_input  => false,
                                                                               :output_prefix => File.join( "/category/", category.path(&:name).join('/').downcase.gsub(/\s/, "-")),
                                                                               :collection    => category.pages,
                                                                               :front_matter  => {:category => category.path(&:name).join(", ")}
                                                                             }.merge( @pagination_opts )
                                                                          ).execute(site)
            end # category
          end # tail
        end # execute(site)


        class Category
          attr_reader :name, :categories, :pages, :parent
          attr_accessor :primary_page
          def initialize(name, parent = nil)
            @name       = name
            @categories = {}
            @pages      = []
            @parent     = parent
          end

          def add(name)
            categories[name] = self.class.new(name, self) unless categories[name]
            categories[name]
          end # add(name)

          # Count the number of pages in this category and all its
          # children.
          def total
            categories.values.map(&:total).inject(pages.total) {|sum, cnt| sum + cnt }
          end # total

          def count
            pages.count
          end # count

          def to_link(style_class = nil)
            class_attr = (style_class ? ' class="' + style_class + '"' : '')
            %Q{<a#{class_attr} href="/category/#{path(&:name).join("/").downcase.gsub(/\s+/,"-")}/">#{name}</a>}
          end # to_link

          def path(&blk)
            return [block_given? ? blk.call(self) : self] if parent.nil?
            block_given? ? parent.path(&blk).push(blk.call(self)) : parent.path.push(self)
          end # path
        end # class::Category



        module CategoryLinker
          attr_accessor :categories
          def category_links(delimiter = ', ', style_class = nil)
            categories.reverse.map{|cat| cat.to_link(style_class) }.join(delimiter)
            #categories.map{|cat| %Q{<a#{class_attr} href="#{cat.primary_page.url}">#{cat}</a>}}.join(delimiter)
          end
        end # module::CategoryLinker

      end # class::Categorize < ::Awestruct::Extensions::Tagger
    end # module::Extensions
  end # module::Awestruct
end # module::Simulacre
