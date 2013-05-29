#encoding:utf-8
module Api
  class ApiController < ActionController::Base
    include ::SessionsHelper
    include Api::V1::JsonHelper
    include Api::V1::SessionsHelper
    protect_from_forgery
    before_action :authorize
  
    delegate :allow?, to: :current_permission
    
    delegate :allow_param?, to: :current_permission
  
    #把当前的tenant,传递给Tenant.current_id
    #后续的Controller，Model，和View可以使用
    around_action :scope_current_tenant
  
    skip_before_action  :verify_authenticity_token

  
    private 
    	def current_permission
    	  @current_permission ||= Permissions.permission_for(current_user)
    	end
    	def current_resource
    	  nil
    	end
    	def authorize
    	  if current_permission.allow?(params[:controller], params[:action], current_resource)
          s=current_permission.permit_params! params
        else  
          return render json:json_base_errors(I18n.t('views.text.unauthorized'))
    	  end
    	end
      def current_tenant
        return current_user.tenant if current_user 
      end
      def scope_current_tenant 
        Tenant.current_id = current_tenant.nil? ? nil : current_tenant.id
        yield
      ensure
        Tenant.current_id = nil 
      end
  end
end