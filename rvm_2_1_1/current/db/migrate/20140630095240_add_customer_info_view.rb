class AddCustomerInfoView < ActiveRecord::Migration
  def up
#   	    execute %{create VIEW customer_detail_summaries as SELECT row_number() OVER () AS id,COALESCE(bc.id, rc.id) AS customer_id,
#        vw.question_id AS question_id,
#        qs.user_id as user_id,
#        qs.question as question,
#        COALESCE(vw.cookie_token_id, rc.cookie_token_id) AS cookie_token_id,
#        (date(vw.created_at) - ('#{DEFAULTS['norm_date']}') + 1 ) AS viewed_norm_date,
#        (date(re.created_at) - ('#{DEFAULTS['norm_date']}') + 1 ) AS responded_norm_date,
#         tn.name as tenant_name,
#         qs.tenant_id as tenant_id,
#         vw.created_at as viewed_at,
#         re.created_at as responded_at,
#        COALESCE(bc.country, rc.country) AS country,
#               COALESCE(bc.state, rc.state) AS state,
#        COALESCE(bc.city, rc.city) AS city,
#        COALESCE(bc.area, rc.area) AS area,
# COALESCE(bc.customer_name, rc.customer_name) AS name,
# COALESCE(bc.email, rc.email) AS email,
# COALESCE(bc.mobile, rc.mobile) AS mobile,
# COALESCE(bc.age, rc.age) AS age,
# COALESCE(bc.gender, rc.gender) AS gender,
#        COALESCE(re.provider, vw.provider) AS provider,
#        qs.created_at AS question_created_at,
#        CASE
#            WHEN re.id IS NOT NULL THEN 'YES'
#            ELSE 'NO'
#        END AS is_responded
# FROM question_view_logs vw
# INNER JOIN questions qs ON vw.question_id = qs.id
# FULL OUTER JOIN tenants tn on qs.tenant_id = tn.id
# FULL OUTER JOIN question_response_logs re ON vw.cookie_token_id = re.cookie_token_id
# FULL OUTER JOIN business_customer_infos bc ON bc.cookie_token_id = COALESCE(re.cookie_token_id , vw.cookie_token_id)
# FULL OUTER JOIN response_customer_infos rc ON rc.cookie_token_id = COALESCE(re.cookie_token_id , vw.cookie_token_id) where vw.question_id = qs.id}
  end

    def down
    execute "drop view customer_details;"
  end


end
