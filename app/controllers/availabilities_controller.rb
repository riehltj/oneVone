# frozen_string_literal: true

class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_availability, only: %i[edit update destroy]

  def index
    @availabilities = current_user.availabilities.order(:day_of_week, :start_time)
  end

  def new
    @availability = current_user.availabilities.build
  end

  def create
    @availability = current_user.availabilities.build(availability_params)
    if @availability.save
      redirect_to availabilities_path, notice: "Availability added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @availability.update(availability_params)
      redirect_to availabilities_path, notice: "Availability updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @availability.destroy!
    redirect_to availabilities_path, notice: "Availability removed."
  end

  private

  def set_availability
    @availability = current_user.availabilities.find(params[:id])
  end

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time, :timezone)
  end
end
