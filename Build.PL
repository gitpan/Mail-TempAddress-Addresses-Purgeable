use Module::Build;

my $build = Module::Build->new(
	module_name => 'Mail::TempAddress::Addresses::Purgeable',
    PL_files    => {
        'bin/mail_tempaddress_purge.pl.PL'
            => [ 'bin/mail_tempaddress_purge.pl' ],
    },
    script_files => [ 'bin/mail_tempaddress_purge.pl' ],
	license     => 'perl',
	requires    => {
		Mail::TempAddress => '<=0.53',
	},
	dist_version_from => 'lib/Mail/TempAddress/Addresses/Purgeable.pm',
);

$build->create_build_script;
