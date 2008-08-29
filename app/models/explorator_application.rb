#This class is a pool of sets. Each set should has a set of RDFS::Resources
#This class is a singleton pattern.
#Author: Samur Araujo
#Date: 25 jun 2008.
class EXPLORATOR::Application < RDFS::Resource
  self.class_uri = RDFS::Resource.new('http://www.tecweb.inf.puc-rio.br/ontologies/2008/explorator/01/core#Application')   
  def initialize(uri)
    super(uri)      
  end
  def is_current?()
    if self.to_s == Application.instance.to_s         
      return true
    end
    false
  end
end
class Application 
  $instance  
  class << self
    def instance
      if $instance == nil
        $instance = EXPLORATOR::Application.new('http://www.tecweb.inf.puc-rio.br/application/id/default')
        $instance.rdfs::label='Default'
        $instance.save
      end        
      $instance
    end
    #checks whether it is the current application
    
    #create a new entry in the pool
    def add(resourceset)    
      raise ExploratorError.new('Must be a ResourceSet instance') if !resourceset.instance_of? EXPLORATOR::Set
      if instance.explorator::set == nil
        instance.explorator::set = [resourceset]
      else
        instance.explorator::set = instance.all_explorator::set | [resourceset]
      end
    end    
    #get a resource set
    def get(uri)        
      EXPLORATOR::Set.new(uri) 
    end    
    ##verifies whether the set was added in the pool
    def is_set?(uri)    
      if instance.explorator::set == nil
        return false
      end           
      instance.all_explorator::set.collect {|x| x.to_s }.include?(uri)      
    end    
    #gets the list of all sets from the current application
    def sets 
      all = instance.all_explorator::set       
      if all == nil
        Array.new        
      end
      all
    end
    #save the environment as an application. This will creates an EXPLORATOR::Application instance and add all 
    #set to it.
    def create(name)      
      xapp = EXPLORATOR::Application.new('http://www.tecweb.inf.puc-rio.br/application/id/' + name)
      xapp.save
      resources = instance.all_explorator::set
      xapp.explorator::set = resources
      xapp.rdfs::label=name 
      $instance = xapp     
    end
    #remove all set from the pool
    def clear      
      #remove each set by itself
      s= instance.all_explorator::set
      if s != nil
        s.each do |resource|
          apps = Query.new.distinct(:s).where(:s,:p,resource).execute         
          if apps.size == 1 
            SemanticExpression.new.delete(resource,nil,nil)
          end
        end
      end
      #remove the resources from the application
      instance.explorator::set = []
      instance.save      
    end     
    #load a saved application
    def load(uri)    
      puts "Loading ...  " + uri
      $instance = EXPLORATOR::Application.new(uri)  
      #puts  instance.all_explorator::set.size
    end
    #deletes an application
    def delete(uri)    
      #can not delete the current application
      if uri == instance.to_s       
        return false
      end
      app = EXPLORATOR::Application.new(uri)     
      app.all_explorator::set.each do |resource|
        #delete the set only whether is only referenced by the current application
        apps = Query.new.distinct(:s).where(:s,:p,resource).execute        
        if apps.size == 1 
          SemanticExpression.new.delete(resource,nil,nil)
        end
        
      end
      #remove the resources from the application
      SemanticExpression.new.delete(app,nil,nil)
      
      true
    end    
    #remove a specific resource set from the pool
    def remove(uri)      
      resource = EXPLORATOR::Set.new(uri)     
      #before remove store the set expression.     
      exp = resource.explorator::expression
      #remove the set from the application
      instance.explorator::set = instance.all_explorator::set - [resource] 
      #replace the expresssion in all expressions that used the set as parameter.
      #this is necessary for avoid missing reference.
      instance.all_explorator::set.each do |expset| 
        expset.explorator::expression=expset.explorator::expression.gsub("'" + uri + "'",exp) 
      end
      #remove the set by itself
       apps = Query.new.distinct(:s).where(:s,:p,resource).execute        
        if apps.size == 1 
          SemanticExpression.new.delete(resource,nil,nil)
        end      
      instance.save
    end     
  end  
end
