class Article < ActiveRecord::Base
  belongs_to :user

  validates :permalink, uniqueness: true, allow_blank: true

  before_save  :sanitize
  after_create :set_permalink

  scope :published, -> {where(state: 'published').order("published_at DESC")}
  scope :recommended, -> {where(state: 'published').where(recommended: true).order("published_at DESC")}

  state_machine :initial => :pending do
    before_transition :on => :publish, :do => :set_published_at
    event :publish do
      transition :pending => :published
    end
  end

  paginates_per 12

  include ActionView::Helpers::DateHelper

  HKZ_SANITIZE = {
    elements: ['a', 'b', 'p', 'strike', 'h3', 'img', 'pre', 'blockquote', 'code', 'ul', 'ol', 'li','iframe', 'object', 'param', 'embed', 'audio', 'source'],
    attributes: {
      'a'      => ['href', 'title'],
      'img'    => ['src', 'width'],
      'object' => ['width', 'height'],
      'iframe' => ['src', 'width', 'height', 'frameborder',
                    'webkitallowfullscreen', 'mozallowfullscreen',
                    'allowfullscreen'],
      'param'  =>  ['name', 'value'],
      'embed'  =>  ['width', 'height', 'allowfullscreen', 'allowscriptaccess', 'quality', 'src', 'type'],
      audio:  ['controls', 'autobuffer'],
      source: ['src', 'type']
    },
    :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}}
  }

  def to_params
    [user.name, permalink]
  end

  def sanitize
    content = Sanitize.clean(content, HKZ_SANITIZE).try(:strip)
  end
  
  def as_json(options={})
    {
      id: id,
      title: title,
      permalink: "#{options[:logged_in] ? 'mine' : user.name}/#{permalink}",
      published_at: time_ago_in_words(published_at||created_at),
      status: published? ? '' : 'draft'
    }
  end

  def set_permalink
    self.title     ||= "Untitled #{id}"
    self.permalink ||= "untitled-#{id}"
    self.save if self.changed?
  end

  def set_published_at
    self.published_at = Time.now
  end

end
