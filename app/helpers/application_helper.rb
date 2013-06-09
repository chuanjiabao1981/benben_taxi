module ApplicationHelper
  include Rails.application.routes.url_helpers


	def delete_link(o)
	link_to I18n.t('views.text.destroy'), 
			o, 
			method: :delete, 
			confirm: t('views.text.confirm',:model => t("activerecord.models.#{o.class.to_s.underscore}"))
	end
	def action_groups
		@_action_groups ||=[
			{
				name: "首页",
				icon: "icon-dashboard",
				url: [:root],
				actions: [
					{
						action:"main::overview",
						url: [:root],
						name: "首页"
					}
				]
			},
			{
				name: "司机",
				icon: "icon-desktop",
				actions:[
					{
						action:"zone_admin/users::index",
						url: [:zone_admin,:users],
						name: "司机列表"
					},
					{
						action:"zone_admin/users::new",
						url: [:new,:zone_admin,:user],
						name: "新增司机"
					}
				]
			}
		]
	end
	def side_bar_group_actions(group)
		group[:actions].each do |a|
			if true
				yield a
			end
		end
	end
	def side_bar_group_size(group)
		return group[:actions].size if group[:actions]
		return 0
	end
	def side_bar_action_match?(action)
		action[:action] == "#{params[:controller]}::#{params[:action]}" 
	end
	def side_bar_group_match?(group)
		group[:actions].each do |a|
			Rails.logger.debug("#{params[:controller]}::#{params[:action]}")
			if a[:action] == "#{params[:controller]}::#{params[:action]}" 
				return true
			end
		end
		false
	end
end
