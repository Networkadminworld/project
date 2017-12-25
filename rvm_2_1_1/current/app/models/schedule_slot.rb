class ScheduleSlot < ActiveRecord::Base
  belongs_to :schedule_type
  validates :slot, :uniqueness => {:scope => :schedule_type_id }

  def self.add(params)
    hour = params[:slot].split(":").first
    params[:slot] = params[:slot].gsub(hour, "0#{hour}")
    status = create(slot: params[:slot], schedule_type_id: params[:schedule_type_id])
    status.errors.try(:messages).blank? ? fetch_all_slots(params[:schedule_type_id]) : { errors: status.errors.try(:messages) }
  end

  def self.remove(params)
    slot = where(id: params[:id], schedule_type_id: params[:schedule_type_id]).first
    status = slot ? slot.destroy : false
    fetch_all_slots(params[:schedule_type_id]) if status
  end

  def self.fetch_all_slots(type_id)
    list  = []
    slots = where(schedule_type_id: type_id)
    slots.each do |slot|
      obj = {}
      obj[:id] = slot.id
      obj[:slot] = slot.slot
      obj[:schedule_type_id] = slot.schedule_type_id
      list << obj.stringify_keys!
    end
    list
  end
end