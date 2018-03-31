//########################################################################################
// owndoc.js
// Version 1.0
// See 01_OwnDoc for licensing
//########################################################################################
//# Christian Hoenig

//------------------------------------------------------------------------------------------------------
// updates the content of the divs for the given dev
//------------------------------------------------------------------------------------------------------
function OwnDoc_updateContent(dev) 
{
    FW_cmd(FW_root+'?cmd=get TYPE=OwnDoc html '+dev+'&XHR=1', function(data) {
        if(!$("#OwnDocContent").length) {
            return; // FHEM slow, user clicked again, #68166
        }

        if (data && data.length > 1) {
            $("#OwnDocContent").html(data);
            var off = $("#OwnDocContent").position().top-20;
            $('body, html').animate({scrollTop:off}, 500);
        } else {
            $("#OwnDocContent").html("No OwnDoc-Documentation found.");
        }
    });

    FW_cmd(FW_root+'?cmd=get TYPE=OwnDoc wiki '+dev+'&XHR=1', function(data) {
        if(!$("#OwnDocTextEdit").length) {
            return; // FHEM slow, user clicked again, #68166
        }
        if (data && data.length > 1) {
            // data = data.replace(/\u2424/g, '<br/>');
            $("#OwnDocTextEdit").val(data);
        } else {
            $("#OwnDocTextEdit").val("");
        }
    });
}

//------------------------------------------------------------------------------------------------------
// Determine csrfToken
//------------------------------------------------------------------------------------------------------

// var req = new XMLHttpRequest();
// req.open('GET', document.location.href, false);
// req.send(null);
// var csrfToken = req.getResponseHeader('X-FHEM-csrfToken');
// if( csrfToken == null ){
//     csrfToken = "null";
// }

//------------------------------------------------------------------------------------------------------
// insert link
//------------------------------------------------------------------------------------------------------

$(document).ready(function() {
    $("div.detLink.devSpecHelp").after(
        "<div class='detLink OwnDoc'>" + 
        "<a href='#'>Documentation</a>" + 
        "</div>"
    );

    $("div.OwnDoc a").each(function() {       // Help on detail window
        $(this).unbind("click");
        $(this).attr("href", "#"); // Desktop: show underlined Text
        $(this).removeAttr("onclick");

        var dev = FW_urlParams.detail;
        if (!dev) return;

        $(this).click(function(evt) {
            // toggle
            if($("#OwnDocContent").length) {
                $("#OwnDoc").remove();
                return;
            }
            
            // init structures
            $("#content").append(
                '<div id="OwnDoc">' +
                    '<div id="OwnDocContent">...</div>' +
                    '<a id="OwnDocEdit" href="#">Edit</a>' +
                    '<div id="OwnDocTextEditDiv" style="display:none">'+
                        '<textarea id="OwnDocTextEdit" rows="25" cols="60" style="width:99%"/>'+
                        '<a id="OwnDocSave" href="#">Save</a>&nbsp;&nbsp;&nbsp;' +
                        '<a id="OwnDocCancel" href="#">Cancel</a>' +
                    '</div>' +
                '</div>'
            );
            
            var cm;
            if(typeof AddCodeMirror == 'function') {
              AddCodeMirror($("#OwnDocTextEdit"), function(pcm) {cm = pcm;});
            }
            
            $("#OwnDocEdit").click(function(evt) {
                $("#OwnDocEdit").hide();
                $("#OwnDocContent").hide();
                $("#OwnDocTextEditDiv").show();
            });
            $("#OwnDocSave").click(function(evt) {
                if (cm) $("#OwnDocTextEdit").val(cm.getValue());
                var doc=$("#OwnDocTextEdit").val();
                doc = doc.replace(/\n/g, '\u2424' );

                FW_cmd(FW_root+'?XHR=1&cmd.=attr '+dev+' OwnDocumentation ' + doc, function(data) {
                    if (data.length > 0) {
                        alert(data);
                    } else {
                        $("#OwnDocEdit").show();
                        $("#OwnDocContent").show();
                        $("#OwnDocTextEditDiv").hide();
                        OwnDoc_updateContent(dev);
                    }
                });

            });
            $("#OwnDocCancel").click(function(evt) {
                $("#OwnDocContent").html("...");
                $("#OwnDocEdit").show();
                $("#OwnDocContent").show();
                $("#OwnDocTextEditDiv").hide();
            });

            OwnDoc_updateContent(dev);
        });
    });
});
