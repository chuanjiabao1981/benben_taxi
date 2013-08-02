class ClientExceptionsController < ApplicationController
	def index
		params[:page] ||=1
		@client_exceptions = ClientException.paginate(:page => params[:page])
	end
end
