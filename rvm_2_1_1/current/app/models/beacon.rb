class Beacon < ActiveRecord::Base

  has_many :user_location_channels, as: :channel
  belongs_to :user
  validates_presence_of :uid
  validates :uid, :uniqueness => {:scope => :user_id }
  validates :name, :uniqueness => {:scope => :user_id }
  after_create :update_location_channels
  after_destroy :remove_location_channels

  def self.list(params, user)
    collection = {}
    collection["beacons_list"] = []
    beacons = where(user_id: user.id).paginate(:page => params[:page],:per_page => params[:per_page]).order('id DESC')
    collection["beacons_list"] << beacons.to_json
    collection["num_results"] = where(user_id: user.id).count
    collection
  end

  def self.create_new(params,user)
    beacon = create(uid: params[:uid], name: params[:name], status: true, user_id: user.id)
    beacon.errors.try(:messages).blank? ? [] : { errors: beacon.errors.try(:messages) }
  end

  def self.update_status(params,user)
    where(id: params[:id], user_id: user.id).first.update(status: params[:status])
  end

  def self.update_details(params,user)
    beacon = where(id: params[:id], user_id: user.id).first
    status = beacon.update_attributes(uid: params[:uid], name: params[:name])
    status ? [] : { errors: beacon.errors.try(:messages)}
  end

  private

  def update_location_channels
    UserLocationChannel.create(channel_id: self.id, channel_type: self.class.name, user_id: self.user_id)
  end

  def remove_location_channels
    UserLocationChannel.destroy(channel_id: self.id, channel_type: self.class.name, user_id: self.user_id)
  end
end