class Doctor < ActiveRecord::Base
  has_paper_trail
  belongs_to :country
	belongs_to :doctor_summary
  belongs_to :user
  has_one :doctor_review, dependent: :destroy

	scope :recent, ->{ order('created_at desc') }
  scope :with_review, lambda { joins(doctor_review: :review).where("posts.hide_for_feed =  false") }

  after_create :create_review, unless: :skip_review_update
  after_save :reload_rating
  before_save :load_doctor_summary
  before_save :set_country_cache
  before_validation :strip_doctor

  validates :name, uniqueness: {scope: :user_id, case_sensitive: false}, presence: true

  attr_accessor :skip_review_update, :hide_for_feed

  def location
    @locations ||= []
    unless @locations.any?
      @locations << city unless city.blank?
      if country_cache == 'United States'
        @locations << state unless state.blank?
      end
      @locations << country_cache unless country_cache.blank?
    end
    @locations.join(', ')
  end

  def self.reviews
    Post.where(doctor_review_id: DoctorReview.where(doctor_id: scoped.pluck('doctors.id')))
  end

	private

	def create_review
		DoctorReview.create!(doctor: self, hide_for_feed: true)
  end  

  def load_doctor_summary
    self.doctor_summary = DoctorSummary.where(doctor_name: name).first_or_create if doctor_summary.blank?
    self.doctor_summary.reload_numbers
  end

  def set_country_cache
    self.country_cache = country.try(:name) if country_id_changed?
  end

  def strip_doctor
    self.name = self.name.strip
  end

  def reload_rating
    doctor_summary.reload_rating
  end
  	
end