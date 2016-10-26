# frozen_string_literal: true
class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :start_playing, :stop_playing, :create_new_playlist]
  before_action :authenticate, only: [:show, :edit]
  before_action :authenticate_owner, only: [:edit, :update]

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

    pnator_setup

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
    pnator_setup

    respond_to do |format|
      if @event.save && @event.update(event_params)
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
    if join_event_params.present?
      @event = Event.find_by_join_code(join_event_params)

      if @event.present?
        set_join_cookie
        set_user_identifier_cookie
        redirect_to @event, notice: "You've sucessfully joined #{@event.name}"
      else
        redirect_to root_path, flash: { error: "Invalid code: #{join_event_params}" }
      end
    else
      redirect_to root_path, flash: { error: 'No join code found' }
    end
  end

  def start_playing
    if create_playlist && queue_first_song && set_playing
      redirect_to @event, notice: 'Sweet! The playlist has started.'
    else
      redirect_to @event, error: 'An error occurred creating the playlist.'
    end
  end

  def stop_playing
    if @event.update(currently_playing: false)
      redirect_to @event, notice: 'Nifty! The playlist has stopped.'
    else
      redirect_to @event, error: 'An error occurred stopping the playlist.'
    end
  end

  def create_new_playlist
    if create_playlist(true)
      redirect_to @event, notice: 'Slick! A new playlist was created.'
    else
      redirect_to @event, error: 'An error occurred creating the new playlist.'
    end
  end

  private

  def pnator_setup
    pnator_on = params[:pnator_on] == 'on'
    if pnator_on
      target_energy = params[:pnator_energy].to_i / 100.to_f
      target_danceability = params[:pnator_danceability].to_i / 100.to_f
      target_popularity = params[:pnator_popularity].to_i / 100.to_f
      target_speechiness = params[:pnator_speechiness].to_i / 100.to_f
      target_happiness = params[:pnator_happiness].to_i / 100.to_f

      @event.pnator_enabled = pnator_on
      @event.pnator_danceability = target_danceability
      @event.pnator_energy = target_energy
      @event.pnator_popularity = target_popularity
      @event.pnator_speechiness = target_speechiness
      @event.pnator_happiness = target_happiness
    end
  end

  def join_event_params
    if params.key?(:join_code)
      params[:join_code]
    elsif params.key?(:events) && params[:events].key?(:join_code)
      params[:events][:join_code]
    end
  end

  def set_playing
    @event.update!(currently_playing: true)
  end

  def queue_first_song
    @event.queue_next_song
  end

  def create_playlist(force = false)
    return true if @event.spotify_playlist_id.present? && !force

    playlist = @event.user.spotify.create_playlist!(@event.name)
    @event.update(spotify_playlist_id: playlist.id)
  end

  def set_join_cookie
    cookies.permanent.encrypted[:join_cookie] = @event.join_code
  end

  def set_user_identifier_cookie
    cookies.permanent[:user_identifier] = Digest::SHA1.hexdigest([Time.now.utc, rand].join)
  end

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

  def authenticate_owner
    redirect_to @event unless owns_event?
  end

  def can_view?
    (current_user.present? && @event.user == current_user) ||
      (Event.find_by_join_code(cookies.permanent.encrypted[:join_cookie]) == @event)
  end

  def owns_event?
    current_user.present? && @event.user == current_user
  end
end
