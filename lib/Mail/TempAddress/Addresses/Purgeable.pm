package Mail::TempAddress::Addresses::Purgeable;

use strict;
use Carp 'croak';

use Mail::TempAddress::Addresses '0.53';
use vars '@ISA';
push @ISA, 'Mail::TempAddress::Addresses';

use Mail::TempAddress::Address;

use vars '$VERSION';
$VERSION = 0.11;
 
use Fcntl ':flock';

use Cwd;

sub purge
{

    my $self = shift;

    my $min_ts;
    if( my $min_age = shift  ) {
        my $subtract = Mail::TempAddress::Address->process_time( $min_age );
        $min_ts = time() - $subtract;
    }
    else {
        $min_ts = time();
    }

    my $purged = 0;
    for( $self->addresses ) {
        my $addy = $self->fetch( $_ );
        my $expires = $addy->expires();
        if( $expires && $expires < $min_ts ) {
            my $file = $self->address_file( $_ );
            open( OUT, '+< ' . $file ) or croak "Cannot lock '$file': $!";
            flock OUT, LOCK_EX;
            unlink($file) && $purged++;
        }
    }
    
    return $purged;

}

sub addresses
{

    my $self = shift;
    my $cwd = cwd();
    chdir($self->address_dir());
    my $extension = $self->address_extension();
    my @files = glob("*.$extension");
    for( @files ) { s/\.$extension// }
    chdir($cwd);
    return wantarray ? @files : \@files;

}

1;

__END__

=head1 NAME

Mail::TempAddress::Addresses::Purgeable - manage and purge
Mail::TempAddress::Address objects

=head1 SYNOPSIS

  use Mail::TempAddress::Addresses::Purgeable;
  my $addresses = Mail::TempAddress::Addresses::Purgeable(
    '.addresses'
  );
  
=head1 DESCRIPTION

Mail::TempAddress::Addresses::Purgeable extends
Mail::TempAddress::Addresses to provide the ability to purge
expired address data files.

=head1 METHODS

=over 4

=item * purge( [ $min_expired_age ] )

The B<purge> method iterates through each data file found in the
addresses directory.  Each data file is loaded into a
Mail::TempAddress::Address object and it's expiry date (if any) is
compared against the current time.  Any object which is expired will have
it's data file removed from the filesystem.

By default each object need only be expired.  Passing the
$min_expired_age requires that the object have been expired for at least
that many seconds.  The minimum age may also be passed using a freeform
expression like '1h30m' or '2m1w'.  See L<Mail::TempAddress/"Expires"> for
more details.

For example, if an address object is set to expire at Mon Oct 27 19:31:39
2003 and the purge() routine is run at 19:33 with an argument of 300, then
the data file for the object will not be deleted.  If the purge method were
to be called at 19:36:40 or any time thereafter then the data file will be
deleted.

=item * addresses()

The <data_files> method returns a list or list reference (depending on
calling context) of the addresses in the address directory.

=back

=head1 AUTHOR

James FitzGibbon E<lt>jfitz@CPAN.ORGE<gt>

=head1 TODO

Major things.  chromatic's modules Mail::TempAddress and Mail::SimpleList
have large quantities of similar code and he plans to factor that out into a
separate base class.  Once that happens, the functionality provided by this
module would better be implemented as a mixin (see L<mixin>).

=head1 COPYRIGHT

Copyright (c) 2003, James FitzGibbon.  All rights reserved.  This module
is distributed under the same terms as Perl itself.
