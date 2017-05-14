class CandidatesController < ApplicationController
  def index
    @candidates = Candidate.all
  end

  def show
    # enter the byebug console
    # byebug
  end

  def new
    @candidate = Candidate.new
  end

  def create
    # create don't need @ instance, the @ is for :new
    @candidate = Candidate.new(candidate_params)
    # byebug

    # you can do the following too
    # @candidate = Candidate.new
    # @candidate.name = params[:candidate][:name]
    # @candidate.party = params[:candidate][:party]
    # @candidate.age = params[:candidate][:age]
    # @candidate.politics = params[:candidate][:politics]

    if @candidate.save
      redirect_to candidates_path
    else
      render :new
    end
  end

  private 
    # clean 
    def candidate_params
      params.require(:candidate).permit(:name, :party, :age, :politics)
    end
end
