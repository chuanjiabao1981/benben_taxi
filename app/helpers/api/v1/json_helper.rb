#encoding:utf-8
module Api
	module V1
		module JsonHelper
			JSON_PAGINATE_CURRENT_PAGE		=:current_page
			JSON_PAGINATE_PER_PAGE			=:per_page
			JSON_PAGINATE_TOTAL_ENTRIES		=:total_entries
			JSON_ERRORS 					=:errors
			JSON_WARNS 						=:warns
			JSON_ERRORS_BASE				=:base
			JSON_WARNS_BASE					=:base

			def json_response
				@_json_response ||= {}
			end

			def json_response=(o)
				@_json_response = o
			end
			def json_params_null_errors
				json_base_errors("参数不可为空!")
			end
			def json_errors(errors_data)
				json_response[JSON_ERRORS]=errors_data
				return json_response
			end
			def json_warns(warns_data)
				json_response[JSON_WARNS]=warns_data
			end
			def json_base_warns(base_warn_msg)
				json_warns({JSON_WARNS_BASE => [base_warn_msg]})
			end
			def json_base_errors(base_error_msg)
				return json_errors({ JSON_ERRORS_BASE => [ base_error_msg ]})
			end
			def json_add_data(key,value)
				json_response[key]=value
				return json_response
			end

			def json_merge_data(data)
				json_response.update(data)
				json_response
			end
			def paginate_info_json(collection)
				json_add_data(JSON_PAGINATE_CURRENT_PAGE,collection.current_page)
				json_add_data(JSON_PAGINATE_PER_PAGE,collection.per_page)
				json_add_data(JSON_PAGINATE_TOTAL_ENTRIES,collection.total_entries)
			end
			def json_response_ok
				json_add_data(:response,:ok)
			end
		end
	end
end