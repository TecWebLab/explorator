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
      if repository.title!= 'Explorator'
        @repositories <<  Repository.new(repository.object_id,repository.title, session[:disablerepositories].include?(repository.title))
      end
    end       
    render :layout => false
  end
  
  #The disable method disable a adapter.
  #disable a specific adapter in the ConnectionPool.
  def enable
    session[:disablerepositories] << (params[:title]) 
    session[:disablerepositories].uniq!
   # Repository.disable_by_title(params[:title])
    #render nothing.
    render :text => '',:layout => false
    
  end
  #The enable method enable a adapter.
  #enable a specific adapter in the ConnectionPool.
  def disable
     session[:disablerepositories].delete(params[:title])
   # Repository.enable_by_title(params[:title])
    #render nothing.
    render :text => '',:layout => false
  end
  def add
    adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => params[:uri], :results => :sparql_xml, :caching =>true
    adapter.title=params[:title]    
    RDFS::Resource.find_all_predicates    
    # construct the necessary Ruby Modules and Classes to use the Namespace
    ObjectManager.construct_classes
   # enable(params[:title])
    
    render :text => 'SparqlEndpoint Added!',:layout => false
  end
end
