class AddCounterToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :vote_logs_count, :integer, default: 0
  end
end
