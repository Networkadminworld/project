module CommandCenter
  class PlannerDetail
	  attr_reader :client_user_id, :service_user_id, :is_service_user, :time_zone

    def initialize(client_user_id, service_user_id,is_service_user,current_date,time_zone)
      @client_user = User.where(id: client_user_id).first
      @service_user = User.where(id: service_user_id).first
      @is_service_user = is_service_user.present?
      current_date = Date.parse(current_date).in_time_zone(time_zone)
      @time_zone = current_date.strftime('%Z')
      @begin_date = current_date.beginning_of_month
      @end_date = current_date.end_of_month
    end
	
    def planner_details
      @client_user.present? && @service_user.nil? ? client_user_results : service_user_results
    end

    def service_user_results
      campaign_ids = @client_user.campaigns.where(service_user_id: @service_user.id).map(&:id)
      @scheduled_campaigns = Delayed::Job.where("to_char(run_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') >= ? AND to_char(run_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') <= ?",@begin_date.strftime("%Y-%m-%d %H:%M %Z"),@end_date.strftime("%Y-%m-%d %H:%M %Z")).where(campaign_id: campaign_ids,failed_at: nil)
      @pending_review_campaigns = @client_user.campaigns.where("to_char(updated_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') >= ? AND to_char(updated_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') <= ?",@begin_date.strftime("%Y-%m-%d %H:%M %Z"),@end_date.strftime("%Y-%m-%d %H:%M %Z")).where(service_user_id: @service_user.id, status: 'WAITING_FOR_APPROVAL')
      @revisions = Revision.where("to_char(created_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') >= ? AND to_char(created_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') <= ?",@begin_date.strftime("%Y-%m-%d %H:%M %Z"),@end_date.strftime("%Y-%m-%d %H:%M %Z")).where(created_by: @client_user.id, created_for: @service_user.id, is_updated: false)
      s_event_count,s_event = schedule_events
      review_count,review_event = pending_reviews
      r_count, r_event = revisions
      { scheduled_count: s_event_count, review_count: review_count, is_service_user: @is_service_user, revision_count: r_count, event_source: [s_event,review_event,r_event]}
    end

    def client_user_results
      campaign_ids = @client_user.campaigns.map(&:id)
      @scheduled_campaigns = Delayed::Job.where("to_char(run_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') >= ? AND to_char(run_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') <= ?",@begin_date.strftime("%Y-%m-%d %H:%M %Z"),@end_date.strftime("%Y-%m-%d %H:%M %Z")).where(user_id: @client_user.id,campaign_id: campaign_ids,failed_at: nil)
      @pending_review_campaigns = @client_user.campaigns.where("to_char(updated_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') >= ? AND to_char(updated_at::timestamp at time zone '#{@time_zone}','YYYY-MM-DD HH24:MI TZ') <= ?",@begin_date.strftime("%Y-%m-%d %H:%M %Z"),@end_date.strftime("%Y-%m-%d %H:%M %Z")).where(status: 'WAITING_FOR_APPROVAL')
      s_event_count,s_event = schedule_events
      review_count,review_event = pending_reviews
      { scheduled_count: s_event_count, review_count: review_count, is_service_user: @is_service_user, revision_count: 0, event_source: [s_event,review_event]}
    end

    def schedule_events
      event_checked = []
      days = Hash.new(0)
      event_days = []
      scheduled_count = 0
      scheduled_events = {:color => '#82C7CA', :textColor => 'white', :events => []}
      @scheduled_campaigns.each do |dj|
        unless event_checked.include?(dj.campaign_id)
          event_days << dj.run_at.strftime("%Y-%m-%d")
          event_checked << dj.campaign_id
          scheduled_count += 1
        end
      end
      event_days.each { |day| days[day] += 1 }
      days.each { |start,title| scheduled_events[:events] << convert_integer_values({:title => title, :start => start })}
      [scheduled_count,scheduled_events]
    end

    def pending_reviews
      days = Hash.new(0)
      event_days = []
      pending_review_count = 0
      pending_review_events = {:color => '#E95C4D', :textColor => 'white', :events => []}
      @pending_review_campaigns.each do |campaign|
          event_days << campaign.updated_at.strftime("%Y-%m-%d")
          pending_review_count += 1
      end
      event_days.each { |day| days[day] += 1 }
      days.each { |start,title| pending_review_events[:events] << convert_integer_values({:title => title, :start => start })}
      [pending_review_count,pending_review_events]
    end

    def revisions
      days = Hash.new(0)
      event_days = []
      revision_count = 0
      revision_events = {:color => '#F5A623', :textColor => 'white', :events => []}
      @revisions.each do |revision|
        event_days << revision.created_at.strftime("%Y-%m-%d")
        revision_count += 1
      end
      event_days.each { |day| days[day] += 1 }
      days.each { |start,title| revision_events[:events] << convert_integer_values({:title => title, :start => start })}
      [revision_count,revision_events]
    end

    private

    def convert_integer_values(values)
      { :title => values[:title].to_s, :start => values[:start]}
    end
  end
end