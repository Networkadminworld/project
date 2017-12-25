module ControllerMacros

  def business_user(business_type_id= nil)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = business_type_id != nil ? FactoryGirl.create(:user,:default_biz_user,:business_type_id => business_type_id) : FactoryGirl.create(:user,:default_biz_user)
      sign_in :user, @user
    end
  end

  def subscribed_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user,:subscribed_biz_user)
      sign_in :user, @user
    end
  end
  def sub_end_with_seven_day(business_type_id= nil)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = business_type_id != nil ? FactoryGirl.create(:user,:sub_end_user,:business_type_id => business_type_id) : FactoryGirl.create(:user,:sub_end_user)
      sign_in :user, @user
    end
  end
  def subscribe_false_user(business_type_id = nil)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = business_type_id != nil ? FactoryGirl.create(:user,:subscribe_false_biz_user,:business_type_id => business_type_id) : FactoryGirl.create(:user,:subscribe_false_biz_user)
      sign_in :user, @user
    end
  end

  def subscribe_expired_user(business_type_id = nil)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = business_type_id != nil ? FactoryGirl.create(:user,:subscribe_expired_biz_user,:business_type_id => business_type_id) : FactoryGirl.create(:user,:subscribe_expired_biz_user)
      sign_in :user, @user
    end
  end

  def invalid_email_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.build(:user,:invalid_email_user_factory)
      @user.save(:validate => false)
      sign_in :user, @user
    end
  end
  def individual_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user,:default_user)
      sign_in @user
    end
  end

  def admin_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user,:admin_user)
      sign_in :user, @user
    end
  end

  # def business_user_with_auth_token
  #   before(:each) do
  #     @request.env["devise.mapping"] = Devise.mappings[:user]
  #     @biz_user_with_auth = FactoryGirl.create(:user,:default_biz_user)
  #     sign_in :user, @biz_user_with_auth
  #   end
  # end
end