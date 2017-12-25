class Revision < ActiveRecord::Base

  def self.save_campaign_revision(params)
    create(content: params[:reason], is_updated: false, campaign_id: params[:inq_campaign_id], created_by: params[:publisher_id],created_for: params[:servicer_id])
  end

  def self.find_revision_notes(params)
    revisions = where(campaign_id: params[:campaign_id], is_updated: false)
    notes = []
    revisions.each do |revision|
      notes << {comment: revision.content }
    end
    notes
  end
end