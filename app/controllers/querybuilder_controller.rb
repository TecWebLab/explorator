class QuerybuilderController < ApplicationController  
  def index 
     puts '$$$$$$$$$$$ eeee'
    @resource =  Namespace.lookup(:rdfs,:Resource)
    render :action => 'index' 
  end
  def resource     
  puts '$$$$$$$$$$$ resource'
     @resource = RDFS::Resource.new(params[:uri])
     render :partial => 'resource' 
 end
  def relation     
    puts '$$$$$$$$$$$ rej'
     @resource = RDFS::Resource.new(params[:uri]) 
     render :partial => 'relation' 
  end
end
