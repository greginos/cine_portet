class MembershipsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(membership_params)
    if @user.save
      redirect_to root_path, notice: "Adhésion réussie !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def membership_params
    params.require(:user).permit(:last_name, :first_name, :email, :phone, :address, :zip_code, :city, :country)
  end
end
