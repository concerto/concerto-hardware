module ConcertoHardware
class PlayersController < ConcertoHardware::ApplicationController
  #include routes.named_routes.helpers
  before_filter :screen_api

  # GET /players
  # GET /players.json
  def index
    @players = Player.all
    auth!

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @players }
    end
  end

  # GET /players/1
  # GET /players/1.json
  # GET /players/by_screen/2(.json)
  # GET /players/current(.json)
  def show
    if params.has_key? :screen_id
      screen_id = params[:screen_id]
      @player = ConcertoHardware::Player.find_by_screen_id!(screen_id)
    elsif params.has_key? :id
      @player = Player.find(params[:id])
    else # Return data about the logged-in screen
      if current_screen.nil?
        raise ActiveRecord::RecordNotFound, "Couldn't find an authenticated screen."
      else
        @player = Player.find_by_screen_id!(current_screen.id)
        @player.ip_address = request.remote_ip if @player
      end
    end
    auth!

    @player.save if @player.ip_address_changed?

    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => @player.to_json(
          :include => { :screen => { :only => :name } },
          :methods => [:time_zone]
        )
      }
    end
  end

  # GET /players/1/edit
  def edit
    @player = Player.find(params[:id])
    auth!
  end

  # PUT /players/1
  # PUT /players/1.json
  def update
    @player = Player.find(params[:id])
    auth!

    respond_to do |format|
      if @player.update_attributes(player_params)
        format.html { redirect_to [hardware, @player], :notice => 'Player was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @player.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player = Player.find(params[:id])
    auth!
    @player.destroy

    respond_to do |format|
      format.html { redirect_to hardware.players_url }
      format.json { head :no_content }
    end
  end

  private

  # Deal with strong parameter restrictions.
  def player_params
    params.require(:player).permit(:wkday_on_time, :wkday_off_time,
      :wknd_on_time, :wknd_off_time, :wknd_disable, :force_off, :always_on)
  end
end

end
