# CSS files
Rails.application.config.assets.precompile += %w( responsive/*)
Rails.application.config.assets.precompile += %w( fonts/*)
Rails.application.config.assets.precompile += %w( manage_clients,manage_users)

# JS files
Rails.application.config.assets.precompile += %w( admin/*)
Rails.application.config.assets.precompile += %w( role_permissions)

