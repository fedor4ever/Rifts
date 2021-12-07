# fixupsym.pl
#
# Copyright (c) 1999 Symbian Ltd.  All rights reserved.
#

#
# Relinks the debug exe/dlls in a ROM if the make file is present
#

require 5.003_07;
no strict 'vars';
use English;
use Cwd;

# Globals
my $debug = 0;
my $rombuild;
my @executables = ( 'euser' );

cwd =~ /^(.:)/o;
my $drive = $1;

# Standard e32toolp path scanning
my $PerlLibPath;
BEGIN
  {
	foreach (split ';', $ENV{Path})
	  {
		s-/-\\-go;				# for those working with UNIX shells
		s-^$-.-o;	# convert empty string to .
		s-^(.*[^\\])$-$1\\-o;	# ensure path ends with a backslash
		if (-e $_.'fixupsym.pl')
		  {
			$PerlLibPath=uc $_;
			last;
		  }
	  }
  }
use lib $PerlLibPath;
use Modload;
Load_SetModulePath($PerlLibPath);

&args;
&main;

exit 0;


#
# main
#
sub main
  {
	my $file;
	my $text;
	my $data;
	my $bss;
	my $textlen;
	my $datalen;
	my $bsslen;

	# build up a hash of all the make files indexed by build and exe name
	%map = ();
	&dirsearch("\\EPOC32\\BUILD");

	open (ROM, "<$rombuild")
	  or die "ERROR: Can't open rombuild log file \"$rombuild\"\n";

	die "ERROR: \"$rombuild\" isn't a rombuild log file\n"
	  unless ((<ROM> =~ /^ROMBUILD/) || (<ROM> =~ /^ROMBUILD/));
	
	while (<ROM>)
	  {
		if (/^Writing Rom image/)
		  {
		  # stop at end of first ROM, ignoring any extension ROMs
		  # This is necessary because the same file could appear
		  # at different places in different extensions.
		  #
		  last;
		  } 
		if (/^Processing file (.*)/)
		  {
			my $datalen;
			my $skip;
			
			$file = lc $1;
			$text = $bss = $data = $datalen = 0;
			
			# Work out final addresses of sections
			while (defined($_=<ROM>) && !/^$/)
			  {
				if (/^Code start addr:\s+(\w+)/)
				  {
					$text = hex($1);
				  }
				elsif (/^DataBssLinearBase:\s+(\w+)/)
				  {
					$data = hex($1);
				  }
				elsif (/^Code size:\s+(\w+)/)
				  {
					$textlen = hex($1);
				  }
				elsif (/^Data size:\s+(\w+)/)
				  {
					$datalen = hex($1);
					$bss = $data + $datalen;
				  }
				elsif (/^BssSize:\s+(\w+)/)
				  {
					$bsslen = hex($1);
				  }
			  }
			
			# Sanity check - text section can't be zero (other sections may be)
			die "ERROR: Can't find rombuild info for \"$file\"\n"
			  if (!$text);
			
			# get the build and exe name
			if ($file =~ /^\\epoc32\\release\\(.*)\\(.*)\\(.*)$/o)
			  {
				$build = lc $1;
				$debrel = uc $2;
				$executablefile = lc $3;
			  }
			
			# Only relink this file if it's kernel-side or matches the regexp
			if ($build =~ /^(M|S)/i)
			  {
				$skip = 0;
			  }
			else
			  {
				$skip = 1;
				foreach $re (@executables)
				  {
					$skip = 0 if ($file =~ /$re/i);
				  }
			  }
			print "$file - skipped\n" if ($skip && $debug);
			next if ($skip);

			if (! defined $map{"$build $executablefile"})
			    {
			    print "$file - no makefile\n";
			    next;
			    }
			if ($debrel ne "UDEB")
			    {
			    print "$file - can't fixup $debrel\n";
			    next;
			    }

			# relink this file
			print "$file";
			
			# lookup the makefile name
			($makepath, $workdir) = @{$map{"$build $executablefile"}};

			# only relink if we have a makefile
			if ($makepath && $workdir)
			  {
				# optimisation: don't relink if already at correct address
				$file =~ /([^\.]+\.).+/;
				my $symfile = $drive.$1."sym";
				if ((-e $file) && (-e $symfile) &&
					open (CHILD, "objdump --headers $symfile |"))
				  {
					my $oldtext;
					my $olddata;
					my $oldbss;
					
					while (<CHILD>)
					  {
						if (/^\s+\d+\s+(\.\w+)\s+[0-9a-fA-F]+\s+([0-9a-fA-F]+)\s/)
						  {
							if ($1 eq '.text')
							  {
								$oldtext = hex($2);
							  }
							elsif ($1 eq '.data')
							  {
								$olddata = hex($2);
							  }
							elsif ($1 eq '.bss')
							  {
								$oldbss = hex($2);
							  }
						  }
					  }
					close CHILD;
					$skip = 1 if ((!$textlen || ($text == $oldtext)) &&
								  (!$datalen || ($data == $olddata)) &&
								  (!$bsslen	 || ($bss  == $oldbss)));
					print " - current" if ($skip && $debug);
				  }

				if (!$skip)
				  {
					chdir $workdir
					  or die "Can't cd to build directory \"$workdir\"\n";

					# save executable in case relink fails
					rename $file, "$file.bak"
					  or die "Can't rename \"$file\": $ERRNO\n"
						if -e $file;
					
					my $command =
					  sprintf ("nmake -nologo -s -f \"$makepath\" $debrel " .
							   "USERLDFLAGS=\"--image-base 0 -Ttext 0x%lx " .
							   "-Tdata 0x%lx -Tbss 0x%lx\"",
							   $text, $data, $bss);
					print "\n\"$command\"" if ($debug);
					open (CHILD, "$command |")
					  or die "\nERROR: Can't run \"$command\": $ERRNO\n";
					close CHILD;

					if (-e $file)
					  {
						unlink "$file.bak";
					  }
					else	# relink failed for some reason - restore saved
					  {
						rename "$file.bak", $file;
					  }
				  }

				print "\n";
			  }
			else
			  {
				print " - can't fixup\n";
			  }
		  }
	  }
	close ROM;
  }

