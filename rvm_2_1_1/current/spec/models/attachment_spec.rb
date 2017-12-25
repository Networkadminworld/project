require "spec_helper"

describe Attachment do
  it { should belong_to(:attachable) }
  it { should have_attached_file(:image) }


  context "validation" do
    it "should have valid factory" do
      should validate_attachment_content_type(:image).allowing('image/jpg', 'image/jpeg', 'image/gif', 'image/png', 'image/pjpeg', 'image/x-png')
    end
  end
  
  describe "attach_user_profile" do
    it "should save user profile image" do
      user = FactoryGirl.create(:user, :default_biz_user)
      attachment = Attachment.attach_user_profile(user, "#{Rails.root}/spec/fixtures/img.jpg")
      expect(attachment).to eq(user.attachment)
    end
  end  
end