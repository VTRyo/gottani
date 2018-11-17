class UsersController < ApplicationController
  def show
    @user = User.where(nickname: params[:id].first)
  end
end
