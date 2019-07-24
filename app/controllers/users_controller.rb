class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])    
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      redirect_to(user_path(@user))
    else
      render('edit')
    end
  end

  private

  def user_params
    params.require(:user).permit(:user_name, :email)
  end

end
