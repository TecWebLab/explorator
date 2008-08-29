#This controller handles all users request that performs a changing in the domain model.
#Author: Samur Araujo
#Date: 25 jun 2008.

#module where the SemanticExpression class is defined.
require 'query_builder'
#module where the query class is defined.
require 'query_factory'

class ExploratorController < ApplicationController 
  require_dependency "resource_set"
  require_dependency "explorator_application"
  # attr_accessor :resourceset
  #default rails method. returns the view index.rhtml.
  def index  
  
  end  
  #  prints the filter screen
  def filter    
    @setid=params[:uri]
    render :partial => 'filter',:layout=>false;
  end
  # This create method  a ResourceSet based on the Semantic Expression passed
  # by the parameter 'exp';
  # The exp value must be a valid SemanticExpression class instance.
  #Request sample:
  #/explorator/create?exp=SemanticExpression.new.union(:s,Namespace.lookup(:rdf,:type),Namespace.lookup(:rdfs,:Class))
  def create    
    
    #creates a new set. 
    #the expression must be passed by the uri
    set = EXPLORATOR::Set.new('http://www.tecweb.inf.puc-rio.br/resourceset/id/' + UUID.random_create.to_s)       
    set.init(params[:exp])
     puts params[:exp]
    #the object @resourceset is a global object that will be used by render
    @resourceset = set     
    #render the _window.rhtml view
    render :partial => 'window',:layout=>false;
  end
  # The  update method updates a specfic ResourceSet instance identified by the parameter id.
  # The new value will be defined by the expression passed by the parameter exp.
  # The exp value must be a valid SemanticExpression class instance and the ResourceSet instance
  # must has been defined before.
  def update     
       puts params[:exp]
    #reevaluate the expression and return the set
    resource =   Application.get(params[:uri])
  
    resource.expression = params[:exp] 
    
    #the object @resourceset is a global object that will be used by render   
    @resourceset =  Application.get(params[:uri]) 
    
    #render the _window.rhtml view
    render :partial => 'window', :layout=>false
  end
  #The execute method  evaluate a ruby expression. 
  #this method is used to invoke another method of Explorator.
  #Basically, the UI call this method passing as the expression a 
  # call to the method refresh or remove.
  def execute
    #eval an expression    
    puts params[:exp]
    eval (params[:exp])
  end
  
  #The reload method is used to return a specific range of resources from a ResourceSet
  #This method is used by the UI when the user is accessing the paginatition indexes.
  #The UI pass 2 parameters, the ResourceSet id and an offset value.
  def reload  
    #return a specific set of resource considering an offset.
    @resourceset= Application.get(params[:uri]).setWithOffset( params[:offset])    
    #render the _window.rhtml view
    render :partial => "window" , :layout=>false
  end
  #This method execute a ruby code over all array elements.
  def map
    
  end
  #The remove method removes a determined ResourceSet from the SetsPool or a specific resource from a ResourceSet
  #This method is called by the execute method, being passing as parameter by the user interface.
  def remove(uri)        
    #for remove only one resource in the context 
    Application.remove(uri)    
    render :text => '', :layout=>false
  end
  #The refresh method return a determined ResourceSet from the SetsPool
  #This method is called by the Execute method, being passed as a parameter by the interface.
  def refresh(uri)   
    @resourceset= Application.get(uri).setWithOffset(0)    
    #render the _window.rhtml view
    render :partial => "window" , :layout=>false
  end
  
  def addfilter     
    @resourceset= Application.get(params[:uri])
    @resourceset.addFilter("filter('select{|i| i.to_i" + params[:op] +  params[:value]+ "}')")
    render :partial => "window" , :layout=>false
  end
  def sum
    @resourceset= Application.get(params[:uri])
    @resourceset.sum()  
      render :partial => "window" , :layout=>false
  end
  
end