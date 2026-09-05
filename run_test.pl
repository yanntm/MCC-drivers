#! /usr/bin/perl

use Time::HiRes qw( time );
use Cwd;

# count failures
my $failed= 0;

# The total examinations (QuasiLivenessAll, StableMarkingAll, UpperBoundsAll)
# print one line per object, KEYWORD object verdict, in place of FORMULA
# lines; an open bound repeats its line with a ? and the last one counts.
my $TOTAL_LINE = qr/^(QLIVE|STABLE|BOUND) /;

my $title = $ARGV[0];
chomp $title;
$title =~ s/\//\./g;
$title =~ s/\.out//g;

print "##teamcity[testSuiteStarted name='$title']\n";

print "Running test : $title \n";
open IN, "< $ARGV[0]";


my $call = <IN>;
chomp $call;

$ENV{'BK_EXAMINATION'}= (split / /,$call)[1];  
	
if ($ARGV[1] eq "-t") {	
	$ENV{'BK_TIME_CONFINEMENT'}=$ARGV[2];
	$call= $call." ".join (" ",@ARGV[3..$#ARGV]);
} else {
	$call= $call." ".join (" ",@ARGV[1..$#ARGV]);
	# default is 15 minutes
	$ENV{'BK_TIME_CONFINEMENT'}=900;
}
print "Timeout set at :".$ENV{'BK_TIME_CONFINEMENT'}." seconds\n";

# position other BK_ variables
if (! defined $ENV{'BK_TOOL'}) {
	$ENV{'BK_TOOL'}=TEST;
}
if (! defined $ENV{'BK_MEM_CONFINEMENT'}) {
	$ENV{'BK_MEM_CONFINEMENT'}=16384;  # 16 GB
}

$ENV{'BK_BIN_PATH'}=getcwd()."/bin/";  # assume this test script lives next to binaries

# print $call;


my $header;
my %verdicts = ();

select IN ;
$| = 1 ; # disable buffering
select STDOUT ;
$| = 1 ; # disable buffering

while (my $line = <IN>) {
  if ($line =~ /STATE\_SPACE/ || $line =~ /FORMULA/ || $line =~ $TOTAL_LINE ) {
    my @words = split /\s+/,$line;
    # Note that the final reported Statistic is what will be taken
    $verdicts{@words[1]} = @words[2];
  }
}

close IN;

my $nbtests = keys(%verdicts);

print "Test : $title ; ".$nbtests." values to test \n";

print "Control values :\n";
foreach my $key (sort keys %verdicts) {
  print "$key=$verdicts{$key}\n";
}

if ($nbtests == 0) {
  print "\n##teamcity[testStarted name='oracle-integrity']\n";
  print "\n##teamcity[testFailed name='oracle-integrity' message='Oracle file empty or otherwise incorrect' details='Was reading : $title' expected='greater than 0' actual='$nbtests'] \n";
  print "\n##teamcity[testFinished name='oracle-integrity']\n";
  exit 1;
}

# Now run the tool
my $tmpfile = "$ARGV[0].tmp";

# RUNATEST selects the runner. Concurrent jobs on the same model instance need
# ./runatest_cluster.sh, which unpacks into a $$ suffixed folder of its own.
my $runner = $ENV{'RUNATEST'} || "./runatest.sh";
$call = $runner." ".$call ;
print "syscalling : $call \n";
my %formouts = ();

print "##teamcity[testStarted name='runits']\n";
my $start = time();

open IN, "($call) |" or die "An exception was raised when attempting to run "+$call+"\n";
my $first=1;

my $last = time();

while (my $line = <IN>) {
  print $line;
  if ($line =~ /STATE\_SPACE/ || $line =~ /\bFORMULA\b/ || $line =~ $TOTAL_LINE )  {
    if ($first) {
      $first = 0;
      my $cur = time();
      my $duration =  int(($cur - $last) * 1000) ;
      $last = $cur;
      print "##teamcity[testFinished name='runits' duration='$duration']\n";
    }
    my @words = split /\s+/,$line;
    $formouts{@words[1]} = @words[2];
    
    my $out = @words[2];
    my $exp =  $verdicts{@words[1]};
    my $tname = @words[1]; #$title.".".@words[1];
    print "##teamcity[testStarted name='$tname']\n";
	
	my $cur = time();
	my $duration =  int(($cur - $last) * 1000) ;
	$last = $cur;

    if (! defined $exp) {
      print "\n Formula @words[1] : no verdict in oracle !! expected/real : $exp /  $out\n";
      print "\n##teamcity[testFailed name='$tname' message='oracle incomplete : formula ( @words[1] )' details='' expected='$exp' actual='$out'] \n";
      $failed++;
    } elsif ( $out ne $exp && $exp ne "?" && !($exp eq "inf" && $out eq "+inf") ) {
      print "\n Formula @words[1] : failed test expected/real : $exp /  $out\n";
      print "\n##teamcity[testFailed name='$tname' message='regression detected : formula ( @words[1] ) $exp / $out' details='' expected='$exp' actual='$out'] \n";
      $failed++;
    } else {
      print "\n Formula @words[1] test successful expected/real : $exp /  $out\n";
    }
    print "##teamcity[testFinished name='$tname' duration='$duration']\n";
  } elsif ($line =~ /\/tmp\/eclipse\/\d+\.log/g) {
  	open (IN2, '<', $line) or die "An exception was raised when attempting to open "+$line+"\n";
  	while (my $line2 = <IN2>) {
	  print $line2;
	}
	close IN2;
  }
}

close IN;

print "Actual read output values :\n";
foreach my $key (sort keys %formouts) {
  print "$key=$formouts{$key}\n";
}

$o = keys (%formouts);
$e = keys (%verdicts);
print "\n##teamcity[testStarted name='all']\n";
if ( $o != $e ) {
#  unless ( $title =~ /SS/ && $o == 3 && $e == 4) {
 	 print "\n##teamcity[testFailed name='all' message='regression detected : less results than expected ( $o / $e )' details='' expected='$e' actual='$o'] \n";
  	$failed++;
#  }
} elsif ($o > 0) {
  print "All $o tests successful in suite : $title\n";
}


my $end = time();
my $duration =  int(($end - $start) * 1000) ;

print "\n##teamcity[testFinished name='all' duration='$duration']\n";


print "##teamcity[testSuiteFinished name='$title']\n";

exit $failed;
