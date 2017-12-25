class Language < ActiveRecord::Base
has_many :client_languages
has_many :client_settings, :through => :client_languages

def self.get_all_languages
  self.all
end

def self.get_language_names(ids)
  if ids.blank?
   self.get_default_language
  else
  where("id in (?)",ids).pluck(:name)
  end
end

def self.get_default_language
  DEFAULTS["language"]
end

end
