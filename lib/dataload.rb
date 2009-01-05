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
 
dir = File.dirname(File.expand_path(__FILE__))


#ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8087/openrdf-sesame/repositories/TESTE", :results => :sparql_xml
#ConnectionPool.add_data_source :type => :sesame, :name=>:teste
#

#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8181/org.semanticdesktop.services.rdfrepository/repositories/main", :results => :sparql_xml, :caching =>true
#adapter.title='NEPOMUK_SPARQL'


adapter =ConnectionPool.add_data_source :type => :sparql_sesame_api ,  :caching =>true
adapter.title='EXPLORATOR_DEFAULT'

adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/NOKIA", :results => :sparql_xml, :caching =>true
adapter.title='NOKIA_DEFAULT'

adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/MONDIAL", :results => :sparql_xml, :caching =>true
adapter.title='MONDIAL_DEFAULT'

adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/CIA", :results => :sparql_xml, :caching =>true
adapter.title='CIA_DEFAULT'

adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/METAMODEL", :results => :sparql_xml, :caching =>true
adapter.title='METAMODEL_SPARQL'

adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://localhost:8080/openrdf-sesame/repositories/FACETO", :results => :sparql_xml, :caching =>true
adapter.title='FACETO_DEFAULT'
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://data.linkedmdb.org/sparql", :results => :sparql_xml, :caching =>true
#adapter.title='IMDB_SPARQL'


#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :virtuoso, :url => "http://www.w3c.es/Prensa/sparql/", :results => :sparql_xml, :caching =>true
#adapter.title='REVYU'


#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://dbtune.org:2105/sparql/", :results => :sparql_xml
#adapter.title='BDTune'
#
#adapter =ConnectionPool.add_data_source :type => :sparql,:engine => :sesame2, :url => "http://spade.lbl.gov:2020/sparql", :results => :sparql_xml
#adapter.title='Spade'

#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/semanticweb/semanticweb.db', :reasoning => false,:keyword => true)
#adapter.title='SEMANTICWEB'
#adapter.load('lib/semanticweb.nt')
#createdir("cia")
#adapter = ConnectionPool.add( :type => :rdflite, :location => 'db/cia/cia.db', :reasoning => false,:keyword => false)
#adapter.title='CIA'
#
#
##adapter.load('lib/cia.nt')
#createdir("terrorist")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/terrorist/terrorist.db', :reasoning => false,:keyword => true)
#adapter.title='TERRORIST'
#
#
#createdir("mondial")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/mondial/mondial.db', :reasoning => false,:keyword => true)
#adapter.title='MONDIAL'
#
##adapter.load('lib/mondial.nt')
#
#createdir("portinari")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/portinari/portinari.db', :reasoning => false,:keyword => true)
#adapter.title='PORTINARI'
#
#
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/rdfexplot.db', :reasoning => false,:keyword => true)
#adapter.title='DBLP 500MB'
#
#createdir("nokia")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/nokia/nokia.db', :reasoning => false,:keyword => true)
#adapter.title='Nokia'
##adapter.load('public/data/nokia.nt')
#
#
#createdir("wn")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/wn/wn.db', :reasoning => false,:keyword => false)
#adapter.title='WordNet'
##adapter.load('public/data/wn.nt.001')
#
#createdir("www2008")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/www2008/www.db', :reasoning => false,:keyword => true)
#adapter.title='WWW 2008'
##adapter.load('lib/www2008.nt')
# 
#createdir("eswc") 
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/eswc/eswc.db', :reasoning => false,:keyword => true)
#adapter.title='ESWC 2008'
##adapter.load('lib/eswc2008.nt')
#createdir("explorator")
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/metamodel/metamodel.db', :reasoning => false,:keyword => true)
#adapter.title='METAMODEL'
#adapter.load('public/data/metamodel.nt')

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
 