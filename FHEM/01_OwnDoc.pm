##############################################
# $Id$
package main;

use strict;
use warnings;
use vars qw($FW_ME);
use SetExtensions;

my $OwnDoc_hasTextWikiFormat = 1;
my $OwnDoc_hasTextMarkdown   = 1;

sub OwnDoc_Initialize($)
{
    my ($hash) = @_;

    $hash->{DefFn}     = "OwnDoc_DefFn";
    $hash->{UndefFn}   = "OwnDoc_UndefFn";
    $hash->{GetFn}     = "OwnDoc_GetFn";
    $hash->{AttrList}  = "OwnDoc_addLinks:0,1 OwnDoc_format:WikiFormat,Markdown";

    addToAttrList(".OwnDocumentation:textField-long");
    
    eval "use Text::WikiFormat";
    $OwnDoc_hasTextWikiFormat = 0 if($@);

    eval "use Text::Markdown";
    $OwnDoc_hasTextMarkdown = 0 if($@);
}

###################################
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

###################################
sub OwnDoc_UndefFn($$) 
{
    my ($hash,$arg) = @_;
    my $name = $hash->{NAME};
  
    delete $data{FWEXT}{OwnDoc};
    return undef;
}

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
    else
    {
        return "Unknown argument $opt, choose one of wiki html";
    }
}

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
