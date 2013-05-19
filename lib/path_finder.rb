require "path_finder/version"

module PathFinder
 	def self.start!(options = {})
 		test = PathFinder::Test.new("Hello world")
 	end

 	class Test
 		def initialize(statement)
 			puts statement
 		end
 	end
end
