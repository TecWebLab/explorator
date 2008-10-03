
//Adds the selection behaviour to all properties and classes
function querybuilderselection(){

    $$('.querybuildertool').each(function(item){
        item.onclick = function(e){
            ajax_create('SemanticExpression.new()');
            $('container').show();
        };
    });
    $$('.removerelation').each(function(item){
        item.onclick = function(e){
            if (item.up('.relation') == undefined) {
                item.up('.container').down('.relation').immediateDescendants().invoke('remove');
            }
            else {
                item.up('.tuple').remove();
            }
            e.stopPropagation();
        };
        curlbracket();
        refreshSet()
    });
    $$('.querybuilderresource').each(function(item){
        item.onclick = function(e){
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
                ajax_insert(item.up("table").select(".relation").first(), '/querybuilder/relation?uri=' + Element.resource($$('.SELECTED').first()));
                
                $$('.SELECTED').invoke('removeClassName', 'SELECTED');
                
                ////////////////////////////////////////////////////////// 
            }
            else 
                if (item.hasClassName('class') && $$('.SELECTED').first().hasClassName('class')) {
                    ajax_update(item, '/querybuilder/resource?uri=' + Element.resource($$('.SELECTED').first()));
                    $$('.SELECTED').invoke('removeClassName', 'SELECTED');
                }
                else 
                    if (item.hasClassName('property') && $$('.SELECTED').first().hasClassName('property')) {
                        ajax_update(item, '/querybuilder/property?uri=' + Element.resource($$('.SELECTED').first()));
                        $$('.SELECTED').invoke('removeClassName', 'SELECTED');
                    }
            curlbracket();
            refreshSet()
            init_all();
        };
    });
}

function refreshSet(){
    querybuilder()
    
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

//Builds the query from the tree (structure query builder).
function querybuilder(){
    var i = 0;
    var q = "SemanticExpression.new(Query.new.distinct(:s,:p,:o).where(:s,:p,:o).where(:s,RDF::type,:o).";
    var root = Element.resource($('container').down('.node'));
    q = q + "where(:s,RDF::type,RDFS::Resource.new('" + root + "'))";
    $('container').down('.relation').immediateDescendants().each(function(item){
        var o = "o" + i;
        q = q + ".where(:s,RDFS::Resource.new('" + Element.resource(item.down('.edge')) + "'),:" + o + ").";
        q = q + "where(:" + o + ",RDF::type,RDFS::Resource.new('" + Element.resource(item.down('.node')) + "'))";
        q = q + tree(item.down('.relation'), o);
        i++;
    });
    return q + ".execute)";   
}
function tree(relation, obj){
    var i = 0;
    var q = ""
    if (relation.down('.node') == undefined) 
        return q;
    relation.immediateDescendants().each(function(item){
        var o = obj + i;
        q = q + ".where(:" + obj + ",RDFS::Resource.new('" + Element.resource(item.down('.edge')) + "'),:" + o + ").";
        q = q + "where(:" + o + ",RDF::type,RDFS::Resource.new('" + Element.resource(item.down('.node')) + "'))";
        q = q + tree(item.down('.relation'), o);
        i++;
    });
    return q;
}
