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
puts    SemanticExpression.new.union('<http://sw.nokia.com/id/ad845e2a-ab23-4bab-973e-30b25064339d/2660>',:p,:o).union('<http://sw.nokia.com/id/edbf3c81-a7e4-491a-856e-5728a57192a5/2865>',:p,:o).union('<http://sw.nokia.com/id/affdb666-c69d-4d41-8855-d0f6a1ddf0d1/2865i>',:p,:o).union('<http://sw.nokia.com/id/f005e247-a3c2-4a0e-b93a-eaec18476939/3105>',:p,:o).union('<http://sw.nokia.com/id/5e7a6e20-d776-4016-ac0d-f393746333e8/3108>',:p,:o).intersection(SemanticExpression.new.union(SemanticExpression.new(:s,'<http://sw.nokia.com/DP-1/screen_height>', '128').intersection(:s,'<http://sw.nokia.com/DP-1/screen_width>', '128'))).result.size
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
       puts params[:exp]
    #creates a new set. 
    #the expression must be passed by the uri
    set = EXPLORATOR::Set.new('http://www.tecweb.inf.puc-rio.br/resourceset/id/' + UUID.random_create.to_s)       
    set.init(params[:exp])

    #the object @resourceset is a global object that will be used by render
    @resourceset = set     
    #render the _window.rhtml view
    render :partial => 'subject_view',:layout=>false;
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
    render :partial => 'subject_view', :layout=>false
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
    render :partial => params[:view]  , :layout=>false
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
  def refresh(uri,view=:subject_view)   
    @resourceset= Application.get(uri).setWithOffset(0)    
    #render the _window.rhtml view
    render :partial => view.to_s , :layout=>false
  end
  
  def addfilter     
    @resourceset= Application.get(params[:uri])
    @resourceset.addFilter("filter('select{|i| i.to_i" + params[:op] +  params[:value]+ "}')")
    render :partial => "subject_view" , :layout=>false
  end
  def sum
    @resourceset= Application.get(params[:uri])
    @resourceset.sum()  
      render :partial => "subject_view" , :layout=>false
  end
  
end