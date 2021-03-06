########################################################################################
#
# OwnDoc.pm
#
# Add own documentation to devices in FHEM
# 
# Christian Hoenig
#
# $Id$
#
########################################################################################
#
#  This programm is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  The GNU General Public License can be found at
#  http://www.gnu.org/copyleft/gpl.html.
#  A copy is found in the textfile GPL.txt and important notices to the license
#  from the author is found in LICENSE.txt distributed with these scripts.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
########################################################################################
package main;

use strict;
use warnings;
use vars qw($FW_ME);

my $OwnDoc_hasTextWikiFormat = 1;
my $OwnDoc_hasTextMarkdown   = 1;

#------------------------------------------------------------------------------------------------------
# Initialize
#------------------------------------------------------------------------------------------------------
sub OwnDoc_Initialize($)
{
    my ($hash) = @_;

    $hash->{DefFn}     = "OwnDoc_DefFn";
    $hash->{UndefFn}   = "OwnDoc_UndefFn";
    $hash->{GetFn}     = "OwnDoc_GetFn";
    $hash->{AttrList}  = "OwnDoc_addLinks:0,1 OwnDoc_showHelpInHeader:0,1 OwnDoc_format:WikiFormat,Markdown";

    addToAttrList(".OwnDocumentation:textField-long");
    
    eval "use Text::WikiFormat";
    $OwnDoc_hasTextWikiFormat = 0 if($@);

    eval "use Text::Markdown";
    $OwnDoc_hasTextMarkdown = 0 if($@);
}

#------------------------------------------------------------------------------------------------------
# Define
#------------------------------------------------------------------------------------------------------
sub OwnDoc_DefFn($$)
{
    my ($hash, $def) = @_;
    my @a = split("[ \t][ \t]*", $def);

    if (!$OwnDoc_hasTextWikiFormat && !$OwnDoc_hasTextMarkdown) {
        return "Please install Text::WikiFormat or Text::Markdown to use module OwnDoc"
    }

    # check syntax
    if(int(@a) != 2) {
        return "Wrong syntax: use define <name> OwnDoc";
    }
  
    # check for single instance of OwnDoc
    my @ownDocDevices = devspec2array("TYPE=OwnDoc");
    if (int(@ownDocDevices) > 1) {
        return "Only one instance of OwnDoc is allowed per FHEM installation. Delete the old one first.";
    }

    $hash->{HAS_TextWikiFormat} = $OwnDoc_hasTextWikiFormat;
    $hash->{HAS_TextMarkdown  } = $OwnDoc_hasTextMarkdown;
    $hash->{STATE}              = 'Initialized';

    $data{FWEXT}{OwnDoc}{SCRIPT} = "owndoc.js";
    return undef;
}

#------------------------------------------------------------------------------------------------------
# Undefine
#------------------------------------------------------------------------------------------------------
sub OwnDoc_UndefFn($$) 
{
    my ($hash,$arg) = @_;
    my $name = $hash->{NAME};
  
    delete $data{FWEXT}{OwnDoc};
    return undef;
}

#------------------------------------------------------------------------------------------------------
# Get
#------------------------------------------------------------------------------------------------------
sub OwnDoc_GetFn($$@)
{
	my ($hash, $name, $opt, @args) = @_;
    return "\"get $name\" needs at least one argument" unless(defined($opt));

    if($opt eq "wiki" || $opt eq "html") 
    {
        if (int(@args) != 1) {
            return "usage: \"get $name $opt DEVICE\"";
        }
        my $dev = $args[0];
        my $wikitext = AttrVal($dev, '.OwnDocumentation', "");
        
        if ($opt eq "wiki") {
            return $wikitext;
        } else {
            my $htmltext = OwnDoc_toHtml($name, $wikitext);
            if (AttrVal($name, "OwnDoc_addLinks", "1") eq "1") {
                $htmltext = FW_addLinks($htmltext);
            }
            return $htmltext;
        }
    }
    elsif ($opt eq "showHelpInHeader") {
        return AttrVal($name, "OwnDoc_showHelpInHeader", "0");
    }
    else
    {
        return "Unknown argument $opt, choose one of wiki html showHelpInHeader";
    }
}

#------------------------------------------------------------------------------------------------------
# Converts wiki text to html for output
#------------------------------------------------------------------------------------------------------
sub OwnDoc_toHtml($$)
{
    my ($name, $wikitext) = @_;
    
    my $defaultFormat = "";
    $defaultFormat = "WikiFormat" if ($OwnDoc_hasTextWikiFormat);
    $defaultFormat = "Markdown"   if ($OwnDoc_hasTextMarkdown);
    
    my $selectedFormat = AttrVal($name, "OwnDoc_format", $defaultFormat);
    if ($selectedFormat eq "") {
        return "Error: could not determine valid OwnDoc_format, please install appropriate modules."
    }
    if ($selectedFormat eq "WikiFormat" && !$OwnDoc_hasTextWikiFormat ||
        $selectedFormat eq "Markdown"   && !$OwnDoc_hasTextMarkdown)
    {
        return "Error: OwnDoc_format '$selectedFormat' not supported."
    }
    
    if ($selectedFormat eq "WikiFormat") {
        my %tags = (
            strong_tag     => qr/\*(.+?)\*/,
            emphasized_tag => qr|(?<!<)/(.+?)/|,
        );
        my $htmltext = Text::WikiFormat::format($wikitext, \%tags, {
            implicit_links => 0
        });
        return $htmltext;
    }

    if ($selectedFormat eq "Markdown") {
        my $markdown = Text::Markdown->new;
        my $htmltext = $markdown->markdown($wikitext);
        return $htmltext;
    }
    
    return "Error: Could not determine valid OwnDoc_format";
}


1;

=pod
=item helper
=item summary    Documentation
=item summary_DE Dokumentation
=begin html

<a name="OwnDoc"></a>
<h3>OwnDoc</h3>
<ul>
</ul>

=end html

=begin html_DE

<a name="OwnDoc"></a>
<h3>OwnDoc</h3>
<ul>
</ul>

=end html_DE

=cut
