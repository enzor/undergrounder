WebFinder::App.controllers :tube_planner do
  
  get :index, :map => '/' do
    render 'tube_planner/index'
  end

  post :index, :map => "/" do
  	@result = begin
  		PathFinder.start!(params[:source], params[:destination], true)
  	rescue Exception => e
  		"Please insert a valid origin or destination ( origin was #{params[:origin]}, destination was #{params[:destination]})"
  	end

  	render 'tube_planner/index'
  end

end
