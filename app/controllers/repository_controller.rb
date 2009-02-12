#This Controller is in charge of the repository management.
#Basically, It enable/disable a repository or list all of them.
#Author: Samur Araujo
#Date: 25 jun 2008.
class RepositoryController < ApplicationController  
  # The index method get the list of all adapter in the pool.
  #list all adapters registered in the pool.
  @repositories
  def index
    #variable that will store the list of adapters.
    @repositories = Array.new
    #Gets all adapters    
    adapters = ConnectionPool.adapters()
    adapters.each do |repository|
      #create a model repository passing the repository's id, title and enableness 
      if repository.title!= 'WORK' && (repository.title.index('_DEFAULT') || session[:addrepositories].include?(repository))
        @repositories <<  Repository.new(repository.object_id,repository.title, session[:disablerepositories].include?(repository.title),repository.limit)
      end
    end       
    render :layout => false
  end
  def limit
    adapters = ConnectionPool.adapters()
    adapters.each do |repository|
      #create a model repository passing the repository's id, title and enableness 
      if repository.title == params[:title]
        repository.limit=params[:limit]
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
      render :text => 'O título do sparql endpoint é obrigatório.',:layout => false      
      return
    end
    begin
      adapter = ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => params[:uri], :results => :sparql_xml, :caching =>true
      adapter.title=params[:title]    
      adapter.limit=params[:limit]  if params[:limit] != nil   
       session[:addrepositories]<<adapter
    session[:disablerepositories] << (params[:title]) 
    session[:disablerepositories].uniq!
      RDFS::Resource.find_all_predicates    
      # construct the necessary Ruby Modules and Classes to use the Namespace
      ObjectManager.construct_classes
      
      #Test the sparql endpoint.
      Query.new.distinct(:s).where(:s,Namespace.lookup(:rdf,:type),Namespace.lookup(:rdfs,:Class)).limit(5).execute      

     

rescue Exception => e
  puts e.message
   session[:addrepositories].delete(adapter)
    session[:disablerepositories].delete(params[:title]) 
 
       ConnectionPool.remove_data_source(adapter)
render :text => e.message,:layout => false

   return
end

   # enable(params[:title])    
render :text => 'SparqlEndpoint Added!',:layout => false
  end
end
