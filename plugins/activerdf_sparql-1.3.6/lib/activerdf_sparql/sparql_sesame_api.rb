require 'rjb'

# SPARQL adapter
class SparqlSesameApiAdapter < ActiveRdfAdapter
  $activerdflog.info "loading SPARQL SESAME API adapter"
  
  ConnectionPool.register_adapter(:sparql_sesame_api, self)  
  attr_reader :caching  , :bridge
  def reset_cache()     
    @sparql_cache = {}
  end
  #  def SparqlAdapter.get_cache
  #    return @sparql_cache
  #  end
  
  # Instantiate the connection with the SPARQL Endpoint.
  # available parameters:
  # * :results => :sparql_xml
  def initialize(params = {})	
    super() 
    @sparql_cache = {}
    @reads = true
    @writes = false
    @caching = params[:caching] || false
    @result_format = :sparql_xml       
    @repository = params[:repository] 
    @sesamedir =params[:dir] 
    
    sesame_jars=''
    dir ="#{File.dirname(__FILE__)}/java/"
    Dir.foreach(dir) {|x|       
      sesame_jars += dir  + x +  File::PATH_SEPARATOR unless x.index('jar') == nil
    }   
    begin
      vmargs = [ '-Xms256m', '-Xmx1024m' ]
      vmargs << ('-Dinfo.aduna.platform.appdata.basedir=' + @sesamedir)
      Rjb::load sesame_jars , vmargs

    rescue => ex
      raise ex, "Could not load Java Virtual Machine. Please, check if your JAVA_HOME environment variable is pointing to a valid JDK (1.4+)."
      
    rescue LoadError => ex
      raise ex, "Could not load RJB. Please, install it properly with the command 'gem install rjb'"
    end        
  
    @bridge = Rjb::import('br.tecweb.explorator.SesameApiRubyAdapter').new(@repository)
  end  
  def size
    query(Query.new.select(:s,:p,:o).where(:s,:p,:o)).size
  end
 
  # query datastore with query string (SPARQL), returns array with query results
  # may be called with a block
  def query(query, &block)    
    qs = Query2SPARQL.translate(query)
    puts qs.to_s
    if @caching
      result = query_cache(qs)
      if result.nil?
        $activerdflog.debug "cache miss for query #{qs}"
      else
        $activerdflog.debug "cache hit for query #{qs}"
        return result
      end
    end    
    result = execute_sparql_query(qs,   &block)
    add_to_cache(qs, result) if @caching
    result = [] if result == "timeout"
    return result
  end
  
  # do the real work of executing the sparql query
  def execute_sparql_query(qs, header=nil, &block)    
    response = ''
    begin 
       
      response = @bridge.query(qs.to_s)
    #  puts response
    rescue 
      raise ActiveRdfError, "JAVA BRIDGE ERRO ON SPARQL ADAPTER"
      return "timeout"     
    end    
    # we parse content depending on the result format    
    results =  parse_xml(response)    
    if block_given?
      results.each do |*clauses|
        yield(*clauses)
      end
    else      
      results
    end
  end	
  def close
    ConnectionPool.remove_data_source(self)
  end	
  private
  def add_to_cache(query_string, result)
    unless result.nil? or result.empty?
      if result == "timeout"
        @sparql_cache.store(query_string, [])
      else 
        $activerdflog.debug "adding to sparql cache - query: #{query_string}"
        @sparql_cache.store(query_string, result) 
      end
    end
  end 
  def query_cache(query_string)    
    if @sparql_cache.include?(query_string)      
      return @sparql_cache.fetch(query_string)
    else
      return nil
    end
  end  
  # parse xml stream result into array
  def parse_xml(s)    
    parser = SparqlResultParser.new
    REXML::Document.parse_stream(s, parser) 
    parser.result
  end  
  # create ruby objects for each RDF node
  def create_node(type, value)
    case type
      when 'uri'
      RDFS::Resource.new(value)
      when 'bnode'
      BNode.new(value)
      when 'literal','typed-literal'
      value.to_s
    end
  end
  
end