#
# args - get command line args
#
sub args
  {
	my $arg;
	my @args;
	my $flag;
	
	&help if (!@ARGV);
	
	while (@ARGV)
	  {
		$arg = shift @ARGV;
		
		if ($arg=~/^[\-\/](\S*)$/)
		  {
			$flag=$1;
			
			if ($flag=~/^[\?h]$/i)
			  {
				&help;
			  }
			else
			  {
				print "\nERROR: Unknown flag \"-$flag\"\n";
				&usage;
				exit 1;
			  }
		  }
		else
		  {
			push @args,$arg;
		  }
	  }
	
	$rombuild = shift @args;
	
	if (@args)
	  {
		foreach $file (@args)
		  {
			push @executables, quotemeta($file);
		  }
	  }
  }


# recursive directory search
sub dirsearch
  {
	my ($input_path) = @_;
	my $searchpath = "$input_path\\";
	my $workdir;
	
	if (opendir DIRHANDLE, $searchpath)
	  {
		my @allfiles = grep !/^\.\.?$/, readdir DIRHANDLE;
		closedir DIRHANDLE;
		foreach $entry (@allfiles)
		  {
			# treat each entry as a possible directory, but don't look in
			# udeb & urel directories which contain objects and binaries
			&dirsearch ("$searchpath$entry") unless ($entry =~ /^u(deb|rel)$/i)
		  }
	  }
	else						# couldn't open the dir, open it as a file
	  {
		# got a file, now to get the exe name from within
		open (FILE, "<$input_path");
		my @lines = <FILE>;
		close FILE;
		
		foreach $liney (@lines)
		  {
			if ($liney =~ /^\# CWD\s(.+)\\/)
			  {
				$workdir = lc $1;
			  }
			if ($liney =~ /^\# Target\s(.*)$/)
			  {
				my $target = lc $1;
				 
				# add to the hash table
				my $build;

				# Derive build from makefile extension (eg .arm4)
				if ($input_path =~ /^.*\.(.*)$/o)
				  {
					$build = lc $1;
					$map{"$build $target"} = [lc $input_path, $workdir];
					$workdir = undef;
				  }
				last;
			  }
		  }
	  }
  }
	
sub help ()
  {
	my $build;
	
	&Load_ModuleL('E32TPVER');
	print "\nfixupsym - " .
	  "Fix up executables with locations taken from a ROM image (Build ",
	  &E32tpver, ")\n";
	&usage;
	exit 0;
  }
	
sub usage ()
  {
	print <<EOF
		  
Usage:
  fixupsym <logfile> [<executables>]

Where:
  <logfile>     Log file from rombuild tool.
  <executables> Names of additional executables to fix up.
                ASSP-specific executables and EUSER are always included.

Example:
  fixupsym rombuild.log efile efsrv .fsy
EOF
  ;
	exit 0;
  }
