require "spec_helper"

describe Feature do
   describe "#get_parent_features" do
		it { expect(Feature.get_parent_features).to eq(Feature.where(:parent_id => 0)) }
	end
   describe "#get_parent_features" do
		it { expect(Feature.last.sub_features).to eq(Feature.where(:parent_id => Feature.last.id)) }
	 end	
end