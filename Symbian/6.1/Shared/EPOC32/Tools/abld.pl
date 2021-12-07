# ABLD.PL
#
# Copyright (c) 1997-1999 Symbian Ltd.  All rights reserved.
#

# find the directory containing ABLD.PL
my $PerlLibPath;
BEGIN {
	require 5.003_07;
	foreach (split ';', $ENV{Path}) {
		s-/-\\-go;	# for those working with UNIX shells
		s-^$-.-o;	# convert empty string to .
		s-^(.*[^\\])$-$1\\-o;   # ensure path ends with a backslash
		if (-e $_.'ABLD.PL') {
			$PerlLibPath=uc $_;
			last;
		}
	}
}

# use a perl integrity checker
# use a command-line parsing module
use Getopt::Long;

# allow loading of libraries from the ABLD.PL directory
use lib $PerlLibPath;
use E32env;

# command data structure
my %Commands=(
	BUILD=>{
		build=>1,
		program=>1,
		what=>1,
		function=>'Combines commands EXPORT,MAKEFILE,LIBRARY,RESOURCE,TARGET,FINAL',
		subcommands=>['EXPORT','MAKEFILE', 'LIBRARY', 'RESOURCE', 'TARGET', 'FINAL'],
		savespace=>1,
	},
	CLEAN=>{
		build=>1,
		program=>1,
		function=>'Removes everything built with ABLD TARGET',
		what=>1,
	},
	CLEANEXPORT=>{
		function=>'Removes files created by ABLD EXPORT',
		what=>1,
		noplatform=>1,
	},
	CLEANMAKEFILE=>{
		program=>1,
		function=>'Removes files generated by ABLD MAKEFILE',
		what=>1,
		hidden=>1,
	},
	EXPORT=>{
		noplatform=>1,
		what=>1,
		function=>'Copies the exported files to their destinations',
	},
	FINAL=>{
		build=>1,
		program=>1,
		function=>'Allows extension makefiles to execute final commands',
	},
	FREEZE=>{
		program=>1,
		function=>'Freezes exported functions in a .DEF file',
	},
	HELP=>{
		noplatform=>1,
		function=>'Displays commands, options or help about a particular command',
		notest=>1,
	},
	LIBRARY=>{
		program=>1,
		function=>'Creates import libraries from the frozen .DEF files',
	},
	LISTING=>{
		build=>1,
		program=>1,
		function=>'Creates assembler listing file for corresponding source file',
		source=>1,	
	},
	MAKEFILE=>{
		program=>1,
		function=>'Creates makefiles or IDE workspaces',
		what=>1,
	},
	REALLYCLEAN=>{
		build=>1,
		program=>1,
		function=>'As CLEAN, but also removes exported files and makefiles',
		what=>1,
		subcommands=>['CLEANEXPORT', 'CLEAN', 'CLEANMAKEFILE'],
	},
	RESOURCE=>{
		build=>1,
		program=>1,
		function=>'Creates resource files, bitmaps and AIFs',
	},
	ROMFILE=>{
		function=>'Under development - syntax not finalised',
		noverbose=>1,
		nokeepgoing=>1,
		hidden=>1,
	},
	SAVESPACE=>{
		build=>1,
		program=>1,
		what=>1,
		function=>'As TARGET, but deletes intermediate files on success',
		hidden=>1, # hidden because only used internally from savespace flag
	},
	TARGET=>{
		build=>1,
		program=>1,
		what=>1,
		function=>'Creates the main executable and also the resources',
		savespace=>1,
	},
	TIDY=>{
		build=>1,
		program=>1,
		function=>'Removes executables which need not be released',
	},
);

# get the path to the bldmake-generated files
# we can perhaps work this out from the current working directory in later versions
my $BldInfDir;
my $PrjBldDir;
BEGIN {
	$BldInfDir=shift @ARGV;
	$PrjBldDir=$E32env::Data{BldPath};
	$PrjBldDir=~s-^(.*)\\-$1-o;
	$PrjBldDir.=$BldInfDir;
	$PrjBldDir=~m-(.*)\\-o; # remove backslash because some old versions of perl can't cope
	unless (-d $1) {
		die "ABLD ERROR: Project Bldmake directory \"$PrjBldDir\" does not exist\n";
	}
}

