//Adds the selection behaviour to the  resources  used to build the query
function addOperationToQueryElements(){
    $('container').select('.select').each(function(item){
        item.observe('click', function(e){
            $$('.SELECTED').invoke('removeClassName', 'SELECTED');
            item.addClassName('SELECTED');
            if (!item.hasClassName('property')) {
                controller('nepomuk:!:selectNode:!:' + item.id);
            }
            else {
                controller('nepomuk:!:selectEdge:!:' + item.id);
            }
        });
    });
    $('container').select('.remove').each(function(item){
        item.observe('click', function(e){
            properties = item.up('.tuple').select('.property').reverse();
            properties.each(function(property){
                object = property.up('.tuple').down('.class');
                property.up('.tuple').remove();
            });
        });
    });
} 
//Adds the selection behaviour to all properties and classes
function querybuilderselection(){
    $$('.querybuilderresource').each(function(item){
        item.observe('click', function(e){
            if ($$('.SELECTED').size() > 1) {
                alert('Select only one resource.');
                return;
            }
            else 
                if ($$('.SELECTED').size() == 0) { 
                    return;
                }
            var selected = $$('.SELECTED').first();
            //Add a property and object for a resource selected.
            //If the resource is a property, just the value of this resource must be update.
            //  $$('.addproperty').each(function(item){
            if (item.hasClassName('literal')) {
                return;
            }
            if (selected.hasClassName('property') && item.hasClassName('class')) {
                         			
//                if (selected.hasClassName('datatypeproperty')) {
//                    object = "<div id = 'id3'  class=' _WINDOW literal resource select'><input type = 'text' onKeyUp='setLiteralValue(this)'; /> </div>"
//                }
				ajax_update(item.up("table").select(".relation").first(),'/querybuilder/relation?uri='  + Element.resource($$('.SELECTED').first()) );
                 
                ////////////////////////////////////////////////////////////
                //Select the last node  added
                $$('.SELECTED').invoke('removeClassName', 'SELECTED');
                //$('id3').addClassName('SELECTED');
                ////////////////////////////////////////////////////////// 
            }else  if (item.hasClassName('class') && $$('.SELECTED').first().hasClassName('class')) {
				 ajax_update(item.up(),'/querybuilder/resource?uri='  + Element.resource($$('.SELECTED').first()) );
            }
            else { 
               ajax_update(item.up(),'/querybuilder/resource?uri='  + Element.resource($$('.SELECTED').first()) );
            }  
			init_all();           
        });
    });
}
function curlbracket(){
    $$('.curlbracket').each(function(item){
        // if (item.up('tr').select('.relation').first().childElements().size() > 1) {
        if (item.next().childElements().size() > 1) {
            item.show();
        }
        else {
            item.hide();
        }
    });
} 
function setLiteral(input){
    Element.extend(input);    
} 
function filterValues(){
    var filterText = $('qbfilter').value;
    $('possibleNodes').select('div').each(function(item){
        if (item.innerHTML.indexOf(filterText) >= 0) 
            item.show();
        else 
            item.hide();
    });
    $('possibleEdges').select('div').each(function(item){
        if (item.innerHTML.indexOf(filterText) >= 0) 
            item.show();
        else 
            item.hide();
    });
}
