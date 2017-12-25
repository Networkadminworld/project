class ExecutiveBusinessMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  def company_name
    Company.where(id: self.company_id).first.try(:name)
  end
end