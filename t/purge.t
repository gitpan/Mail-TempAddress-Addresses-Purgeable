#!/usr/bin/perl -w

BEGIN
{
    chdir 't' if -d 't';
    use lib '../lib', '../blib/lib';
}

use strict;

use Test::More 'no_plan';

use File::Path;

mkdir 'addresses' unless -d 'addresses';

END
{   
    rmtree 'addresses' unless @ARGV;
}

my $module = 'Mail::TempAddress::Addresses::Purgeable';
use_ok( $module ) or exit;

can_ok( $module, 'new' );
my $addys = $module->new( 'addresses' );
isa_ok( $addys, $module );

# make sure no addresses exist
my $objects = $addys->addresses();
is( @$objects, 0, 'no addresses exist');

# create five objects, none of which expire yet
my $time = time();
my $increment = 60*60;
for( 1..5 ) {
    my $addy = Mail::TempAddress::Address->new(
        expires => $time + ($increment + $_),
    );
    $addys->save(
        $addy,
        $addys->generate_address(),
    );
}

# make sure that we have five addresses
$objects = $addys->addresses();
is( @$objects, 5, 'five addresses exist');

# attempt to purge
my $purged = $addys->purge();
is( $purged, 0, 'nothing purged' );

# make sure that we still have five addresses
$objects = $addys->addresses();
is( @$objects, 5, 'five addresses exist');

# create five objects, all of which are expired
for( 1..5 ) {
    my $addy = Mail::TempAddress::Address->new(
        expires => $time - ($increment + $_),
    );
    $addys->save(
        $addy,
        $addys->generate_address(),
    );
}

# make sure that we have ten addresses
$objects = $addys->addresses();
is( @$objects, 10, 'ten addresses exist');

# create five objects, all of which expired a long
# time ago
$increment = 60*60*24;
for( 1..5 ) {
    my $addy = Mail::TempAddress::Address->new(
        expires => $time - ($increment + $_),
    );
    $addys->save(
        $addy,
        $addys->generate_address(),
    );
}

# make sure that we have fifteen addresses
$objects = $addys->addresses();
is( @$objects, 15, 'fifteen addresses exist');

# try to purge with a minimum of a half day
$purged = $addys->purge( 60*60*12 );
is( $purged, 5, 'five addresses purged' );

# make sure that we have ten addresses
$objects = $addys->addresses();
is( @$objects, 10, 'ten addresses exist');

# create five objects, all of which expired a long
# time ago
$increment = 60*60*24;
for( 1..5 ) {
    my $addy = Mail::TempAddress::Address->new(
        expires => $time - ($increment + $_),
    );
    $addys->save(
        $addy,
        $addys->generate_address(),
    );
}

# make sure that we have fifteen addresses
$objects = $addys->addresses();
is( @$objects, 15, 'fifteen addresses exist');

# try to purge with a minimum of a half day using freeform syntax
$purged = $addys->purge( '12h' );
is( $purged, 5, 'five addresses purged' );

# make sure that we have ten addresses
$objects = $addys->addresses();
is( @$objects, 10, 'ten addresses exist');

# do a purge without a minimum
$purged = $addys->purge();
is( $purged, 5, 'five addresses purged');
 
# make sure that we have five addresses
$objects = $addys->addresses();
is( @$objects, 5, 'five addresses exist');

# create five objects without expire times
for( 1..5 ) {
    my $addy = Mail::TempAddress::Address->new;
    $addys->save(
        $addy,
        $addys->generate_address(),
    );
}

# make sure that we have ten addresses
$objects = $addys->addresses();
is( @$objects, 10, 'ten addresses exist');

# attempt to purge
$purged = $addys->purge();
is( $purged, 0, 'nothing purged' );

# make sure that we still have ten addresses
$objects = $addys->addresses();
is( @$objects, 10, 'ten addresses exist');
