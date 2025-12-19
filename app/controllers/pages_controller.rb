class PagesController < ApplicationController
  def home
    # Redirect logged-in users to their respective dashboards
    if user_signed_in?
      if current_user.brand?
        redirect_to brand_dashboard_path
      else
        redirect_to creator_dashboard_path
      end
    end
  end
end

