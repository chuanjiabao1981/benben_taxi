module ApplicationHelper

	def delete_link(o)
	link_to I18n.t('views.text.destroy'), 
			o, 
			method: :delete, 
			confirm: t('views.text.confirm',:model => t("activerecord.models.#{o.class.to_s.underscore}"))
	end
end
