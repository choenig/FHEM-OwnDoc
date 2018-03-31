##############################################
# $Id$
package main;

use strict;
use warnings;
use vars qw($FW_ME);
use SetExtensions;

sub OwnDoc_Initialize($)
{
    my ($hash) = @_;

    $hash->{DefFn}     = "OwnDoc_DefFn";
    $hash->{UndefFn}   = "OwnDoc_UndefFn";
    $hash->{GetFn}     = "OwnDoc_GetFn";
    $hash->{AttrList}  = "OwnDoc_addLinks:0,1";

    addToAttrList(".OwnDocumentation:textField-long");
}

###################################
sub OwnDoc_DefFn($$)
{
    my ($hash, $def) = @_;
    my @a = split("[ \t][ \t]*", $def);

    eval { require Text::WikiFormat; };
    return "Please install Perl Text::WikiFormat to use module OwnDoc"
        if ($@);

    # check syntax
    if(int(@a) != 2) {
        return "Wrong syntax: use define <name> OwnDoc";
    }
  
    # check for single instance of OwnDoc
    my @ownDocDevices = devspec2array("TYPE=OwnDoc");
    if (int(@ownDocDevices) > 1) {
        return "Only one instance of OwnDoc is allowed per FHEM installation. Delete the old one first.";
    }

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
            my $htmltext = OwnDoc_toHtml($wikitext);
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

sub OwnDoc_toHtml($)
{
    my ($wikitext) = @_;

    my %tags = (
        strong_tag     => qr/\*(.+?)\*/,
        emphasized_tag => qr|(?<!<)/(.+?)/|,
    );
    my $htmltext = Text::WikiFormat::format($wikitext, \%tags, {
        implicit_links => 0
    });
    return $htmltext;

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
