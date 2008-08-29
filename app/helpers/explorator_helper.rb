#The Explorator Helper has several methods used by the files.rhtml.
#Basically, Its methods help the view to hender a RDFS::Resource.
#Author: Samur Araujo
#Date: 25 jun 2008.
module ExploratorHelper
  include RenderHelper
  #Returns a resourceset define in the controllers.
  def resourceset     
    @resourceset
  end 
  #return an interval of resources from the offset to the pagination attribute.
  #This method is used when the user is paginating a set of resources
  def get_resources_paginated      
    @resourceset.resources[@resourceset.offset.to_i,@resourceset.pagination.to_i]   
     
  end
  
  #Return an array of resources.
  def get_resources
    @resourceset.resources
  end
  #Return a resource set expression. 
  def get_expression       
    @resourceset.explorator::expression
  end
  #return the predicates defined by the properties method. 
  def get_predicates
    properties  
  end
  #This method only is invocated when the view is rendering one and only one resource.
  #It is used to retrieve all properties/values from the resource.
  #visualize the resources and all its properties.
  def properties     
    predicates = Hash.new
    if @resourceset.resources.size != 1
      return  predicates
    end   
    if @resourceset.resources[0].class == String
      return predicates
    end
    
    #returns all predicates and objects of this resource.
    
    #    resource= Query.new.select(:p,:o).where(@resourceset.resources[0],:p,:o).execute    
    #    resource.each do |p,o|
    #      predicates[p]=Array.new if predicates[p]==nil
    #      predicates[p] << o if (o != nil && o.to_s.length > 0)
    #    end    
    
    @resourceset.resources[0].get_properties
  end  
  
 
  #return the uri as a string
  def to_s(resource)     
    return resource if (resource.instance_of? String)    
    return resource.uri if (resource.instance_of? RDFS::Resource) 
  end
  #Resource URI
  def uri (resource)            
    return resource.to_s.gsub("'","\\\\'")  if  (resource.instance_of? RDFS::Literal)    
    return resource.gsub("'","\\\\'")  if  (resource.instance_of? String)    
    
    return resource 
  end
  #this will be added in the class attribute of the html element.
  #return a string of all resource types separated by space.
  def css(resource)       
    if resource.instance_of? String
      return ' resource string'
    end  
    if resource.instance_of? BNode
      return ' resource '
    end     
    
    classes = Array.new  
    
    resource.type.each do |type|
      classes <<   type.localname.downcase
    end    
    classes.uniq.join(' ') << ' '
  end
  #verifies whether the resource is from type class.
  def is_class(resource)
    if resource.instance_of? String
      return false
    end    
    resource.type.each do |type|
      if type.localname.downcase == 'class'
        return true
      end
    end
    return false
  end  
end
