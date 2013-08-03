class ClientExceptionsController < ApplicationController
	def index
		params[:page] ||=1
		@client_exceptions = ClientException.paginate(:page => params[:page])
	end
	def show
		@client_exception  = @current_resource
	end
	private 
		def current_resource
			@current_resource = ClientException.find(params[:id]) if params[:id]
		end
end
