class ClientExceptionsController < ApplicationController
	def index
		params[:page] ||=1
		@client_exceptions = ClientException.order("created_at desc").paginate(:page => params[:page])
	end
	def show
		@client_exception  = @current_resource
	end
	def destroy
		@current_resource.destroy
		flash[:notice] = "成功删!"
		return redirect_to url_for(@current_resource)
	end
	private 
		def current_resource
			@current_resource = ClientException.find(params[:id]) if params[:id]
		end
end
