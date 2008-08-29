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
  def initialize(s=nil,p=nil,o=nil,r=:s)    
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
      s.result
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
  def spo(s,p,o,r=:s)     
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
    @result = @result | Query.new.distinct(:s).keyword_where(:s,k).execute | Query.new.distinct(:p).keyword_where(:p,k).execute | Query.new.distinct(:o).keyword_where(:o,k).execute
    self
  end  
  #Wrapper for the class ActiveRDF Query. This method executes a query and returns a set of resources.
  #With parameter must be a single resource.
  def query(s,p,o,r=:s) 
    #checks whether the s is a literal.   
    if isLiteral(s)      
      Array.new << to_resource(s,:s)
    else
      #These ifs are necessaries because SPARQL does not return a resource defined in the query.
      #For example, if you want to know whether john is married with mary, you must used the SPARQL's clause ASK
      #I use ASK here because I could not have the query like that in sparql: select s? where SOMERESOURCE p? ?o    
      #So, when I return the :s, :p or :o for a defined variable, I must use ASK and after return the specific resource.
      if s != nil && s != :s && r.to_sym ==:s ||  p != nil && p != :p && r.to_sym ==:p ||  o != nil && o != :o  && r.to_sym ==:o
        @flag = false
        # This loop is necessary because the ActiveRDF api returns an array of boolean representing the 
        # query response. ActiveRDF api does not return only false or true, but a boolean array.
        Query.new.ask.where(to_resource(s,:s),to_resource(p,:p), to_resource(o,:o)).execute.each do |x|
          if x == "true" || x == true
            @flag = true
          end
        end        
        if @flag
          Array.new << to_resource(eval(r.to_s),r.to_sym)
        else
          Array.new       
        end
      else     
        #Execute the query normally.
        q = Query.new.distinct(r.to_sym).where(to_resource(s,:s),to_resource(p,:p), to_resource(o,:o))
        q.execute
      end 
    end
  end 
  #Union method,
  #s - represents the s in the (s,p,o) triple or the set id or a SemanticExpression instance.
  #p - p in the triple
  #o - o in the triple
  #r - the position on the triple that should be returned.
  def union(s,p=nil,o=nil,r=:s)    
    if s.instance_of? SemanticExpression 
      @result = @result | s.result
      #Union, Intersection and Difference are operation over sets.
    elsif s.instance_of? Array 
      
      @result = @result | s 
    elsif Application.is_set?(s)
      #returns all set's resources
      @result = @result | Application.get(s).resources
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
  def intersection(s,p=nil,o=nil,r=:s)
    if s.instance_of? SemanticExpression 
      @result = @result & s.result      
      #Intersection, Intersection and Difference are operation over sets.
    elsif s.instance_of? Array 
      @result = @result & s      
      #Intersection, Intersection and Difference are operation over sets.      
    elsif Application.is_set?(s)
      #returns all set's resources
      @result = @result & Application.get(s).resources
      #Intersection method, passed as parameter a triple expression
    else
      @result = @result & query(s,p,o,r)
    end
    self
  end
  #Difference method
  #s - represents the s in the (s,p,o) triple or the set id 
  #p - p in the triple
  #o - o in the triple
  #r - the position on the triple that should be returned.
  def difference(s,p=nil,o=nil,r=:s)
    if s.instance_of? SemanticExpression 
      @result = @result - s.result   
    elsif s.instance_of? Array 
      @result = @result - s 
      #Difference, Intersection and Difference are operation over sets.
    elsif Application.is_set?(s)
      #returns all set's resources
      @result = @result - Application.get(s).resources
      #Difference method, passed as parameter a triple expression
    else
      @result = @result - query(s,p,o,r)
    end
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