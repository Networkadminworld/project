class Admin::ActionListsController < ApplicationController
  layout 'admin_layout'
  before_action :check_admin_user
  before_action :set_admin_action_list, only: [:show, :edit, :update, :destroy]

  def index
   @action_lists = ActionList.all.paginate(:page => params[:page], :per_page => 10)
  end

  def show
  end

  def new
    @action_list = ActionList.new
  end

  def edit
  end

  def create
    @action_list = ActionList.new(admin_action_list_params)

    respond_to do |format|
      if @action_list.save
        response_message(format)
      else
        format.html { render :new }
        format.json { render json: @action_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @action_list.update(admin_action_list_params)
        response_message(format)
      else
        format.html { render :edit }
        format.json { render json: @action_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @action_list.destroy
    respond_to do |format|
      format.html { redirect_to admin_action_lists_url }
      format.json { head :no_content }
    end
  end

  private

  def set_admin_action_list
    @action_list = ActionList.find(params[:id])
  end

  def admin_action_list_params
    params.require(:action_list).permit!
  end

  def check_admin_user
    redirect_to "/" if current_user && !current_user.admin?
  end

  def response_message(format)
    format.html { redirect_to admin_action_lists_path, notice: 'Action list was successfully created.' }
    format.json { render :show, status: :ok, location: @action_list }
  end
end
