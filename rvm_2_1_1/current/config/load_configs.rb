class MimicUnlimited
def self.max_value
 n_bytes = [42].pack('i').size
 n_bits = n_bytes * 8
 max = (2 ** (n_bits - 2) - 1) + 1
 end
end

COLUMN_NAME = YAML.load_file("config/column_settings.yml")
$unlimited = MimicUnlimited.max_value
PLAN = YAML.load(ERB.new(File.read("config/plan_details.yml")).result)
OMNIAUTH_KEYS = YAML.load(ERB.new(File.read("config/omniauth.yml")).result)[::Rails.env]
BITLY_URL = YAML.load(ERB.new(File.read("config/custom.yml")).result)[::Rails.env]
APP_MSG = YAML.load_file("config/notification_message.yml")
DEFAULTS = YAML.load(ERB.new(File.read("config/default_values.yml")).result)
PERMISSIONS = YAML.load(ERB.new(File.read("config/permissions.yml")).result)
METHOD_ACC_LEVEL = YAML.load(ERB.new(File.read("config/method_access_level.yml")).result)
FEATURE_PERMISSIONS = YAML.load(ERB.new(File.read("config/feature_permissions.yml")).result)
DISTRIBUTE_PLAN = YAML.load(ERB.new(File.read("config/distribute_plan_details.yml")).result)