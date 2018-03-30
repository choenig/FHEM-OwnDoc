//########################################################################################
// owndoc.js
// Version 1.0
// See 01_OwnDoc for licensing
//########################################################################################
//# Christian Hoenig

//------------------------------------------------------------------------------------------------------
// Determine csrfToken
//------------------------------------------------------------------------------------------------------

var req = new XMLHttpRequest();
req.open('GET', document.location.href, false);
req.send(null);
var csrfToken = req.getResponseHeader('X-FHEM-csrfToken');
if( csrfToken == null ){
    csrfToken = "null";
}

//------------------------------------------------------------------------------------------------------
// insert link
//------------------------------------------------------------------------------------------------------

var ownDocLink = "<div class='detLink OwnDoc'>" + 
                 "<a href='#'>Dokumentation</a>" + 
                 "</div>";


$(document).ready(function() {
    //$("div#ZWHelp").insertBefore("div.makeTable.internals"); // Move
    $(ownDocLink).insertAfter("div.detLink.devSpecHelp");
    // if(FW_tp) $("div.img.ZWPepper").appendTo("div#menu");
    // $("select.set,select.get").each(function(){
    //     $(this).get(0).setValueFn = function(val) {
    //         $("div#ZWHelp").html(val);
    //     }     
    //     $(this).change(function(){
    //         FW_queryValue('{ZWave_helpFn("'+zwaveDevice+'","'+$(this).val()+'")}',
    //                 $(this).get(0));
    //             });
    //         });
    //     });

});
