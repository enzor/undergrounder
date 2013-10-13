require 'rubygems'
require 'mechanize'
require 'yaml'

module TubeScraper
	def self.start!
		@agent = Mechanize.new
		@agent.get('http://tubephotos.dannycox.me.uk/stationsbyline.html'); # page fetching
		tube_name_list, final_list = [], []
		@agent.page.search('.style5').each {|x| tube_name_list << x.first[1]} # we search through all the occurrence of the class that holds station names..
		tube_name_list.uniq!.sort! #then tidy up the array and sort alphabetically

		stations = @agent.page.search('.stationList')
		stations.each do |element|
			children = element.elements.children;
			temp_tube_list, temp_list = [], []
			children.each_with_index do |x, i| # for every station object we..
				value = x.text.split("\n").join(" ") # ..remove carriages inside the name.
					.gsub("  "," ") # ...remove double unaestetic double spaces
					.gsub("&", "and") # ...change the & to and, to better hand data in yaml
					.gsub(/\(([^\)]+)\)/,'').rstrip # ...remove everything is between parentheses. 
				if(value != "")
					temp_list << value
				end
			end 

			# Having obtained a clear list of the tube stations, we create
			# a series of { source => target } hashes
			temp_list.each_with_index do |prov,index| 
				if index + 1 < temp_list.size
					temp_tube_list << { prov => temp_list[index+1] }
				end
			end


			final_list << temp_tube_list if temp_tube_list.size > 0

		end

		# Once we have all the station connections, we push the line name
		# at the beginning of every array.
		final_list.each_with_index do |lines,index|
			lines.unshift(tube_name_list[index].gsub("&","and"))
		end

		#and we finally save it!
		File.open(Dir.pwd + "/tube_list2.yml", 'w+') {|f| f.write(final_list.to_yaml) }
	end

end


