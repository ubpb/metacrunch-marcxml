require "metacrunch"
require "ox"
require "htmlentities"

begin
  require "pry"
rescue LoadError ; end

module Metacrunch
  module Mab2
    require_relative "./mab2/version"
    require_relative "./mab2/document"
    require_relative "./mab2/cli"
    require_relative "./mab2/builder"
  end
end
