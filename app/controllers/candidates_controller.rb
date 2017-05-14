class CandidatesController < ApplicationController
  before_action :find_candidate, only: [:show, :edit, :update, :destroy]

  def index
    @candidates = Candidate.all
  end

  def show
    # enter the byebug console
    # byebug
    # @candidate = Candidate.find_by(id: params[:id]) # before_action
    # redirect_to candidates_path if @candidate.nil? # 防呆
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

  def edit
    # @candidate = Candidate.find_by(id: params[:id]) # before_action
    # redirect_to candidates_path if @candidate.nil? # 防呆
  end

  def update
    # @candidate = Candidate.find_by(id: params[:id]) # before_action
    # redirect_to candidates_path if @candidate.nil? # 防呆

    if @candidate.update(candidate_params)
      redirect_to candidate_path(@candidate), notice: "Work"
    else
      render :edit
    end
  end

  def destroy
    # @candidate = Candidate.find_by(id: params[:id]) # before_action
    # redirect_to candidates_path if @candidate.nil? # 防呆
    @candidate.destroy
    redirect_to candidates_path, notice: "Delete!"
  end

  private 
    # clean 
    def candidate_params
      params.require(:candidate).permit(:name, :party, :age, :politics)
    end

    def find_candidate
      @candidate = Candidate.find_by(id: params[:id])
      redirect_to candidates_path if @candidate.nil? # 防呆
    end
end
