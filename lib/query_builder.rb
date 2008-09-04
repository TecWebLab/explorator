require "date"
#SemanticExpression is a DSL designed for the Explorator.
#This class implements the operation meta-model defined in the specification
#The following operation were implemented.
# union - operation over set
# intersection - operation over set
# difference - operation over set
# spo - semantic operation defined in the Explorator meta-model.
# keyword - search by keyword 
#Author: Samur Araujo
#Date: 25 jun 2008.
require 'active_rdf'
class SemanticExpression
  #:result - It is a array of RDFS::Resource.
  attr_accessor  :result  
  #constructor.
  def initialize(s=nil,p=nil,o=nil,*r)    
    # initialize the variable query with the ActiveRDF Query
    @result = Array.new   
    if s != nil || p != nil || o != nil
      union(s,p,o,r)
    end
  end   
  #This method return an array of resource, no matter what was passed as parameter.
  #  This method is necessary because the spo can be called passing a ResourceSet id as parameters.
  def resource_or_set_to_array(s)
    if s == nil
      Array.new 
    elsif Application.is_set?(s)
      Application.get(s).resources
    else
      Array.new << s 
    end
  end
  #
  #returns a array of resource. Sometimes the parameter s could be a SemanticExpression instance.
  def resource_or_self(s)
    if s == nil
      Array.new 
    elsif s.instance_of? SemanticExpression
      s.result.collect {|s,p,o| s}.compact.uniq
    else
      Array.new << s 
    end
  end
  #This method is executes a semantic operation.
  #Keep in mind that this method could receive as parameter a resource, an array of resources or a SemanticExpression instance, in the
  # parameters s, p or o.
  # the parameter r is the variable in the triple that should be gathered.
  #the same method as query, but it is able to treat arrays.
  #This methos
  def spo(s,p,o,*r)     
    result = Array.new 
    s = resource_or_self(s)
    p = resource_or_self(p)
    o = resource_or_self(o)
    s.each do |x|
      p.each do |y|
        o.each do |z|
          result |= query(x,y,z,r)
        end        
      end     
    end    
    @result = @result | result
    self
  end
  #adds keyword query to the expression
  def keyword(k)   
    r = [:s,:p,:o]
    @result = @result | Query.new.distinct(r).keyword_where(:s,k).execute | Query.new.distinct(r).keyword_where(:p,k).execute | Query.new.distinct(r).keyword_where(:o,k).execute
    self
  end  
  #Wrapper for the class ActiveRDF Query. This method executes a query and returns a set of resources.
  #With parameter must be a single resource.
  def query(s,p,o,*r)   
    if r == nil
      r = [:s,:p,:o]
    end          
    q = Query.new.distinct(:s,:p,:o).where(:s,:p,:o).filter(get_filter(s,:s)).filter(get_filter(p,:p)).filter(get_filter(o,:o))
    q.execute       
  end   
  def get_filter(value,symbol)
    if value == symbol
      nil
    else
      str = '?' + symbol.to_s + ' = ' + value.to_s
      
      str
    end
  end
  
  #Union method,
  #s - represents the s in the (s,p,o) triple or the set id or a SemanticExpression instance.
  #p - p in the triple
  #o - o in the triple
  #r - the position on the triple that should be returned.
  def union(s,p=nil,o=nil,*r)    
    if s.instance_of? SemanticExpression 
      @result = @result | s.result
      #Union, Intersection and Difference are operation over sets.
    elsif s.instance_of? Array       
      @result = @result | s 
    elsif Application.is_set?(s)
      #returns all set of resources
      @result = @result | Application.get(s).elements
      #Union method, passed as parameter a triple expression
    else
      @result = @result | query(s,p,o,r)
    end
    self
  end
  #Intersection method 
  #s - represents the s in the (s,p,o) triple or the set id 
  #p - p in the triple
  #o - o in the triple
  #r - the position on the triple that should be returned.
  def intersection(s,p=nil,o=nil,*r)
    tmp = @result
    if s.instance_of? SemanticExpression 
      tmp =  s.result      
      #Intersection, Intersection and Difference are operation over sets.
    elsif s.instance_of? Array 
      tmp =  s      
      #Intersection, Intersection and Difference are operation over sets.      
    elsif Application.is_set?(s)
      #returns all set of resources
      tmp =  Application.get(s).elements
      #Intersection method, passed as parameter a triple expression
    else
      tmp =  query(s,p,o,r)
    end
    #@result = @result & tmp - The intersection is between the subjects and it is not between triples.
    a = tmp.collect{|s,p,o| s}
    @result = @result.collect { |s,p,o| [s,p,o] if a.include?(s) } 
    self
  end
  #Difference method
  #s - represents the s in the (s,p,o) triple or the set id 
  #p - p in the triple
  #o - o in the triple
  #r - the position on the triple that should be returned.
  def difference(s,p=nil,o=nil,*r)
    tmp = Array.new
    if s.instance_of? SemanticExpression 
      tmp =  s.result   
    elsif s.instance_of? Array 
      tmp =  s 
      #Difference, Intersection and Difference are operation over sets.
    elsif Application.is_set?(s)
      #returns all set of resources
      tmp = Application.get(s).elements
      #Difference method, passed as parameter a triple expression
    else   
      tmp =  query(s,p,o,r)
    end
       #@result = @result & tmp - The difference is between the subjects and it is not between triples.
     a = tmp.collect{|s,p,o| s}
     @result = @result.collect { |s,p,o| [s,p,o] if !a.include?(s) } 
 
    self
  end   
  #this method applies a filter to the result of the expression.
  #note that we are not using the sparql filter, we are applying the filter directly in the ruby objects. 
  #This was decided because some adapters could ever implement any kind of filters.
  def filter (exp) 
    begin 
      @result =  eval('@result.' + exp)      
    rescue
      return self
    end
    if !@result.instance_of? Array
      @result = (Array.new <<       @result.to_s) 
    end
    self    
  end
  #delete triples in the repositories
  def delete(s,p,o)    
    ConnectionPool.write_adapter.delete(s,p,o)    
  end
  #Verifies whether the variable is a resource
  # It could receive 3 parameter types: Literal, a Symbol or a Resource. All in string format.
  def isLiteral(r)        
    if r != nil && !(r.instance_of? Symbol) && !(r.instance_of? BNode) && !(r.instance_of? RDFS::Resource)&& r[0] != 60 && r[0..1] !="_:" # 60 is the ascii code for '<'
      return true
    end
    return false
  end
  #The to_resource method is necessary because the ActiveRDF Query only accept a RDFS::Resource, a Literal(String) or a Ruby Symbol as parameter.
  #Convert a string to RDFS:Resource or symbol. The String should be in the format: "SOME TEXT"
  def to_resource(term,symbol)   
    if term == symbol
      return term
    elsif term == nil
      symbol.to_sym
    elsif term.instance_of? BNode 
      term
    elsif term.instance_of?(RDFS::Resource)
      term
    elsif term[0..1]=="_:"
      BNode.new term[2..term.size]
    elsif term[0] == 60
      RDFS::Resource.new term 
    else
      term 
    end   
  end  
  
end