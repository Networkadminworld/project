require "spec_helper"

describe Language do
 
	it { should have_many(:client_languages) }
	it { should have_many(:client_settings).through(:client_languages) }
	
	it "it should get all languages" do
		expect(Language.get_all_languages).to eq(Language.all)
	end
	
	describe "get the language names" do
		it "pick the default language" do
			expect(Language.get_language_names("")).to eq(DEFAULTS["language"])
		end
		it "pick the default language" do
			language_id = Language.last.id
			Language.get_language_names([language_id])
		end		
	end
	
	it "it should get default language" do
		expect(Language.get_default_language).to eq(DEFAULTS["language"])
	end	
end	