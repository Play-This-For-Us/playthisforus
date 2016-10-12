# frozen_string_literal: true
class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, only: [:show, :edit]

  def index
    @events = Event.all
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user # the owner

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to current_user, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def join
  end

  def create_join
    @event = Event.find_by_join_code(params[:join_code])
    if @event.present?
      cookies.permanent.encrypted[:join_cookie] = @event.join_code
      cookies.permanent[:user_identifier] = Digest::SHA1.hexdigest([Time.now, rand].join)
      redirect_to @event
    else
      render :join
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:name, :description)
  end

  def authenticate
    redirect_to root_path unless can_view?
  end

  def can_view?
    (current_user.present? && @event.user == current_user) ||
      (Event.find_by_join_code(cookies.permanent.encrypted[:join_cookie]) == @event)
  end
end
