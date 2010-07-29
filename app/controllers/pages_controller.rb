class PagesController < ApplicationController
  def show
    return not_found unless current_page
  end
end
