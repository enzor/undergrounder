require "path_finder/version"
require 'yaml'


module PathFinder
 	def self.start!(source, destination)
 		test = PathFinder::Graph.new
 		test.load_from_yaml(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/tube_list.yml"))
 		test.print_shortest_paths(source, destination)
 	end
 	class Graph
 		attr_reader :graph, :nodes, :prev_station, :distance_modifier
		def initialize
			@graph = {}	 # the graph // {node => { edge1 => weight, edge2 => weight}, node2 => ...
			@nodes = Array.new		 
			@INFINITY = 1 << 64 
			@tube_list = []
		end
			
		def add_edge(source, target, weight, line) 	# s= source, t= target, w= weight
			if (not @graph.has_key?(source))	 
				@graph[source] = {target => [weight, [line]  ] }		 
			elsif(@graph[source].has_key?(target))
				@graph[source][target][1] << line
				@graph[source][target][1].uniq!
			else
				@graph[source][target] = [weight , [line] ]   
			end
			
			
			if (not @graph.has_key?(target))
				@graph[target] = {source => [weight, [line]] }
			elsif(@graph[target].has_key?(source))
				@graph[target][source][1] << line
				@graph[target][source][1].uniq!
			else
				@graph[target][source] = [weight, [line] ] 
			end



			if (not @nodes.include?(source))	
				@nodes << source
			end
			if (not @nodes.include?(target))
				@nodes << target
			end	
		end
		
		# based of wikipedia's pseudocode: http://en.wikipedia.org/wiki/Dijkstra's_algorithm
		
		def dijkstra(source)
			@distance = {}
			@prev = {}

			@nodes.each do |i|
				@distance[i] = @INFINITY
				@prev[i] = -1
			end	

			@distance[source] = 0
			q = @nodes.compact
			@modifier = 0;
			while q.size > 0
				u = nil;
				
				q.each do |min|
					if (not u) or (@distance[min] and @distance[min] < @distance[u])
						u = min
					end
				end

				if (@distance[u] == @INFINITY)
					break
				end
				q = q - [u]
				@graph[u].keys.each do |v| 
					current_line = @graph[u][v][1]
					if @distance[u] > 0
						modifier = changed_line?(@prev[u][1], current_line) == true ? 1 : 0
					else
						modifier = 0
					end

					alt = @distance[u] + @graph[u][v][0] + modifier
					
					if(alt < @distance[v])
						@distance[v] = alt
						@prev[v] = [u, current_line]
 					end
				end
			end
		end

		def changed_line?(previous_line, current_line)
			#puts "#{current_line} include #{previous_line} ? "
			previous_line.each do |line|
				if current_line.include?(line)
					return false
				end
			end
			return true
		end
		
		# To print the full shortest route to a node
		
		def print_path(dest)
			if @prev[dest] != -1
				print_path @prev[dest][0]
			end
			@tube_list << dest
		end
	

		def load_from_yaml(source)
			lines = YAML.load_file(source)
			lines.each do |line|
				stations = line[1]
				stations.each_with_index do |station,index|
					add_edge(station.keys[0], station.values[0], 1, line[0])
				end
			end
		end
		
		# Gets all shortests paths using dijkstra
		
		def shortest_paths(source, dest)
			@source = source
			dijkstra source
			print_path dest
			return @distance[dest]
		end

		def print_shortest_paths(source,dest)
			check_data_integrity(source, dest)
			total_distance = shortest_paths(source, dest)
			stations_changed = (total_distance - @tube_list.size) > 0 ? (total_distance - @tube_list.size) : 0;
			if total_distance != @INFINITY
				puts "Source: #{source}, Destination: #{dest}\n"
				puts "#{@tube_list.join(', ')}"
				puts "#{total_distance} #{@tube_list.size}"
				puts "\nDistance: #{total_distance}, you changed station #{stations_changed} times"
			else
				puts "NO PATH"
			end
		end

		def check_data_integrity(source, dest)
			station_list = @graph.map {|x| x.first}
			errors = []
			if !station_list.include?(source)
				errors << source
			end

			if !station_list.include?(dest)
				errors << dest
			end

			if errors.size > 0
				puts "The following stations were not found in the application: #{errors.join(",")}. Please, check your data."
				exit
			end
		end
	end
end
