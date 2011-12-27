Encoding.default_internal = Encoding.default_external = "UTF-8"
Dir[File.dirname(__FILE__) + "/simulacre/awestruct/extensions/*" ].each { |ext| require ext }

Awestruct::Extensions::Pipeline.new do
  extension Simulacre::Awestruct::Extensions::Posts.new('/posts')
  extension Awestruct::Extensions::Tagger.new( :posts, '/index', '/tags', :per_page=>10 )
  extension Awestruct::Extensions::Indexifier.new

  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::GoogleAnalytics
end
