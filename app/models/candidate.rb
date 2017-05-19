class Candidate < ApplicationRecord
  validates :name, presence: true
  has_many :vote_logs

  # 處理資料有關的邏輯，就寫在 model
  # before_save :add_name
  # before_create :encrypt_email

  def info
    "#{name}, Age: #{age}"
  end

  private
  # def encrypt_email
  #   self.password = ...
  # end
  # def add_name
  #   self.name = "#{self.name} 9527" unless name.ends_with?("9527")
  # end
end
