require "simulacre"
require "disqus"

Awestruct::Extensions::Pipeline.new do
  extension Simulacre::Awestruct::Extensions::Posts.new('/posts')
  extension Awestruct::Extensions::Tagger.new(:pages, '/tag/index', '/tag', :per_page=>10 )
  extension Simulacre::Awestruct::Extensions::Categorizer.new(:pages, '/category/index', :per_page=>10 )
  extension Awestruct::Extensions::Indexifier.new
  extension Simulacre::Awestruct::Extensions::Archive.new
  extension Awestruct::Extensions::Disqus.new
  extension Awestruct::Extensions::Atomizer.new( :posts, '/feed/index.xml' )

  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::Tagger::TagLinker
  helper Awestruct::Extensions::GoogleAnalytics
end
