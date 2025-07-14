class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  before_validation :normalize_name
  
  def self.increment_count(tag_name)
    normalized_name = tag_name.to_s.strip.downcase
    return if normalized_name.blank?
    
    tag = find_or_initialize_by(name: normalized_name)
    tag.count = (tag.count || 0) + 1
    tag.save!
    tag
  end
  
  def self.highest_count_tag
    order(count: :desc).first
  end
  
  private
  
  def normalize_name
    self.name = name.to_s.strip.downcase if name.present?
  end
end
