module CandidatesHelper
  def candidate_info(candidate)
    # if candidate.kind_of?(Candidate) # 很少這樣檢查型別
    "#{candidate.name}, Age: #{candidate.age}"
  end
end

