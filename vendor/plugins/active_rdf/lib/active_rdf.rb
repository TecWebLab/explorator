
require 'rubygems'

# ActiveRDF loader

# determine the directory in which we are running depending on cruby or jruby
file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))  


$: << this_dir + '/'
$: << this_dir + '/active_rdf/'

require 'active_rdf_helpers'
require 'active_rdf_log'

$activerdflog.info "ActiveRDF started, logging level: #{$activerdflog.level}"

# load standard classes that need to be loaded at startup
require 'objectmanager/resource'
require 'objectmanager/bnode'
require 'objectmanager/literal'
require 'objectmanager/namespace'
require 'federation/connection_pool'
require 'queryengine/query'
require 'federation/active_rdf_adapter'

def load_adapter s
  begin
    require s
  rescue Exception => e
    $activerdflog.info "could not load adapter #{s}: #{e}"
  end
end


# determine whether activerdf is installed as a gem:
if Gem::cache.search(/^activerdf$/).empty?
	# we are not running as a gem
	$activerdflog.info 'ActiveRDF is NOT installed as a Gem'
  	#load_adapter this_dir + '/../activerdf-rdflite/lib/activerdf_rdflite/rdflite'
  	#load_adapter this_dir + '/../activerdf-rdflite/lib/activerdf_rdflite/fetching'
  	#load_adapter this_dir + '/../activerdf-rdflite/lib/activerdf_rdflite/suggesting'
  	#load_adapter this_dir + '/../activerdf-redland/lib/activerdf_redland/redland'
  	load_adapter this_dir + '/../activerdf-sparql/lib/activerdf_sparql/sparql'
  	#load_adapter this_dir + '/../activerdf-yars/lib/activerdf_yars/jars2'	  
  
else
	# we are running as a gem
	require 'gem_plugin'
	$activerdflog.info 'ActiveRDF is installed as a Gem'
	GemPlugin::Manager.instance.load "activerdf" => GemPlugin::INCLUDE
end

