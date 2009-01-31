require 'dataload.rb'
require 'query_builder.rb'
require 'query_factory.rb'
require 'explorator_application.rb'


#this adapter must be the last one added to the pool because It will be used as an write adapter by the activerdf
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/explorator.db', :reasoning => false,:keyword => true)
adapter = ConnectionPool.add_data_source :type => :sparql_sesame_api ,   :repository => 'WORK', :dir => $sesamedir.path
adapter.title='WORK'
 

