class ScheduleType < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates :name, :uniqueness => {:scope => :user_id }

  has_many :schedule_slots, :dependent => :destroy
  serialize :schedule_days, Hash

  def self.all_list(user)
    collection = []
    s_types = where(user_id: user.id).order(id: :asc)
    s_types.each do |type|
      obj = {}
      obj[:id] = type.id
      obj[:name] = type.name
      obj[:is_active] = type.is_active
      obj[:schedule_days] = type.schedule_days
      obj[:schedule_slots] = []
      type.schedule_slots && type.schedule_slots.each do |slot|
        obj2 = {}
        obj2[:id] = slot.id
        obj2[:slot] = slot.slot
        obj2[:schedule_type_id] = slot.schedule_type_id
        obj[:schedule_slots] << obj2.stringify_keys!
      end
      collection << obj.stringify_keys!
    end
    collection
  end

  def self.update_active_days(params,user)
    type = where(id: params[:id], user_id: user.id).first
    if type
      type.update_attributes(schedule_days: merge_hashes(params[:schedule_days]))
      type.schedule_days
    end
  end

  def self.merge_hashes(days)
    list = []
    days.each { |day| list << {day["name"] => day["is_active"]} }
    list.reduce({}, :merge)
  end

  def self.update_status(params,user)
    type = where(id: params[:id], user_id: user.id).first
    if type && type.schedule_slots.count == 0
      { type: 'danger', msg: "Please add at-least one slot to use this." }
    elsif type && type.schedule_slots.count >= 1 && check_active_days(type.schedule_days) == 0
      { type: 'danger', msg: "There must be at-least one active day to use this." }
    elsif type && type.schedule_slots.count >= 1 && check_active_days(type.schedule_days) != 0
      where(user_id: user.id).update_all(is_active: false)
      type.update_attributes(is_active: true)
      { type: 'success', msg: "Your schedule has been updated" }
    end
  end

  def self.new_schedule(params,user)
    schedule = create(name: params[:name].downcase, user_id: user.id, is_active: false, schedule_days: merge_hashes(params[:schedule_days]))
    schedule.errors.try(:messages).blank? ? [] : { errors: schedule.errors.try(:messages) }
  end

  def self.check_active_days(days)
    count = 0
    days.each do |k, v|
      count += 1 if v
    end
    count
  end
end