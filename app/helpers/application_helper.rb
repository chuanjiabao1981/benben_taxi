module ApplicationHelper
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
						action:["main::overview"],
						url: [:root],
						name: "概况",
						title: "系统概况"
					}
				]
			},
			{
				name: "司机",
				icon: "icon-desktop",
				actions:[
					{
						action:["zone_admin/users::index"],
						url: [:zone_admin,:users],
						name: "司机列表",
						title: "司机详细情况列表"
					},
					{
						action:["zone_admin/users::new"],
						url: [:new,:zone_admin,:user],
						name: "新增司机",
						title: "新增加出租车司机"
					}
				]
			},
			{
				name: "公司",
				icon: "icon-group",
				actions:[
					{
						action:["zone_admin/taxi_companies::index"],
						url:[:zone_admin,:taxi_companies],
						name: "公司列表",
						title: "出租车公司详细情况"
					},
					{
						action:["zone_admin/taxi_companies::new","zone_admin/taxi_companies::create"],
						url:[:new,:zone_admin,:taxi_company],
						name: "新增公司",
						title: "新增加公司"
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
	def action_match?(action)
		action[:action].include?("#{params[:controller]}::#{params[:action]}")
	end
	def group_match?(group)
		group[:actions].each do |a|
			if action_match?(a)
				return true
			end
		end
		false
	end
	def page_header(groups)
		g 	= nil
		a 	= nil
		g,a = current_group_and_action(groups)
		yield g,a
	end
	def bread_crumbs_actions(groups)
		g = nil
		a = nil
		g,a = current_group_and_action(groups)
		#默认第一个group的第一个action为首页
		#第一个boolean参数表示是否是第一级
		#第二个boolean参数表示是否是最后一级
		yield groups[0],true,false
		if side_bar_group_size(g) > 1
			yield g,false,false
			yield a,false,true
		else
			yield a,false,true
		end
	end
	def current_group_and_action(groups)
		g= nil
		a= nil
		groups.each do |group|
			g= group
			group[:actions].each do |action|
				if action_match?(action)
					a = action
					break
				end
			end
			break if a
		end
		[g,a]
	end
end
