require 'valid_email'
class User < ActiveRecord::Base
  include FlagShihTzu
  geocoded_by :address
  has_flags 1 => :completed_survey

  include RailsSettings::Extend

  USER_TYPES = {"PATIENT" => "I am a Patient",
                "CARETAKER" => "I am a Care Taker or Family member of a Patient",
                "OTHER" => "None of the Above"}
  TRACKING_EMAIL_TYPES = {'never' => 1, 'daily' => 2, 'weekly' => 3}

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :omniauthable, authentication_keys: [:login]

  has_one :referral, dependent: :destroy
  has_one :well_being, dependent: :destroy

  has_many :answers
  has_many :user_conditions, dependent: :destroy
  has_many :conditions, through: :user_conditions
  has_many :symptoms, dependent: :destroy
  has_many :symptom_summaries, through: :symptoms
  has_many :sub_categories, through: :symptom_summaries
  has_many :categories, through: :sub_categories
  has_many :treatments, dependent: :destroy
  has_many :following_users, class_name: "UserFollower", foreign_key: :followed_user_id, dependent: :destroy
  has_many :followed_users, class_name: "UserFollower", foreign_key: :following_user_id, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :helpfuls, dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :to_user_id, dependent: :destroy
  has_many :sent_messages, class_name: "Message", foreign_key: :from_user_id, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :from_user_id, dependent: :destroy
  has_many :received_notifications, class_name: "Notification", foreign_key: :to_user_id, dependent: :destroy
  has_many :patient_matches, foreign_key: :from_user_id, dependent: :destroy
  has_many :matching_users, through: :patient_matches, source: :to_user
  has_many :post_followers, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :points, class_name: 'ActionPointUser', dependent: :destroy
  has_many :luvs, dependent: :destroy
  has_many :doctors
  has_many :versions, :foreign_key => "whodunnit", class_name: 'PaperTrail::Version'
  has_many :events, dependent: :destroy
  has_many :labs, dependent: :destroy
  has_many :patient_matches_to, foreign_key: :to_user_id, class_name: "PatientMatch"
  has_many :patient_matches_to_users, through: :patient_matches_to, source: :from_user

  has_and_belongs_to_many :question_categories

  belongs_to :main_condition, class_name: "Condition"
  belongs_to :profile_photo, class_name: "CroppedPhoto"
  belongs_to :country

  validates :email, :username, :password, :password_confirmation, presence: true, if: lambda {provider.blank? && new_record?}
  validates :email, :username, uniqueness: {case_sensitive: false}, if: lambda {email.present? && provider.blank?}
  validates :username, format: {with: /\A[a-zA-Z\d\s\.]*\Z/}
  validates :password, confirmation: true
  #validates :patient_or_caregiver, acceptance: true, on: :create
  validates :email, email: true
  validates :patient_or_caregiver, acceptance: true

  attr_accessor :condition_ids, :symptom_names, :symptom_levels, :treatment_names,
                :treatment_start_years, :treatment_start_months, :treatment_end_years,
                :treatment_end_months, :profile_photo_file, :login, :authentication_token,
                :skip_matching, :skip_before_save

  accepts_nested_attributes_for :referral, :symptoms, :well_being, :treatments

  before_save :check_medical_info, :save_my_tags, :save_full_name, :add_points, :set_country
  before_create :mark_as_active
  after_create :send_welcome_email
  
  after_save :populate_patient_after_save, if: :finished_profile?, unless: :patient_matches_populated?
  
  after_save :touch_posts, if: :username_changed?

  after_validation :geocode, if: ->(obj){ obj.city_changed? || obj.country_id_changed? || obj.zipcode_changed? || obj.state_changed?}

  scope :active, lambda {where(active: true)}

  scope :with_ids, lambda{|ids|
    where(id: ids)
  }

  scope :age_from, lambda{|age|
    date = age.years.ago
    where("birth_date <= ?", date)
  }

  scope :age_to, lambda{|age|
    date = (age + 1).years.ago
    where('birth_date >= ?', date)
  }

  scope :by_gender, lambda{|gender|
    where(gender: gender.downcase)
  }

  scope :by_condition, lambda{|condition_name|
    where('lower(conditions.name) like ?', "#{condition_name.downcase}")
  }

  scope :by_condition, lambda{|condition_id|
    where('user_conditions.condition_id = ? or main_condition_id = ?', condition_id, condition_id)
  }

  scope :best_matches_for, lambda{ |user|
    joins('LEFT JOIN patient_matches ON (patient_matches.to_user_id = users.id)').
    where('patient_matches.from_user_id = ? or patient_matches.from_user_id is null', user.id)
  }

  scope :with_photo, lambda{where("profile_photo_id is not null AND profile_photo_id <> ''")}
  scope :with_coordinates, -> {where('latitude is not null and longitude is not null')}
  scope :last_online, -> {order('last_sign_in_at DESC')}
  acts_as_taggable

  searchable do
    text :first_name, :last_name, :username, :email, :gender, :location, :city, :state, :bio
    text :username, as: :username_textp
    text :username_solr
    text :main_condition_name do
      main_condition.try(:name)
    end
    text :condition_names do
      user_conditions.map{|uc| uc.condition.name}
    end
    text :symptom_names do
      symptoms.map{|s| s.symptom}
    end
    text :treatment_names do
      treatments.map{|t| t.treatment}
    end
  end

  # return full username for index
  def username_solr
    self.username
  end

  def self.text_search(options = {})
    solr_search do
      fulltext options[:query]
    end
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      if user.first_name.blank? && auth.info.name.present?
        names = auth.info.name.split(" ")
        user.last_name = names.pop
        user.first_name = names.join(" ")
      end
      user.username = auth.info.nickname
      user.email = auth.info.email
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"]) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def filled_in_basic_info?
    first_name.present? && last_name.present? && birth_date.present?
  end

  def filled_in_medical_info?
    symptoms.present? || treatments.present?
  end

  def profile_complete?
    main_condition.present?
  end

  def condition_ids=(ids)
    @condition_ids = ids
  end

  def symptom_names=(names)
    @symptom_names = names
  end

  def symptom_levels=(levels)
    @symptom_levels = levels
  end

  def treatment_names=(names)
    @treatment_names = names
  end

  def treatment_start_years=(years)
    @treatment_start_years = years
  end

  def treatment_start_months=(months)
    @treatment_start_months = months
  end

  def treatment_end_years=(years)
    @treatment_end_years = years
  end

  def treatment_end_months=(months)
    @treatment_end_months = months
  end

  def build_well_being_if_needed
    well_being || build_well_being
  end

  def age
    now = Time.now.utc.to_date
    now.year - birth_date.year - (birth_date.to_date.change(:year => now.year) > now ? 1 : 0) rescue nil
  end

  def total_points
    points.sum(:score)
  end

  def check_medical_info
    return if skip_before_save

    # Conditions
    if condition_ids.present?
      self.user_conditions = []
      condition_ids.each do |id|
        if id.to_i > 0
          unless user_conditions.map(&:condition_id).include?(id.to_i)
            self.user_conditions << UserCondition.new(condition_id: id)
          end
        end
      end
    end

    # Symptoms
    if symptom_names.present?
      self.symptoms = []
      symptom_names.each_with_index do |name, index|
        unless name.blank?
          level = symptom_levels[index]
          self.symptoms << Symptom.new(symptom: name, level: level)
        end
      end
    end

    # Treatments
    if treatment_names.present?
      self.treatments = []
      treatment_names.each_with_index do |name, index|
        unless name.blank?
          start_month = treatment_start_months[index]
          start_year  = treatment_start_years[index]
          end_month   = treatment_end_months[index]
          end_year    = treatment_end_years[index]

          started_on  = Date.parse("#{start_year}-#{start_month}-01")
          ended_on    = Date.parse("#{end_year}-#{end_month}-01")

          self.treatments << Treatment.new(treatment: name, started_on: started_on, ended_on: ended_on)
        end
      end
    end
  end

  def profile_photo_file=(file)
    return if file.blank?
    photo = self.photos.create!(attachment: file, type: "CroppedPhoto")
    #photo.attachment.reprocess_without_delay!(:large)
    self.update_attributes(profile_photo: photo, finished_profile: true)
  end

  def follow!(user)
    self.followed_users.create!(followed_user: user)
    if !ActionPoints.favorite_added.blank? && !self.points.exists?(actionable_type: 'User', actionable_id: user.id, action: 'favorite_added')
      self.points.create score: ActionPoints.favorite_added, action: 'favorite_added', actionable_type: 'User', actionable_id: user.id
    end
  end

  def following?(user)
    self.followed_users.map(&:followed_user_id).include?(user.id)
  end

  def followed_by?(user)
    self.following_users.map(&:following_user_id).include?(user.id)
  end

  def save_my_tags
    if skip_before_save
      self.skip_before_save = false
      return
    end

    tags_array = []

    tags_array << main_condition.try(:name) if main_condition.try(:name).present?

    self.symptoms.each do |symptom|
      tags_array << symptom.symptom unless tags_array.include?(symptom.symptom)
    end

    self.sub_categories.each do |sub_category|
      tags_array << sub_category.name 
    end

    self.categories.each do |categories|
      tags_array << categories.name 
    end

    self.conditions.each do |condition|
      tags_array << condition.name unless tags_array.include?(condition.name)
    end

    self.tag_list = tags_array.join(", ")
    self.skip_before_save = true
    self.save
  end

  def mark_as_active
    self.active = true
  end

  def save_full_name
    return if skip_before_save

    self.full_name = "#{first_name} #{last_name}".strip
  end

  def luv!(from_user)
    Notification.loved_user(from_user, self)
    if !ActionPoints.luvs_sent.blank? && !from_user.points.exists?(actionable_type: 'User', actionable_id: self.id, action: 'luvs_sent')
      from_user.points.create score: ActionPoints.luvs_sent, action: 'luvs_sent', actionable_type: 'User', actionable_id: self.id
    end
  end  

  def remove_duplicates_patient_matches
    count = 0
    PatientMatch.where(to_user_id: id).group("from_user_id").count.each do |x,y|      
      if y != 1        
        PatientMatch.where(to_user_id: id, from_user_id: x).to_a.each_with_index do |x,i|
          next if i == 0
          x.delete
          count += 1
        end
      end
    end
    puts "Removed " + count.to_s + " duplicates for user with id: " + id.to_s
  end

  def populate_patient_after_save
    return true if patient_matches_updated_at.present?
    self.touch(:patient_matches_updated_at)
    save_my_tags
    populate_patient_matches
    populate_patient_matches_inverse
  end

  def populate_patient_matches_both_ways
    #save_my_tags
    #populate_patient_matches
    #populate_patient_matches_inverse
    #remove_duplicates_patient_matches
  end

  def populate_patient_matches
    #worker = ::PatientMatchWorker.new
    #worker.run(self)
  end

  def populate_patient_matches_inverse
    #worker = ::PatientMatchWorker.new
    #worker.inverse_run(self)
  end

  # Because of the uniqueness validation, all jobs performed on the 
  # patient_matches queue will be created, only if there is no other
  # job with the same handler.
  #handle_asynchronously :populate_patient_matches, queue: :patient_matches
  #handle_asynchronously :remove_duplicates_patient_matches, queue: :patient_matches
  #handle_asynchronously :populate_patient_matches_inverse, queue: :patient_matches, run_at: Proc.new { 5.minutes.from_now }

  def patient_matches_populated?
    patient_matches_updated_at.present?
  end

  def following_post?(post)
    post_followers.where(post_id: post.id).present?
  end

  def follow_post!(post)
    post_followers.create!(post_id: post.id)
  end

  def unfollow_post!(post)
    post.touch
    post_followers.where(post_id: post.id).delete_all
  end

  def luv_post!(post)
    post.luv!(self)
  end

  def interested!(review)
    review_treatment = review.treatment_review.try(:treatment)
    if !review_treatment.nil? && !treatments.exists?(treatment: review_treatment.treatment)
      treatments.create treatment: review_treatment.treatment, period: "I'm Interested"
    end
  end

  def percentage_score(user)
    score = patient_matches.where(to_user_id: user.id).first.try(:score).to_f
    return "Match Score: 0%" if score < 0
    "Match Score: #{(100.0 * score / highest_score.to_f).to_i}%" rescue ""
  end

  def highest_score
    patient_matches.order("score desc").first.score rescue 0
  end

  def lowest_score
    0
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_with_username
    "#{first_name} #{last_name} #{username}"
  end

  def add_points
    if self.profile_photo_id_changed? && !points.exists?(action: 'profile_pic_uploaded', actionable_type: 'User', actionable_id: self.id)
      points.create action: 'profile_pic_uploaded', actionable_type: 'User', actionable_id: self.id, score: ActionPoints.profile_pic_uploaded
    end

    if self.bio_changed? && self.bio_was.blank? && !points.exists?(action: 'about_me_posted', actionable_type: 'User', actionable_id: self.id)
      points.create action: 'about_me_posted', actionable_type: 'User', actionable_id: self.id, score: ActionPoints.about_me_posted
    end
  end

  def set_country
    self.country_cache = Country.find_by_id(self.country_id).try(:name) if self.country_id_changed?
  end

  def address
    address_arr = [city, state, country_cache]
    address_arr << self.zipcode if self.country_cache == 'United States'
    address_arr.compact.join(', ')
  end

  def pretty_name
    username || full_name
  end
  
  def update_logs
    return true if self.update_treatment_logs
    
    self.treatments.find_each do |treatment|
      treatment.versions.order('versions.created_at asc').find_each do |version|
        v = version.reify
        next if v.blank?
        v.tracking_date = version.created_at.to_date
        v.update_treatment_log
      end
      tr = if (first_version = treatment.versions.order('versions.created_at asc').first.try(:reify)).present?
        first_version
      else
        treatment
      end
      tr.tracking_date = tr.created_at
      tr.take_today = true
      tr.update_treatment_log
    end
    
    self.symptoms.find_each do |symptom|
      symptom.versions.order('versions.created_at asc').find_each do |version|
        v = version.reify
        next if v.blank?
        v.tracking_date = version.created_at.to_date
        v.update_symptom_log
      end
    end

    if self.well_being
      well_being.versions.order('versions.created_at asc').find_each do |version|
        v = version.reify
        next if v.blank?
        v.tracking_date = version.created_at.to_date
        v.update_well_being_log
      end
    end

    self.update_attributes(update_treatment_logs: true)
  end

  def daily_digest
    results = []
    if email_digest_for_private_message
      daily_messages.each do |item|
        results << {item: item, link: item.target_url, created_at: item.created_at.to_i}
      end
    end

    [:email_digest_when_comment_after,
     :email_digest_when_luv,
     :email_digest_when_luv_post,
     :email_digest_when_subscribed,
     :email_digest_when_mentioned,
     :email_digest_for_helpful,
     :email_digest_for_follower,
     :email_digest_when_reply,
     :email_digest_when_comment].each do |title|
      items = daily_notifications(Notification::NOTIFICATION_DIGEST_CONFIG[title][:notification_type])
      if self.send(title) && items.length > 0
        items.each do |item|
          results << {item: item, link: item.target_url, created_at: item.created_at.to_i}
        end
      end
    end

    if ::SENDING_EMAILS && results.length > 0
      NotificationsMailer.daily_digest(results, self).deliver
    end
  end

  def daily_notifications(notification_type)
    received_notifications.where(created_at: 1.day.ago..Time.zone.now).where(notification_type: notification_type)
  end

  def daily_messages
    received_messages.where(created_at: 1.day.ago..Time.zone.now)
  end


  def all_messages_with(user)
    Message.where('(from_user_id = ? AND to_user_id = ?) OR (from_user_id = ? AND to_user_id = ?)', self.id, user.id, user.id, self.id).order('created_at DESC')
  end

  def name
    username
  end

  def finish_survey
    update_attributes completed_survey: true
  end

  handle_asynchronously :update_logs, queue: :patient_matches, priority: 10

protected
  def send_welcome_email
    if ::SENDING_EMAILS
      NotificationsMailer.welcome(self).deliver
    end
  end

  def touch_posts
    posts.find_each(&:touch)
  end

end
