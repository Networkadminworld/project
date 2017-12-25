module CommandCenter
  class PostRevision
    attr_reader :client_user_id, :service_user_id, :limit, :offset, :filter_by

    def initialize(client_user_id, service_user_id,limit,offset, filter_by)
      @client_user = User.where(id: client_user_id).first
      @service_user = User.where(id: service_user_id).first
      @limit = limit
      @offset = offset
      @filter_by = filter_by
    end

    def revisions
      @client_user.present? && @service_user.nil? ? client_user_posts : service_user_posts
    end

    def service_user_posts
      revisions = filter_revision_data(Revision.where(is_updated: false,created_by: @client_user.id, created_for: @service_user.id))
      Campaign.campaign_collection(Campaign.where(id: revisions.map(&:campaign_id)))
    end

    def client_user_posts
      revisions = filter_revision_data(Revision.where(is_updated: false,created_for: @client_user.id))
      Campaign.campaign_collection(Campaign.where(id: revisions.map(&:campaign_id)))
    end

    def filter_revision_data(revisions)
      case @filter_by
        when 'MONTH'
          start_date = Date.today.beginning_of_month.strftime('%Y-%m-%d')
          end_date = Date.today.strftime('%Y-%m-%d')
          revisions.where("to_char(created_at,'YYYY-MM-DD') >= ? AND to_char(created_at,'YYYY-MM-DD') <= ?",start_date,end_date).
              limit(@limit.to_i).offset(@offset.to_i).order(:id => :desc)
        when 'WEEK'
          start_date = Date.today.beginning_of_week.strftime('%Y-%m-%d')
          end_date = Date.today.strftime('%Y-%m-%d')
          revisions.where("to_char(created_at,'YYYY-MM-DD') >= ? AND to_char(created_at,'YYYY-MM-DD') <= ?",start_date,end_date).
              limit(@limit.to_i).offset(@offset.to_i).order(:id => :desc)
        else
          revisions.limit(@limit.to_i).offset(@offset.to_i).order(:id => :desc)
      end
    end

  end
end