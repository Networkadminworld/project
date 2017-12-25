require 'fileutils'
class QrCode < ActiveRecord::Base
  extend FriendlyId

  has_many :user_location_channels, as: :channel, :dependent => :destroy
  belongs_to :user
  validates_presence_of :name
  validates :name, :uniqueness => {:scope => :user_id }
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix,:multiline => true, :if => Proc.new { |q| !q.url.blank? }
  has_attached_file :image,
                    :styles => { medium: "300x300>", thumb: "100x100>" },
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    }
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  after_create :update_location_channels, :update_short_url

  friendly_id :slug, use: :slugged

  before_create :generate_unique_slug_key

  def self.list(params, user)
    collection = {}
    collection["qrcode_list"] = []
    qr_codes = where(user_id: user.id, is_default: false).paginate(:page => params[:page],:per_page => params[:per_page]).order('id DESC')
    qr_codes.each do |qr_code|
      qr_obj = {
          :id => qr_code.id,
          :name => qr_code.name,
          :short_url => qr_code.short_url,
          :url => (qr_code.url.blank? || qr_code.url.nil?) ? "http://ezeees.com" : qr_code.url,
          :status => qr_code.status,
          :user_id => qr_code.user_id,
          :image => qr_code.image.url
      }
      collection["qrcode_list"] << qr_obj
    end
    collection["num_results"] = where(user_id: user.id).count
    collection
  end

  def self.create_new(params,user)
    is_active = params[:url].blank? ? false : true
    qr_code = create(name: params[:name], url: params[:url], status: true, is_default: false, user_id: user.id, is_active: is_active)
    qr_code.errors.try(:messages).blank? ? [] : { errors: qr_code.errors.try(:messages) }
  end

  def self.update_details(params,user)
    qr_code = where(id: params[:id], is_default: false, user_id: user.id).first
    is_active = qr_code.url != params[:url] ? true : qr_code.is_active
    is_updated = qr_code.update_attributes(name: params[:name], url: params[:url],is_active: is_active)
    update_qr_campaigns(qr_code) if is_active && is_updated
    is_updated ? [] : { errors: qr_code.errors.try(:messages) }
  end

  def self.update_qr_campaigns(qr_code)
    QrCodeCampaign.where(qr_code_id: qr_code).update_all(is_active: false)
  end

  def self.update_status(params,user)
    where(id: params[:id], user_id: user.id).first.update(status: params[:status])
  end

  private

  def update_short_url
    redirect_url = "#{ENV['CUSTOM_URL']}configurations/#{self.slug}"
    img_path = "#{Rails.root}/public/qrcode/images/#{self.user_id}_qrcodes"
    FileUtils.mkdir_p img_path unless File.directory?(img_path)
    qr_code = RQRCode::QRCode.new(redirect_url)
    qr_code.as_png(resize_gte_to: false, resize_exactly_to: false, fill: 'white', color: 'black', size: 300,
        border_modules: 4, module_px_size: 6,file: "#{img_path}/#{self.id}.png")
    self.update_attributes(short_url: BitLyService.new.shorten({url: redirect_url, secret: ENV['SHORTEN_SECRET']})["short_url"], image: upload_object("#{img_path}/#{self.id}.png"))
  end

  def upload_object(img_path)
    temp_path = File.new(img_path)
    ActionDispatch::Http::UploadedFile.new(tempfile: temp_path, filename: File.basename(temp_path), type: "image/png")
  end

  def update_location_channels
    UserLocationChannel.create(channel_id: self.id, channel_type: self.class.name, user_id: self.user_id)
  end

  protected

  def generate_unique_slug_key
    self.slug = loop do
      random_generate_id = SecureRandom.hex
      break random_generate_id unless self.class.exists?(slug: random_generate_id)
    end
  end
end
