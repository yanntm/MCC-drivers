#! /usr/bin/perl

use Time::HiRes qw( time );
use Cwd;

# count failures
my $failed= 0;
my %verdicts = ();

# The total examinations (QuasiLivenessAll, StableMarkingAll, UpperBoundsAll)
# ask one question per transition (t<i>) or per place (p<i>), i being the
# definition index in model.pnml. The tool prints one line per object as it
# answers, "QLIVE t12 TRUE ...", "BOUND p3 7 ...", and an open bound repeats
# "BOUND p3 ? lo hi" as its interval moves : the last line of an object counts.
# The oracle holds the whole vector after the header, opened by the keyword and
# wrapped over as many lines as needed, whitespace being insignificant :
#   QLIVE               then one char per transition, T F or ?
#   STABLE              then one char per place
#   BOUND               then one token per place, an integer, inf or ?
my $totalmode = "";
my @total = ();
my %totalchar = ( "T" => "TRUE", "F" => "FALSE", "?" => "?" );

sub total_append {
  my $txt = shift;
  if ($totalmode eq "BOUND") {
    $txt =~ s/^\s+|\s+$//g;
    push @total, split(/\s+/, $txt) if ($txt ne "");
  } else {
    $txt =~ s/\s+//g;
    push @total, map { $totalchar{$_} } split //, $txt;
  }
}

# the expected verdict of a formula or of an object of a total examination
sub expected {
  my $name = shift;
  return $verdicts{$name} if (exists $verdicts{$name});
  if (@total && $name =~ /^[pt](\d+)$/) {
    return $total[$1];
  }
  return undef;
}

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

select IN ;
$| = 1 ; # disable buffering
select STDOUT ;
$| = 1 ; # disable buffering

while (my $line = <IN>) {
  if ($totalmode) {
    total_append($line);
  } elsif ($line =~ /^(QLIVE|STABLE|BOUND)\b(.*)$/) {
    $totalmode = $1;
    total_append($2);
  } elsif ($line =~ /STATE\_SPACE/ || $line =~ /FORMULA/ ) {
    my @words = split /\s+/,$line;
    # Note that the final reported Statistic is what will be taken
    $verdicts{@words[1]} = @words[2];
  }
}

close IN;

my $nbtests = keys(%verdicts) + scalar(@total);

print "Test : $title ; ".$nbtests." values to test \n";

print "Control values :\n";
foreach my $key (sort keys %verdicts) {
  print "$key=$verdicts{$key}\n";
}
if (@total) {
  my %count = ();
  $count{$_}++ foreach @total;
  print "total examination : ".join(" ", map { "$_=$count{$_}" } sort keys %count)."\n";
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
  if ($line =~ /STATE\_SPACE/ || $line =~ /\bFORMULA\b/ || $line =~ /^(QLIVE|STABLE|BOUND) / )  {
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
    my $exp =  expected(@words[1]);
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
$e = keys (%verdicts) + scalar(@total);
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
