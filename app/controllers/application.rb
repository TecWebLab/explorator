# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ExploratorError < Exception
end
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time  
  before_filter :session_init
  #global attribute use for all explorator controllers
  @resourceset
 def session_init
    #puts  session[:application].instance
    if session[:application] == nil
      puts 'initializing session'
      session[:application] =  Application.new(session.session_id)
  end
     Thread.current[:application]=session[:application]
 end

  #This was set to false for enable ajaxs request over post HTTP method.
  self.allow_forgery_protection = false  
  def index    
    puts "aqui"
    @applications = EXPLORATOR::Application.find_by_explorator::uuid(session[:useruri])
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