# check the platform module exists and then load it
BEGIN {
	unless (-e "${PrjBldDir}Platform.pm") {
		die "ABLD ERROR: \"${PrjBldDir}Platform.pm\" not yet created\n";
	}
}
use lib $PrjBldDir;
use Platform;

# change directory to the BLD.INF directory so that extension makefiles
# can specify paths relative to that directory.
chdir($BldInfDir) or die "ABLD ERROR: Can't CD to \"$BldInfDir\"\n";

# MAIN PROGRAM SECTION
{

#	PROCESS THE COMMAND LINE
	my %Options=();
	unless (@ARGV) {
		&Usage();
	}

#	Process options and check that all are recognised
	unless (GetOptions(\%Options, 'check|c', 'keepgoing|k', 'savespace|s', 'verbose|v', 'what|w')) { 
		exit 1;
	}

#	check the option combinations
	if (($Options{check} and $Options{what})) {
		&Options;
	}
	if (($Options{check} or $Options{what}) and ($Options{keepgoing} or $Options{savespace} or $Options{verbose})) {
		&Options();
	}

#	take the test parameter out of the command-line if it's there
	my $Test='';
	if (@ARGV && $ARGV[0]=~/^test$/io) {
		$Test='test';
		shift @ARGV;
	}

#	if there's only the test parameter there, display usage
	unless (@ARGV) {
		&Usage();
	}

#	get the command parameter out of the command line
	my $Command=uc shift @ARGV;
	unless (defined $Commands{$Command}) {
		&Commands();
	}
	my %CommandHash=%{$Commands{$Command}};

#	check the test parameter is not specified where it shouldn't be
	if ($Test and $CommandHash{notest}) {
		&Help($Command);
	}

#	check the options are suitable for the commands
#	-verbose and -keepgoing have no effect in certain cases
	if ($Options{what} or $Options{check}) {
		unless ($CommandHash{what}) {
			&Help($Command);
		}
	}
	if ($Options{savespace}) {
		unless ($CommandHash{savespace}) {
			&Help($Command);
		}
	}
	if ($Options{keepgoing}) {
		if ($CommandHash{nokeepgoing}) {
			&Help($Command);
		}
	}
	if ($Options{verbose}) {
		if ($CommandHash{noverbose}) {
			&Help($Command);
		}
	}

#	process help command if necessary
	if ($Command eq 'HELP') {
		if (@ARGV) {
			my $Tmp=uc shift @ARGV;
			if (defined $Commands{$Tmp}) {
				&Help($Tmp);
			}
			elsif ($Tmp eq 'OPTIONS') {
				&Options();
			}
			elsif ($Tmp eq 'COMMANDS') {
				&Commands();
			}
		}
		&Usage();
	}

#	process parameters
	my ($Plat, $Bld, $Program, $Source)=('','','','');
#	platform parameter first
	unless ($CommandHash{noplatform}) {
		unless ($Plat=uc shift @ARGV) {
			$Plat='ALL'; # default
		}
		else {
			COMPARAM1 : {
				if (grep(/^$Plat$/, ('ALL', @Platform::Plats))) {
					last COMPARAM1;
				}
#				check whether the platform might in fact be a build, and
#				set the platform and build accordingly if it is
				if ($CommandHash{build}) {
					if ($Plat=~/^(UDEB|UREL|DEB|REL)$/o) {
						$Bld=$Plat;
						$Plat='ALL';
						last COMPARAM1;
					}
				}
#				check whether the platform might in fact be a program, and
#				set the platform, build and program accordingly if it is
				if ($CommandHash{program}) {
					if  (((not $Test) and grep /^$Plat$/, @{$Platform::Programs{ALL}})
							or ($Test and grep /^$Plat$/, @{$Platform::TestPrograms{ALL}})) {
						$Program=$Plat;
						$Plat='ALL';
						$Bld='ALL';
						last COMPARAM1;
					}
				}
#				report the error
				if ($CommandHash{build} and $CommandHash{program}) {
					die "This project does not support platform, build or $Test program \"$Plat\"\n";
				}
				if ($CommandHash{build} and not $CommandHash{program}) {
					die "This project does not support platform or build \"$Plat\"\n";
				}
				if ($CommandHash{program} and not $CommandHash{build}) {
					die "This project does not support platform or $Test program \"$Plat\"\n";
				}
				if (not ($CommandHash{build} or $CommandHash{program})) {
					die "This project does not support platform \"$Plat\"\n";
				}
			}
		}
	}

#	process the build parameter for those commands which require it
	if ($CommandHash{build}) {
		unless ($Bld) {
			unless ($Bld=uc shift @ARGV) {
				$Bld='ALL'; # default
			}
			else {
				COMPARAM2 : {
					if ($Bld=~/^(ALL|UDEB|UREL|DEB|REL)$/o) {
#						hack for TOOLS and VC6TOOLS platforms
						if ($Plat ne 'ALL') {
							if (($Plat!~/TOOLS$/o and $Bld=~/^(DEB|REL)$/o) or ($Plat=~/TOOLS$/o and $Bld=~/^(UDEB|UREL)$/o)) {
								die  "Platform \"$Plat\" does not support build \"$Bld\"\n";
							}
						}
						last COMPARAM2;
					}
#					check whether the build might in fact be a program, and
#					set the build and program if it is
					if ($CommandHash{program}) {
						if  (((not $Test) and grep /^$Bld$/, @{$Platform::Programs{$Plat}})
								or ($Test and grep /^$Bld$/, @{$Platform::TestPrograms{$Plat}})) {
							$Program=$Bld;
							$Bld='ALL';
							last COMPARAM2;
						}
						my $Error="This project does not support build or $Test program \"$Bld\"";
						if ($Plat eq 'ALL') {
							$Error.=" for any platform\n";
						}
						else {
							$Error.=" for platform \"$Plat\"\n";
						}
						die $Error;
					}
					my $Error="This project does not support build \"$Bld\"";
					if ($Plat eq 'ALL') {
						$Error.=" for any platform\n";
					}
					else {
						$Error.=" for platform \"$Plat\"\n";
					}
					die $Error;
				}
			}
		}
	}

#	get the program parameter for those commands which require it
	if ($CommandHash{program}) {
		unless ($Program) {
			unless ($Program=uc shift @ARGV) {
				$Program=''; #default - means ALL
			}
			else {
#				check that the program is supported
				unless (((not $Test) and grep /^$Program$/, @{$Platform::Programs{$Plat}})
						or ($Test and grep /^$Program$/, @{$Platform::TestPrograms{$Plat}})) {
					my $Error="This project does not support $Test program \"$Program\"";
					if ($Plat eq 'ALL') {
						$Error.=" for any platform\n";
					}
					else {
						$Error.=" for platform \"$Plat\"\n";
					}
					die $Error;
				}
			}
		}
	}

#	get the source file parameter for those commands which require it
	if ($CommandHash{source}) {
		unless ($Source=uc shift @ARGV) {
			$Source=''; #default - means ALL
		}
		else {
			$Source=" SOURCE=$Source";
		}
	}

#	check for too many arguments
	if (@ARGV) {
		&Help($Command);
	}

#	expand the platform list
	my @Plats;
	unless ($CommandHash{noplatform}) {
		if ($Plat eq 'ALL') {
			@Plats=@Platform::RealPlats;
#			hack for WINSCW - remove WINSCW from the "ALL" list
			@Plats=grep !/CW$/o, @Plats;
			if ($CommandHash{build}) {
#				remove unnecessary platforms if just building for tools, or building everything but tools
#				so that the makefiles for other platforms aren't created with abld build
				if ($Bld=~/^(UDEB|UREL)$/o) {
					@Plats=grep !/TOOLS$/o, @Plats;
				}
				elsif ($Bld=~/^(DEB|REL)$/o) {
					@Plats=grep /TOOLS$/o, @Plats;
				}
			}
		}
		else {
			@Plats=($Plat);
		}

		foreach $Plat (@Plats) {
			unless (-e "$PrjBldDir$Plat$Test.make") {
				die "ABLD ERROR: \"$PrjBldDir$Plat$Test.make\" not yet created\n";
			}
		}
		undef $Plat;
	}

#	set up a list of commands where there are sub-commands
	my @Commands=($Command);
	if ($CommandHash{subcommands}) {
		@Commands=@{$CommandHash{subcommands}};
		if ($Command eq 'BUILD') { # avoid makefile listings here
			if ($Options{what} or $Options{check}) {
				@Commands=grep !/^MAKEFILE$/o, @{$CommandHash{subcommands}};
			}
		}
	}
#	implement savespace if necessary
	if ($Options{savespace}) {
		foreach $Command (@Commands) {
			if ($Command eq 'TARGET') {
				$Command='SAVESPACE';
			}
		}
	}

#	set up makefile call flags and macros from the options
	my $KeepgoingFlag='';
	my $KeepgoingMacro='';
	my $VerboseMacro=' VERBOSE=-s';
	if ($Options{keepgoing}) {
		$KeepgoingFlag=' -k';
		$KeepgoingMacro=' KEEPGOING=-k';
	}
	if ($Options{verbose}) {
		$VerboseMacro='';
	}

#	set up a list of nmake calls
	my @Calls;

#	handle the exports related calls first
	if (($Command)=grep /^(.*EXPORT)$/o, @Commands) { # EXPORT, CLEANEXPORT
		unless (-e "${PrjBldDir}EXPORT$Test.make") {
			die "ABLD ERROR: \"${PrjBldDir}EXPORT$Test.make\" not yet created\n";
		}
		unless ($Options{what} or $Options{check}) {
			push @Calls, "nmake -nologo$KeepgoingFlag -f \"${PrjBldDir}EXPORT$Test.make\" $Command$VerboseMacro$KeepgoingMacro";
		}
		else {
			push @Calls, "nmake -nologo -f \"${PrjBldDir}EXPORT$Test.make\" WHAT";
		}
		@Commands=grep !/EXPORT$/o, @Commands;
	}

#	then do the rest of the calls

	COMMAND: foreach $Command (@Commands) {

		my $Plat;
		PLATFORM: foreach $Plat (@Plats) {

#			set up a list of builds to carry out commands for if appropriate
			my @Blds=($Bld);
			if (${$Commands{$Command}}{build}) {
				if ($Bld eq 'ALL') {
					unless ($Plat=~/TOOLS$/o) { # hack for platforms TOOLS and VC6TOOLS
						@Blds=('UDEB', 'UREL');
					}
					else {
						@Blds=('DEB', 'REL');
					}
				}
				else {
#					check the build is suitable for the platform - TOOLS and VC6TOOLS are annoyingly atypical
					unless (($Plat!~/TOOLS$/o and $Bld=~/^(UDEB|UREL)$/o) or ($Plat=~/TOOLS$/o and $Bld=~/^(DEB|REL)$/o)) {
						next;
					}
				}
			}
			else {
				@Blds=('IRRELEVANT');
			}

			my $LoopBld;
			foreach $LoopBld (@Blds) {
				my $CFG='';
				if ($LoopBld ne 'IRRELEVANT') {
					$CFG=" CFG=$LoopBld";
				}
				unless ($Options{what} or $Options{check}) {
					if ($Program) { # skip programs if they're not supported for a platform
						unless ($Test) {
							unless (grep /^$Program$/, @{$Platform::Programs{$Plat}}) {
								next PLATFORM;
							}
						}
						else {
							unless (grep /^$Program$/, @{$Platform::TestPrograms{$Plat}}) {
								next PLATFORM;
							}
						}
					}
					push @Calls, "nmake -nologo$KeepgoingFlag -f \"$PrjBldDir$Plat$Test.make\" $Command$Program$CFG$Source$VerboseMacro$KeepgoingMacro";
					next;
				}
				unless (${$Commands{$Command}}{what}) {
					next COMMAND;
				}
				if ($Program) { # skip programs if they're not supported for a platform
					unless ($Test) {
						unless (grep /^$Program$/, @{$Platform::Programs{$Plat}}) {
							next PLATFORM;
						}
					}
					else {
						unless (grep /^$Program$/, @{$Platform::TestPrograms{$Plat}}) {
							next PLATFORM;
						}
					}
				}
				my $Makefile='';
				if ($Command=~/MAKEFILE$/o) {
					$Makefile='MAKEFILE';
				}
				push @Calls, "nmake -nologo -f \"$PrjBldDir$Plat$Test.make\" WHAT$Makefile$Program $CFG";
			}
		}
	}


#	make the required calls

	my $Call;
	unless ($Options{what} or $Options{check}) {
		foreach $Call (@Calls) {
			print "  $Call\n";
			open PIPE, "$Call |";
			while (<PIPE>) {
				print;
			}
			close PIPE;
		}
	}
	else {
		my %WhatCheck; # check for duplicates
		if ($Options{what}) {
			foreach $Call (@Calls) {
				open PIPE, "$Call |";
				while (<PIPE>) {
#					releasables split on whitespace - quotes possible -stripped out
					while (/("([^"\t\n\r\f]+)"|([^ "\t\n\r\f]+))/go) {
						my $Releasable=($2 ? $2 : $3);
						unless ($WhatCheck{$Releasable}) {
							$WhatCheck{$Releasable}=1;
							print "$Releasable\n";
						}
					}
				}
				close PIPE;
			}
		}
		else {			
			foreach $Call (@Calls) {
				open PIPE, "$Call |";
				while (<PIPE>) {
#					releasables split on whitespace - quotes possible -stripped out
					while (/("([^"\t\n\r\f]+)"|([^ "\t\n\r\f]+))/go) {
						my $Releasable=($2 ? $2 : $3);
						unless ($WhatCheck{$Releasable}) {
							$WhatCheck{$Releasable}=1;
							unless (-e $Releasable) {
								print STDERR "MISSING: $Releasable\n";
							}
						}
					}
				}
				close PIPE;
			}
		}
	}
}

