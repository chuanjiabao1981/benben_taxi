class ZoneAdmin::PassengersController < ApplicationController
	def index
		params[:page] ||=1
		@passengers = User.where(:role => User::ROLE_PASSENGER).paginate(:page => params[:page])
	end
	def new
		@passenger = User.build_passenger_with_no_verify
	end
	def create
		@passenger = User.build_passenger_with_no_verify(params[:user])
		if @passenger.save
			flash[:notice] = "成功创建乘客 #{@passenger.name}!"
			return redirect_to url_for(zone_admin_passengers_path)
		else
			Rails.logger.debug(@passenger.errors)
			render 'new'
		end
	end
	def edit
		@passenger = current_resource
	end
	def update
		@passenger = current_resource
		if @passenger.update(params[:user])
			flash[:notice] = "成功更新 #{@passenger.name} 信息!"
			return redirect_to url_for([:zone_admin,:passengers])
		else
			render 'edit'
		end
	end
	def destroy
		@passenger=current_resource
		@passenger.destroy
		flash[:notice] = "成功删除 #{@passenger.name}!"
		return redirect_to url_for([:zone_admin,:passengers])
	end
	private 
		def current_resource
			@current_resource ||= User.find_by(id:params[:id],role: User::ROLE_PASSENGER) if params[:id]
		end
end
