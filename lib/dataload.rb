require "date"
require "logger"
#This module loads the adapters.
#Each adapter has a connection with a repository.
#See the ActiveRDF documentation for further references.
#Author: Samur Araujo
#Date: 25 jun 2008.

require 'active_rdf' 
def createdir(dir)
  Dir.mkdir("db/" + dir) unless File.directory?("db/" + dir)
end
#$activerdflog.level = Logger::DEBUG
#Keep track of all repositories registered in the pool

#dir = File.dirname(File.expand_path(__FILE__))
dbdir = Dir.pwd +  File::SEPARATOR + 'db'

#ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8087/openrdf-sesame/repositories/TESTE", :results => :sparql_xml
#ConnectionPool.add_data_source :type => :sesame, :name=>:teste
#

#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8181/org.semanticdesktop.services.rdfrepository/repositories/main", :results => :sparql_xml, :caching =>true
#adapter.title='NEPOMUK_SPARQL'

$sesamedir = Dir.new(dbdir + File::SEPARATOR + 'Sesame' + File::SEPARATOR + "repositories")
$sesamedir.each  do |x| 
  
  if x.rindex('.') == nil && x!= ('SYSTEM') && x!= ('INTERNAL') 
    
    adapter = ConnectionPool.add_data_source :type => :sparql_sesame_api ,  :caching =>true, :repository => x, :dir => $sesamedir.path
    adapter.title=x + '_LOCAL'    
  end
end

#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/PRESIDENT", :results => :sparql_xml, :caching =>true
#adapter.title='PRESIDENT_PARALLAX_DEFAULT'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/NOKIA", :results => :sparql_xml, :caching =>true
#adapter.title='NOKIA_DEFAULT'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/MONDIAL", :results => :sparql_xml, :caching =>true
#adapter.title='MONDIAL_DEFAULT'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/CIA", :results => :sparql_xml, :caching =>true
#adapter.title='CIA_DEFAULT'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/METAMODEL", :results => :sparql_xml, :caching =>true
#adapter.title='METAMODEL_SPARQL'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/FACETO", :results => :sparql_xml, :caching =>true
#adapter.title='FACETO_DEFAULT'
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://data.linkedmdb.org/sparql", :results => :sparql_xml, :caching =>true
#adapter.title='IMDB_SPARQL'


adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :virtuoso, :url => "http://139.82.71.60:8890/sparql", :results => :sparql_xml, :caching =>true
adapter.title='DBPEDIA_LOCAL'


#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://dbtune.org:2105/sparql/", :results => :sparql_xml
#adapter.title='BDTune'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://spade.lbl.gov:2020/sparql", :results => :sparql_xml
#adapter.title='Spade'

 
#You should insert here a line for each namespace that you want to use in your application.
#The namespace must be unique. If you have doubt please see the ActiveRDF documentation.
Namespace.register(:dp1, 'http://sw.nokia.com/DP-1/')
Namespace.register(:fn1, 'http://sw.nokia.com/FN-1/')
Namespace.register(:mars, 'http://sw.nokia.com/MARS-3/')
Namespace.register(:voc1, 'http://sw.nokia.com/VOC-1/')
Namespace.register(:fntype, 'http://sw.nokia.com/FN-1/Type/')
Namespace.register(:sesame, 'http://www.openrdf.org/schema/sesame#')
Namespace.register(:dc, 'http://purl.org/dc/elements/1.1/')
Namespace.register(:dcterms, 'http://purl.org/dc/terms/')
Namespace.register(:editor, 'http://sw.nokia.com/Editor-1/')
Namespace.register(:webarch, 'http://sw.nokia.com/WebArch-1/')
Namespace.register(:faceto, 'http://www.semanticnavigation.org/2008/faceto#')
Namespace.register(:explorator, 'http://www.explorator.org/2008/explorator#')
Namespace.register(:foaf, 'http://xmlns.com/foaf/0.1/')
Namespace.register(:dbpedia, 'http://dbpedia.org/resource/')
Namespace.register(:imdb, 'http://www.imdb.org/')
Namespace.register(:wn, 'http://www.w3.org/2006/03/wn/wn20/schema/')

Namespace.register(:explorator, 'http://www.tecweb.inf.puc-rio.br/ontologies/2008/explorator/01/core#')

Namespace.register(:imdb2, 'http://wwwis.win.tue.nl/~ppartout/Blu-IS/Ontologies/IMDB/')

Namespace.register(:oddlinker, "http://data.linkedmdb.org/resource/oddlinker/")
Namespace.register(:map, "file:/C:/d2r-server-0.4/mapping.n3#")
Namespace.register(:db, "http://data.linkedmdb.org/resource/")
Namespace.register(:skos,"http://www.w3.org/2004/02/skos/core#")
Namespace.register(:moviedmdb,"http://data.linkedmdb.org/resource/movie/")
Namespace.register(:omdb,"http://triplify.org/vocabulary/omdb#")
Namespace.register(:movie,"http://triplify.org/vocabulary/movie#")
Namespace.register(:mondial,"http://www.semwebtech.org/mondial/10/meta#")

RDFS::Resource.find_all_predicates

# construct the necessary Ruby Modules and Classes to use the Namespace
ObjectManager.construct_classes
