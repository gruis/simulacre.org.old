module Simulacre
  module Awestruct
    module Extensions

      # Gropus posts by MM/YY
      class Archive
        attr_reader :format, :url_format
        def initialize(format = "%B %Y", url_format = "/%Y/%m/")
          @format     = format
          url_format  = "/#{url_format}" unless url_format[0] ==  '/'
          url_format  = url_format[0..-2] if url_format[-1] ==  '/'
          @url_format = url_format
        end

        def execute(site)
          # there should be an easier way to do this
          site.engine.instance_variable_get(:@helpers).push(Helper)

          grouped = site.posts.inject({}) do |coll, post|
            key = post.date.strftime(format)
            (coll[key] ||= {:url => post.date.strftime(@url_format), :posts => []})[:posts].push(post)
            coll
          end

          grouped.each do |grp, psts|
            ::Awestruct::Extensions::Paginator.new(:posts, '/archive/index',
                                                   :remove_input  => false,
                                                   :output_prefix => psts[:url],
                                                   :collection    => psts[:posts].flatten,
                                                   :front_matter  => {:group => grp}
                                                  ).execute(site)
          end # grp, psts

          site.grouped_posts = grouped
        end # execute(site)

        module Helper
          # @todo use a partial template
          def grouped_posts(klass = '')
            html = %Q{<ul class="#{klass}">}
            begin
              site.grouped_posts.each do |name, attrs|
                psts = attrs[:posts]
                html += %Q{<li><a href="#{attrs[:url]}" title="#{name} #{psts.count}">#{name} (#{psts.count})</a></li>}
              end
            rescue Exception => e
              puts e
              puts e.backtrace
            end

            html += "</ul>"
            html
          end # grouped_posts
        end # module::Helper

      end # module::Archive

    end # module::Extensions
  end # module::Awestruct
end # module::Simulacre
