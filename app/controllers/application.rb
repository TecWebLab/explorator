# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ExploratorError < Exception
end
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  #global attribute use for all explorator controllers
  @resourceset
  #This was set to false for enable ajaxs request over post HTTP method.
  self.allow_forgery_protection = false
  
  def index    
    @applications = EXPLORATOR::Application.find_all    
  end
  def create
     Application.create(params[:name])  
      redirect_to :controller => "explorator"
  end
  def restore 
      Application.load(params[:uri])  
      redirect_to :controller => "explorator"
     # render :template => 'explorator/index'
  end
  def delete
    Application.delete(params[:uri])  
  end
end
