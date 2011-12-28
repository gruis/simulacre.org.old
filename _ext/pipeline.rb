Dir[File.dirname(__FILE__) + "/simulacre/awestruct/extensions/*" ].each { |ext| require ext }

Awestruct::Extensions::Pipeline.new do
  extension Simulacre::Awestruct::Extensions::Posts.new('/posts')
  extension Awestruct::Extensions::Tagger.new(:posts, '/tag/index', '/tag', :per_page=>10 )
  extension Simulacre::Awestruct::Extensions::Categorizer.new(:posts, '/index', '/category', :per_page=>10 )
  extension Awestruct::Extensions::Indexifier.new
  extension Simulacre::Awestruct::Extensions::GroupPosts.new

  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::Tagger::TagLinker
  helper Awestruct::Extensions::GoogleAnalytics
end
