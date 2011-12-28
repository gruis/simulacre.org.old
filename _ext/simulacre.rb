Dir[File.dirname(__FILE__) + "/simulacre/awestruct/extensions/*" ].each { |ext| require ext }
module Simulacre
  module Error; end
  class StandardError < ::StandardError;
    include Error;
    def to_s
      super + " (#{self.class})"
    end # to_s
  end
  class NotFoundError < StandardError; end
end
