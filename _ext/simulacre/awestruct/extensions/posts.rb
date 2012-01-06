module Simulacre
  module Awestruct
    module Extensions

      # Creates a summary attribute and removes the prefix and date
      # from each post's rendered filename.
      #
      # Standard Posts in Awestruct will be output to
      # [prefix]/YYYY/MM/DD/[slug]. I'd prefer to have them directly
      # under the root '/'. This does mean that non-posts and posts can
      # collide, so care should be taken.
      class Posts < ::Awestruct::Extensions::Posts

        def execute(site)
          super(site).each do |page|
            page.layout = 'post' unless page.layout
            page.summary = Tilt.new("summary.md") { page.summary }.render if page.summary
            next unless page.slug
            page.slug.downcase!
            page.output_path = "/#{page.slug}.html"
          end # page
        end # execute(site)

      end # class::Posts < ::Awestruct::Extensions::Posts
    end # module::Extensions
  end # module::Awestruct
end # module::Simulacre
