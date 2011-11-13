# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.

module Nesta
  class App
    use Rack::Static, :urls => ["/images","/js"], :root => "themes/simark0/public"

    helpers do

      # Retrieves each category and the number of times the category is
      # has been associated with an article.
      # @return [Hash] category occurence indexed by count
      # @todo figure out how to cache the count
      def categories_cnt
        ccnt = Hash.new { |h,k| h[k] = 0 }
        Nesta::Page.find_all
        .reject {|p| p.metadata('categories').nil? }
        .map {|page| page.metadata('categories').split(",").map(&:strip) }
        .flatten
        .compact
        .each { |category| ccnt[category] += 1 }
        ccnt
      end # categories_cnt
    end # helpers

    # Add new routes here.
  end
end