sub Usage () {
	print <<ENDHERESTRING;
Common usage : abld [test] command [options] [platform] [build] [program]
  where command is build, target, etc.
    (type \"abld help commands\" for a list of commands)
  where options are -c, -k, etc.
    (type \"abld help options\" for a list of options)
  where parameters depend upon the command
    (type \"abld help <command>\" for command-specific help)
  where parameters default to 'ALL' if unspecified
ENDHERESTRING

	print
		"project platforms:\n",
		"   @Platform::Plats\n"
	;
	exit 1;
}

sub Options () {
	print <<ENDHERESTRING;
Options (case-insensitive) :
  -c or -check      check the releasables are present
  -k or -keepgoing  build unrelated targets on error
  -s or -savespace  delete intermediate files on success
  -v or -verbose    display tools calls as they happen
  -w or -what       list the releasables

 possible combinations :
	(([-check]|[-what])|([-k][-s][-v]))
ENDHERESTRING

	exit;
}

sub Help ($) {
	my ($Command)=@_;

	my %CommandHash=%{$Commands{$Command}};

	print 'ABLD';
	unless ($CommandHash{notest}) {
		print ' [test]';
	}
	print " $Command ";
	if ($Command eq 'HELP') {
		print '([OPTIONS|COMMANDS]|[<command>])';
	}
	else {
		if ($CommandHash{what}) {
			print '(([-c]|[-w])|';
		}
		if ($CommandHash{savespace}) {
			print '[-s]';
		}
		unless ($CommandHash{nokeepgoing}) {
			print '[-k]';
		}
		unless ($CommandHash{noverbose}) {
			print '[-v]';
		}
		if ($CommandHash{what}) {
			print '))';
		}
		unless ($CommandHash{noplatform}) {
			print ' [<platform>]';
		}
		if ($CommandHash{build}) {
			print ' [<build>]';
		}
		if ($CommandHash{program}) {
			print ' [<program>]';
		}
		if ($CommandHash{source}) {
			print ' [<source>]';
		}
	}

	print
		"\n",
		"\n",
		"$CommandHash{function}\n"
	;
	exit;
}

sub Commands () {

	print "Commands (case-insensitive):\n";
	foreach (sort keys %Commands) {
		next if ${$Commands{$_}}{hidden};
		my $Tmp=$_;
		while (length($Tmp) < 12) {
			$Tmp.=' ';
		}
		print "  $Tmp ${$Commands{$_}}{function}\n";
	}

	exit;
}


