 
//Adds the selection behaviour to all properties and classes
function querybuilderselection(){
	  $$('.removerelation').each(function(item){
        item.onclick=function(e){			 
			 if (item.up('.relation') == undefined){
			 	item.up('.container').down('.relation').childElements().invoke('remove');
			 }
			 else{     
			 	item.up('.relation') .childElements().invoke('remove');}
				  e.stopPropagation();
        };
		curlbracket();
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
				ajax_insert(item.up("table").select(".relation").first(),'/querybuilder/relation?uri='  + Element.resource($$('.SELECTED').first()) );
                 
               
                $$('.SELECTED').invoke('removeClassName', 'SELECTED');
                
                ////////////////////////////////////////////////////////// 
            }else  if (item.hasClassName('class') && $$('.SELECTED').first().hasClassName('class')) {
				 ajax_update(item ,'/querybuilder/resource?uri='  + Element.resource($$('.SELECTED').first()) );
				  $$('.SELECTED').invoke('removeClassName', 'SELECTED');
            }
            else  if (item.hasClassName('property') && $$('.SELECTED').first().hasClassName('property')) {
               ajax_update(item ,'/querybuilder/property?uri='  + Element.resource($$('.SELECTED').first()) );
			    $$('.SELECTED').invoke('removeClassName', 'SELECTED');
            }  
			 curlbracket();
			init_all();           
        };
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