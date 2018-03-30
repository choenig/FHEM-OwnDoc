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
                 "<a href='#'>Documentation</a>" + 
                 "</div>";

$(document).ready(function() {
    $(ownDocLink).insertAfter("div.detLink.devSpecHelp");

    $("div.OwnDoc a").each(function() {       // Help on detail window
        var dev = FW_urlParams.detail;
        $(this).unbind("click");
        $(this).attr("href", "#"); // Desktop: show underlined Text
        $(this).removeAttr("onclick");

        if (!dev) return;

        $(this).click(function(evt) {
            if($("#OwnDoc").length) {
                $("#OwnDoc").remove();
                return;
            }
            $("#content").append('<div id="OwnDoc"></div>');
            FW_cmd(FW_root+'?cmd={AttrVal("'+dev+'","OwnDocumentation","")}&XHR=1', function(data) {
                if(!$("#OwnDoc").length) {
                    // FHEM slow, user clicked again, #68166
                    return;
                }
                if (data && data.length > 1) {
                    $("#OwnDoc").html(data);
                } else {
                    $("#OwnDoc").html("No OwnDoc-Documentation found.");
                }
            });
        });
    });
});
