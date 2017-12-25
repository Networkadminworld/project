FactoryGirl.define do
	factory :tenant do
		name "coffe day"
		address "jayan nagar"
		client_id 1
		is_active true
	end
	factory :valid_tenant, :class => Tenant do
		name "forum mall"
		address "jayan nagar"
		client_id 1
		is_active true
	end	
	factory :invalid_tenant, :class => Tenant do
		name nil
		address "jayan nagar"
	end
	factory :tenant_inactive, :class => Tenant do
		name "KFC"
		address "jayan nagar"
		client_id 1
		is_active false
	end
end