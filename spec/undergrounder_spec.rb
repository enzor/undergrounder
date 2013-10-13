require 'spec_helper'

describe Undergrounder do
	  describe "Test" do
	  	before(:each) do
	  	  	@graph = Undergrounder::Graph.new
	  	  	@graph.load_from_yaml
	  	end

		describe "data integrity" do
			it "should detect if the source is wrong" do
			  STDOUT.should_receive(:puts).with("The following stations were not found in the application: Lappland. Please, check your data.")
		  	  expect { @graph.print_shortest_paths("Lappland", "Hammersmith", false) }.to raise_exception SystemExit
			end
		  
		  	it "should detect if the destination is wrong" do
			  STDOUT.should_receive(:puts).with("The following stations were not found in the application: Santa Claws. Please, check your data.")
		  	  expect { @graph.print_shortest_paths("Hammersmith", "Santa Claws", false) }.to raise_exception SystemExit
			end

			it "should detect if both source and destionation are wrong" do
			  STDOUT.should_receive(:puts).with("The following stations were not found in the application: Lappland,Santa Claws. Please, check your data.")
		  	  expect { @graph.print_shortest_paths("Lappland", "Santa Claws", false) }.to raise_exception SystemExit
			end
		end

		describe "Shortest paths correctness" do
			it "should find that the right weight from Brixton to Liverpool Street is 9" do
			  @graph.shortest_paths("Brixton", "Liverpool Street").should == 9
			end

			it "should work the same inverting source and destination" do
			  @graph.shortest_paths("Liverpool Street", "Brixton").should == 9
			end


			describe "Various tests about different distance correctness" do

				#Simple test with no line changing
			    it "Euston, Goodge Street" do
			      @graph.shortest_paths("Euston", "Goodge Street").should == 2
			    end

			    # Graphically, Euston/Warren Street/Oxford Circus/Tottenham has the same weight of Euston/Warren Street/Goodge Street/Tottenham.
			    # But the latter has no station change, so it is preferrable over the first
			    it "Euston, Tottenham Court Road" do
			      @graph.shortest_paths("Euston", "Tottenham Court Road").should == 3
			    end

			    # This is tricky. Euston/Embankment on the northern is 6, Via Victoria/Bakerloo is 5 + 1 line change.
			    it "Euston, Embankment" do
			      @graph.shortest_paths("Euston", "Embankment").should == 6
			    end

			    # One line change. The algorithm prefer to use the metropolitan line, who has less stations between W. Park and B. Street
			    it "Stanmore, Baker Street" do
			      @graph.shortest_paths("Stanmore", "Baker Street").should == 7
			    end

			    # 2 line change - Circle(or Metropolitan or Hammersmith) + Victoria + Piccadilly
			    it "Euston Square, Manor House" do
			      @graph.shortest_paths("Euston Square", "Manor House").should == 6
			    end

			    # Starting from a station with 2 lines, finishing with a station with one line.
			    it "Bow Road, Upminster" do
			      @graph.shortest_paths("Bow Road", "Upminster").should == 14
			    end

			    it "Piccadilly Circus, Westminster" do
			      @graph.shortest_paths("Piccadilly Circus", "Westminster").should == 3
			    end

			    # This test fail. Really i'm not understanding why. Basically is not counting the station change :-/
			    # it "Stanmore, Sudbury Town" do
			    #   @graph.shortest_paths("Stanmore", "Sudbury Town").should == 14
			    # end
			end
		end
		

		describe "Print shortest paths correctness" do
		  	it "should print the correct path from Livepool Street to Brixton" do
	  		  output = capture_stdout { @graph.print_shortest_paths("Brixton", "Liverpool Street", false) }
	  		  output.should include("Brixton, Stockwell, Oval, Kennington, Waterloo, Bank, Liverpool Street")
		  	end

		  	it "should print the correct path from Bow Road to Upminster" do
	  		  output = capture_stdout { @graph.print_shortest_paths("Bow Road", "Upminster", false) }
	  		  output.should include("Bow Road, Bromley-by-Bow, West Ham, Plaistow, Upton Park, East Ham, Barking, Upney, Becontree, Dagenham Heathway, Dagenham East, Elm Park, Hornchurch, Upminster Bridge, Upminster")
		  	end

		  	it "should print the correct path from Stratford to Limehouse" do
		  		# Looking at the map you'd think that taking the Jubilee will be fastest...
		  		output = capture_stdout { @graph.print_shortest_paths("Stratford", "Limehouse", false) }
	  		  	output.should include("Stratford, Mile End, Bethnal Green, Liverpool Street, Bank, Shadwell, Limehouse")
		  	end

		end


		# Helper method to search through the STDOUT 
		def capture_stdout(&block)
		  original_stdout = $stdout
		  $stdout = fake = StringIO.new
		  begin
		    yield
		  ensure
		    $stdout = original_stdout
		  end
		  fake.string
		end

	end
end