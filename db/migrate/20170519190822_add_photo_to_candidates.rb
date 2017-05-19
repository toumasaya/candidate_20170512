class AddPhotoToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :photo, :string
  end
end
