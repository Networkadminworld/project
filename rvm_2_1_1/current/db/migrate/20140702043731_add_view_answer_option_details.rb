class AddViewAnswerOptionDetails < ActiveRecord::Migration
  def up
#   	execute %{create view answer_option_details as  SELECT row_number() OVER () AS id,COALESCE(bc.id, rc.id) AS customer_id,qs.id AS question_id,
#        qs.user_id as user_id,
#        tn.name as tenant_name,
#        tn.id as tenant_id,
#        COALESCE(bc.country, rc.country) AS country,
#        re.cookie_token_id AS cookie_token_id,
# COALESCE(bc.customer_name, rc.customer_name) AS name,
# COALESCE(bc.email, rc.email) AS email,
# COALESCE(bc.mobile, rc.mobile) AS mobile,
# COALESCE(bc.age, rc.age) AS age,
#               COALESCE(bc.state, rc.state) AS state,
#        COALESCE(bc.city, rc.city) AS city,
#        COALESCE(bc.area, rc.area) AS area,
# COALESCE(bc.gender, rc.gender) AS gender,
#   re.provider as provider,
#        re.created_at AS responded_at,ans.option
# FROM questions qs
# inner JOIN answers ans on ans.question_id  = qs.id
# FULL OUTER JOIN tenants tn on qs.tenant_id = tn.id
# FULL OUTER JOIN question_response_logs re ON re.cookie_token_id = ans.uuid
# FULL OUTER JOIN business_customer_infos bc ON bc.cookie_token_id = re.cookie_token_id
# FULL OUTER JOIN response_customer_infos rc ON rc.cookie_token_id = re.cookie_token_id where ans.question_id = qs.id and ans.is_other is false and ans.comments is null and re.question_id = qs.id}
  end
  def down
    execute "drop view answer_option_details;"
  end
end
