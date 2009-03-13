#This Controller is in charge of the repository management.
#Basically, It enable/disable a repository or list all of them.
#Author: Samur Araujo
#Date: 25 jun 2008.
class RepositoryController < ApplicationController  
  # The index method get the list of all adapter in the pool.
  #list all adapters registered in the pool.
  @repositories
  def index
   
    render :layout => false
  end
  def limit
    adapters = ConnectionPool.adapters()
    adapters.each do |repository|
      #create a model repository passing the repository's id, title and enableness 
      if repository.title == params[:title]
        
        repository.limit=params[:limit].rstrip
        repository.limit=nil if repository.limit == 0 || repository.limit ==''
        puts repository.limit
      end
    end       
    render :text => '',:layout => false
  end
  #The disable method disable a adapter.
  #disable a specific adapter in the ConnectionPool.
  def enable
    RDFS::Resource.reset_cache() 
    session[:disablerepositories] << (params[:title]) 
    session[:disablerepositories].uniq!
    # Repository.disable_by_title(params[:title])
    #render nothing.
    render :text => '',:layout => false    
  end
  #The enable method enable a adapter.
  #enable a specific adapter in the ConnectionPool.
  def disable
    RDFS::Resource.reset_cache() 
    session[:disablerepositories].delete(params[:title])
    # Repository.enable_by_title(params[:title])
    #render nothing.
    render :text => '',:layout => false
  end
  def add
    if params[:title]==nil || params[:title]  == ''
      redirect_to :controller => 'message',:action => 'error', :message => "Type the SPARQL Enpoint title",:layout => false
      return
    end
    begin
      adapter = ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => params[:uri], :results => :sparql_xml, :caching =>true
      adapter.title=params[:title]    
      adapter.limit=params[:limit]  if params[:limit] != nil && params[:limit].rstrip != ''  
      session[:addrepositories]<<adapter
    session[:disablerepositories] << (params[:title]) 
    session[:disablerepositories].uniq!
    
rescue Exception => e
  puts e.message
  puts e.backtrace
  
   session[:addrepositories].delete(adapter)
    session[:disablerepositories].delete(params[:title]) 
   ConnectionPool.remove_data_source(adapter)
#      render_component :controller => 'message',:action => 'error', :message => "SPARQL Enpoint invalid: "+e.message ,:layout => false
redirect_to :action => 'endpointsform' , :message => "SPARQL Enpoint invalid: "+e.message ,:layout => false
return
end
       begin 
      RDFS::Resource.find_all_predicates    
      # construct the necessary Ruby Modules and Classes to use the Namespace
      ObjectManager.construct_classes
      
      #Test the sparql endpoint.
      Query.new.distinct(:s).where(:s,Namespace.lookup(:rdf,:type),Namespace.lookup(:rdfs,:Class)).limit(5).execute      
rescue Exception => e
  puts e.message
  puts e.backtrace
   session[:addrepositories].delete(adapter)
    session[:disablerepositories].delete(params[:title]) 
    ConnectionPool.remove_data_source(adapter)
redirect_to :action => 'endpointsform' ,:message => e.message ,:layout => false
return
#       render_component :controller => 'message',:action => 'error',:message => e.message ,:layout => false
end
redirect_to :action => 'endpointsform',:message => 'Sparql endpoint added successfully!' ,:messageaction=>'confirmation'
 
end
def listenabledrepositories
 render :partial => 'listenabledrepositories',:layout =>false
end

def endpointsform
   #variable that will store the list of adapters.
    @repositories = Array.new
    @message = params[:message]
    puts @message
    #Gets all adapters    
    adapters = ConnectionPool.adapters()
    adapters.each do |repository|
      #create a model repository passing the repository's id, title and enableness 
      if repository.title!= 'INTERNAL' && (repository.title.index('_LOCAL') || session[:addrepositories].include?(repository))
        @repositories <<  Repository.new(repository.object_id,repository.title, session[:disablerepositories].include?(repository.title),repository.limit)
      end
    end       

 render :layout =>false
end
end
