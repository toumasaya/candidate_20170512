namespace :vote do
  desc "Reset Counter Cache"
  # task :reset_counter do # 指示不夠明確，會產生 error
  task :reset_counter => :environment do # 先做 :environment 再做 :reset_counter
    Candidate.all.each do |candidate|
      Candidate.reset_counters(candidate.id, :vote_logs)
      puts candidate.id
    end
    # puts "hi"
  end
end

namespace :gg do
  desc "Test GG"
  task :test_gg do
    puts "hi"
  end
end
