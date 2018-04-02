//########################################################################################
// owndoc.js
// Version 1.0
// See 01_OwnDoc for licensing
//########################################################################################
//# Christian Hoenig

function OwnDoc_cmd(cmd, fnc)
{
    FW_cmd(FW_root+'?XHR=1&cmd='+cmd, fnc);
}

//------------------------------------------------------------------------------------------------------
// updates the content of the divs for the given dev
//------------------------------------------------------------------------------------------------------
function OwnDoc_updateHtmlContent(div, dev) 
{
    OwnDoc_cmd('get TYPE=OwnDoc html ' + dev, function(data) {
        if(!$(div).length) {
            return; // FHEM slow, user clicked again, #68166
        }
        if (data && $.trim(data).length > 0) {
            $(div).html(data);
        } else {
            $(div).html("No OwnDoc-Documentation found.");
        }
        OwnDoc_scrollToContent(div);
    });
}

function OwnDoc_updateWikiContent(dev, codeMirror) 
{
    OwnDoc_cmd('get TYPE=OwnDoc wiki ' + dev, function(data) {
        if(!$("#OwnDocTextEdit").length) {
            return; // FHEM slow, user clicked again, #68166
        }
        if (data && $.trim(data).length > 0) {
            if(codeMirror) {
                codeMirror.setValue(data)
                $("#OwnDocTextEdit").val(codeMirror.getValue());
            } else {
                $("#OwnDocTextEdit").val(data);
            }
            OwnDoc_scrollToContent();
        } else {
            $("#OwnDocTextEdit").val("");
        }
    });
}

function OwnDoc_scrollToContent(div)
{
    var off = $(div).position().top-20;
    $('body, html').animate({scrollTop:off}, 500);
}

function OwnDoc_setupInHead(dev)
{
    $("#content > table > tbody > tr > td:first-child").prepend(
        '<div id="OwnDocInHead">' +
            '<span class="mkTitle">Documentation</span>' +
            '<a id="OwnDocInHeadShow" href="#" style="padding-left:10px;font-size:smaller;">Show</a>' +
            '<a id="OwnDocInHeadHide" href="#" style="padding-left:10px;font-size:smaller;display:none;">Hide</a>' +
            '<div id="OwnDocInHeadContent" style="display:none;">...</div>' +
        '</div>'
    );
    
    $("#OwnDocInHeadShow").each(function() {
        $(this).unbind("click");
        $(this).attr("href", "#"); // Desktop: show underlined Text
        $(this).removeAttr("onclick");

        $(this).click(function(evt) {
            $("#OwnDocInHeadContent").show();
            $("#OwnDocInHeadShow").hide();
            $("#OwnDocInHeadHide").show();
            OwnDoc_updateHtmlContent("#OwnDocInHeadContent", dev);
        });
    });

    $("#OwnDocInHeadHide").each(function() {
        $(this).unbind("click");
        $(this).attr("href", "#"); // Desktop: show underlined Text
        $(this).removeAttr("onclick");

        $(this).click(function(evt) {
            $("#OwnDocInHeadContent").hide();
            $("#OwnDocInHeadShow").show();
            $("#OwnDocInHeadHide").hide();
        });
    });
}

function OwnDoc_setupDetLink(dev)
{
    $("div.detLink.devSpecHelp").after(
        '<div class="detLink OwnDoc">' + 
        '<a href="#">Documentation</a>' + 
        '</div>'
    );

    $("div.OwnDoc a").each(function() {
        $(this).unbind("click");
        $(this).attr("href", "#"); // Desktop: show underlined Text
        $(this).removeAttr("onclick");

        $(this).click(function(evt) {
            // toggle
            if($("#OwnDoc").length) {
                $("#OwnDoc").remove();
                return;
            }
            
            // init structures
            $("#content").append(
                '<div id="OwnDoc">' +
                    '<a id="OwnDocEdit" href="#">Edit</a>' +
                    '<div id="OwnDocContent">...</div>' +
                    '<div id="OwnDocTextEditDiv" style="display:none">'+
                        '<a id="OwnDocSave" href="#">Save</a>&nbsp;&nbsp;&nbsp;' +
                        '<a id="OwnDocCancel" href="#">Cancel</a>' +
                        '<textarea id="OwnDocTextEdit" rows="25" cols="60" style="width:99%"/>'+
                    '</div>' +
                '</div>'
            );
            
            var cm;
            if(typeof AddCodeMirror == 'function') {
              AddCodeMirror($("#OwnDocTextEdit"), function(pcm) {cm = pcm;});
            }
            
            $("#OwnDocEdit").click(function(evt) {
                OwnDoc_updateWikiContent(dev, cm);
                $("#OwnDocEdit").hide();
                $("#OwnDocContent").hide();
                $("#OwnDocTextEditDiv").show();
            });
            $("#OwnDocSave").click(function(evt) {
                if (cm) $("#OwnDocTextEdit").val(cm.getValue());
                var doc=$("#OwnDocTextEdit").val();
                doc = $.trim(doc);
                doc = doc.replace(/\n/g, '\u2424' );
                doc = doc.replace(/;/g,  ';;' );
                doc = encodeURIComponent(doc);

                OwnDoc_cmd('attr ' + dev + ' .OwnDocumentation ' + doc, function(data) {
                    if (data.length > 0) {
                        alert(data);
                    } else {
                        OwnDoc_updateHtmlContent("#OwnDocContent", dev);
                        $("#OwnDocEdit").show();
                        $("#OwnDocContent").show();
                        $("#OwnDocTextEditDiv").hide();
                    }
                });

            });
            $("#OwnDocCancel").click(function(evt) {
                $("#OwnDocEdit").show();
                $("#OwnDocContent").show();
                $("#OwnDocTextEditDiv").hide();
                OwnDoc_scrollToContent();
            });

            OwnDoc_updateHtmlContent("#OwnDocContent", dev);
        });
    });
}

//------------------------------------------------------------------------------------------------------
// insert link
//------------------------------------------------------------------------------------------------------
$(document).ready(function()
{
    var dev = FW_urlParams.detail;
    if (!dev) return;

    OwnDoc_cmd('get TYPE=OwnDoc showHelpInHeader', function(data) {
        if ($.trim(data) == "1") {
            OwnDoc_setupInHead(dev);
        }
    });
    OwnDoc_setupDetLink(dev);
});
