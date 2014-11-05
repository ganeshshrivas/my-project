class UserController < ApplicationController
	  before_action :set_user, only: [:show, :edit, :update, :destroy]

  ...

  # GET /users/:id.:format
  def show
    # authorize! :read, @user
  end

  # GET /users/:id/edit
  def edit
    # authorize! :update, @user
  end

  # PATCH/PUT /users/:id.:format
  def update
    # authorize! :update, @user
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user == current_user ? @user : current_user, :bypass => true)
        format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    # authorize! :update, @user 
    if request.patch? && params[:user] #&& params[:user][:email]
      if @user.update(user_params)
        @user.skip_reconfirmation!
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  # DELETE /users/:id.:format
  def destroy
    # authorize! :delete, @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end
  
  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      accessible = [ :name, :email ] # extend with your own params
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      params.require(:user).permit(accessible)
    end
end

app/views/users/finish_signup.html.erb

In our implementation, the form below only collects an email address from the user, but you could easily add other required fields, and even request the user specify a password at this point so they can login with an email and password later on. Note that the following template uses Bootstrap markup.

<div id="add-email" class="container">
  <h1>Add Email</h1>
  <%= form_for(current_user, :as => 'user', :url => finish_signup_path(current_user), :html => { role: 'form'}) do |f| %>
    <% if @show_errors && current_user.errors.any? %>
      <div id="error_explanation">
        <% current_user.errors.full_messages.each do |msg| %>
          <%= msg %><br>
        <% end %>
      </div>
    <% end %>
    <div class="form-group">
      <%= f.label :email %>
      <div class="controls">
        <%= f.text_field :email, :autofocus => true, :value => '', class: 'form-control input-lg', placeholder: 'Example: email@me.com' %>
        <p class="help-block">Please confirm your email address. No spam.</p>
      </div>
    </div>
    <div class="actions">
      <%= f.submit 'Continue', :class => 'btn btn-primary' %>
    </div>
  <% end %>
</div>

end
