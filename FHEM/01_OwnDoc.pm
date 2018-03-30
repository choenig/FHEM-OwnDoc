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
}

###################################
sub OwnDoc_DefFn($$)
{
    my ($hash, $def) = @_;
    my @a = split("[ \t][ \t]*", $def);

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


#sub OwnDoc_fhemwebFn($$$$)
#{
#  my ($FW_wname, $d, $room, $pageHash) = @_; # pageHash is set for summaryFn.
#
#  my $js = "$FW_ME/pgm2/owndoc.js";
#
#  return "<script type='text/javascript' src='$js'></script>"
#}


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
