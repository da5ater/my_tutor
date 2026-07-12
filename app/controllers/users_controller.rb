class UsersController < ApplicationController
  before_action :set_user, only: [ :edit, :update, :show ]


  def index
    # @users = User.all.order(created_at: :desc)


    @q = User.ransack(params[:q])

    @pagy, @users = pagy(@q.result(distinct: true))

    authorize User
  end


  def show
    authorize @user
  end


  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(user_params)
      redirect_to users_path
      flash[:notice] = "User updated successfully"
    else
      render :edit, status: :unprocessable_entity
      flash[:alert] = "User update failed"
    end
  end



  private

  def user_params
    params.require(:user).permit(role_ids: [])
  end

  def set_user
    @user = User.friendly.find(params[:id])
  end
end
