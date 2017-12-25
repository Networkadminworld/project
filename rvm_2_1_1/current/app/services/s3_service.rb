require 'aws-sdk-v1'
require 'aws-sdk'

class S3Service

	def initialize access_key=ENV['AWS_ACCESS_KEY_ID'], secret_key=ENV['AWS_SECRET_ACCESS_KEY'], region=ENV['AWS_REGION']
    @identity = Aws::CognitoIdentity::Client.new(access_key_id: access_key,secret_access_key: secret_key, region: region)
  end

  def get_config(params)
    s3_config = S3Config.where(identity_type: params[:type]).first
    if s3_config
      identity_id = s3_config.identity_name
      identity_pool_id = s3_config.identity_pool_name
    else
      resp = @identity.create_identity_pool({identity_pool_name: params[:pool_name],allow_unauthenticated_identities: true })
      resp2 = @identity.get_id({ account_id: ENV['AWS_ACCOUNT'],identity_pool_id: resp.identity_pool_id })
      S3Config.find_or_initialize_by(identity_type: params[:type])
        .update_attributes!(identity_type: params[:type], identity_name: resp2.identity_id, identity_pool_name: resp.identity_pool_id)
      identity_id = resp2.identity_id
      identity_pool_id = resp.identity_pool_id
    end
    {:awsToken => ENV['AWS_ACCESS_KEY_ID'],:awsSecret => ENV['AWS_SECRET_ACCESS_KEY'], :identityId => identity_id, identityPoolId: identity_pool_id, :s3BucketName => ENV['AWS_BUCKET']}
  end
end