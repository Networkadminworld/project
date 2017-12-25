module CommandCenter
  class PostReview
    attr_reader :client_user_id, :service_user_id, :limit, :offset, :filter_by

    def initialize(client_user_id, service_user_id,limit,offset, filter_by)
      @client_user = User.where(id: client_user_id).first
      @service_user = User.where(id: service_user_id).first
      @limit = limit
      @offset = offset
      @filter_by = filter_by
    end

    def posts
      @client_user.present? && @service_user.nil? ? client_user_posts : service_user_posts
    end

    def service_user_posts
      pending_review_campaigns = filter_campaign_data(@client_user.campaigns).where(service_user_id: @service_user.id, status: 'WAITING_FOR_APPROVAL').
                                  limit(@limit.to_i).offset(@offset.to_i).order(:id => :desc)
      Campaign.campaign_collection(pending_review_campaigns)
    end

    def client_user_posts
      pending_review_campaigns = filter_campaign_data(@client_user.campaigns).where(status: 'WAITING_FOR_APPROVAL').
                                 limit(@limit.to_i).offset(@offset.to_i).order(:id => :desc)
      Campaign.campaign_collection(pending_review_campaigns)
    end

    def filter_campaign_data(campaigns)
      case @filter_by
        when 'MONTH'
          start_date = Date.today.beginning_of_month.strftime('%Y-%m-%d')
          end_date = Date.today.strftime('%Y-%m-%d')
          campaigns.where("to_char(created_at,'YYYY-MM-DD') >= ? AND to_char(created_at,'YYYY-MM-DD') <= ?",start_date,end_date)
        when 'WEEK'
          start_date = Date.today.beginning_of_week.strftime('%Y-%m-%d')
          end_date = Date.today.strftime('%Y-%m-%d')
          campaigns.where("to_char(created_at,'YYYY-MM-DD') >= ? AND to_char(created_at,'YYYY-MM-DD') <= ?",start_date,end_date)
        else
          campaigns
      end
    end

  end
end