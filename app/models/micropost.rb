class Micropost < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.maxlenpost}
  validate  :picture_size
  scope :posted_by, ->(user){where user_id: user.id}
  scope :sort_by_time_desc, ->{order(created_at: :desc)}
  scope :find_post_of_current_and_followed, ->(following_ids, id){where "user_id IN (?) OR user_id = ?", following_ids, id}
  mount_uploader :picture, PictureUploader

  private

  # Validates the size of an uploaded picture.
  def picture_size
    errors.add :picture, I18n.t(".imagesize") if picture.size > Settings.imagesize.megabytes
  end
end
