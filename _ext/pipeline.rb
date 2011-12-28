require "simulacre"

Awestruct::Extensions::Pipeline.new do
  extension Simulacre::Awestruct::Extensions::Posts.new('/posts')
  extension Awestruct::Extensions::Tagger.new(:posts, '/tag/index', '/tag', :per_page=>10 )
  extension Simulacre::Awestruct::Extensions::Categorizer.new(:posts, '/category/index', :per_page=>10 )
  extension Awestruct::Extensions::Indexifier.new
  extension Simulacre::Awestruct::Extensions::Archive.new

  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::Tagger::TagLinker
  helper Awestruct::Extensions::GoogleAnalytics
end
