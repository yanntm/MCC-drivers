#!/usr/bin/perl

use strict;
use warnings;

$index=0;

if (@ARGV[0] =~ /-s/){
  $index=2; 
}

$time = @ARGV[$index] or die "Arg $index is time limit";
$cmd = join (" ",@ARGV[($index+1)..$#ARGV]);

# directly off the manual
# simulate open(FOO, "-|")
sub pipe_from_fork ($) {
  my $parent = shift;
  pipe $parent, my $child or die;
  my $pid = fork();
  die "fork() failed: $!" unless defined $pid;
  if ($pid) {
    close $child;
  }
  else {
    close $parent;
    open(STDOUT, ">&=" . fileno($child)) or die;
  }
  $pid;
}

print $cmd."\n";

## Following code is extracted from "pslist" utility v1.3.2 (ubuntu package)
## copied here to make utility self containing
#
# Copyright (c) 2000, 2005, 2009, 2016  Peter Pentchev
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
# Taken from revision : 08fe6fcec39c3b43dd1fae324548d0f04d7cb86e
# of repo : https://gitlab.com/pslist/pslist/blob/master/pslist

my ($defaultPS, $defaultPSflags) = ("/bin/ps", "axco pid,ppid,command");
my ($PS, $PSflags);
my %proc;
my %parproc;

# Function:
# proc_gather   - parse ps output to fill out process arrays
# Inputs:
# none
# Returns:
# nothing
# Modifies:
# fills out %proc and %parproc
# invokes a pipe to 'ps'

sub proc_gather() {
    $PS = $ENV{'PS'} // $defaultPS;
    $PSflags = $ENV{'PSflags'} // $defaultPSflags;
  open my $ps, "$PS $PSflags |" or die "failed to invoke '$PS $PSflags' - $!\n";
  while (defined(my $line = <$ps>)) {
    chomp $line;
    if ($line =~ /^
        \s* (?<pid>\d+) \s+
        (?<ppid>\d+) \s+
        (?<cmd>\S+)
        (?<args>.*)
        $/x) {
      $proc{$+{pid}} = {
        ppid => $+{ppid},
        cmd => $+{cmd},
        args => $+{args},
      };
      $parproc{$+{ppid}} .= "$+{pid} ";
    }
  }
  close $ps;
}

# Function:
# proc_get_children - get a list of a process's immediate children
# Inputs:
# $pid      - process ID to examine
# Returns:
# array of children PIDs
# Modifies:
# nothing

sub proc_get_children($) {
  my ($pid) = @_;
  my @arr;
  my $s;

  return () unless defined $parproc{$pid};

  $s = $parproc{$pid};
  while ($s =~ /^(?<pid>\d+) \s+ (?<rest>.*)/x) {
    push @arr, $+{pid};
    $s = $+{rest};
  }

  return @arr;
}

# Function:
# proc_get_children_r - get a list of PIDs of a process's child tree
# Inputs:
# $pid      - PID to examine
# Returns:
# array of children PIDs
# Modifies:
# nothing; calls proc_get_children()

sub proc_get_children_r($);

sub proc_get_children_r($) {
  my ($pid) = @_;

  my @chi = proc_get_children $pid;
  my @res;
  for my $child (@chi) {
    push @res, $child, proc_get_children_r $child;
  }
  return @res;
}

# Function:
# proc_kill   - recursively kill a process and its children
# Inputs:
# $pid      - PID to kill
# $sig      - signal to send
# Returns:
# 0 on success
# negative number of unkilled children on failure, $! is set

sub proc_kill($ $) {
  my ($pid, $sig) = @_;
  die "bad pid ($pid)\n" unless $pid =~ /^\d+$/;
  die "non-existent pid ($pid)\n" unless defined $proc{$pid};

  my @arr = ($pid, proc_get_children_r $pid);
  print STDERR "Killing ($sig) : @arr \n";
  if (scalar @arr != kill $sig, @arr) {
    if ($sig != 9) {
      print STDERR "Could not kill all the requested processes (@arr): $!\n";
    }
  }
}

# New function:
# calculate_depth   - calculate depth of each process in the tree
# Inputs:
# $root_pid   - root process ID
# Returns:
# hash of pid => depth
# Modifies:
# nothing

sub calculate_depth {
    my ($root_pid) = @_;
    my %depth; # pid => depth
    $depth{$root_pid} = 0;

    sub traverse_depth {
        my ($pid, $curr_depth) = @_;
        my @children = proc_get_children($pid);
        for my $child (@children) {
            $depth{$child} = $curr_depth + 1;
            traverse_depth($child, $curr_depth + 1);
        }
    }

    traverse_depth($root_pid, 0);
    return %depth;
}

# New function:
# group_by_depth    - group processes by their depth in the tree
# Inputs:
# $root_pid   - root process ID
# Returns:
# hash of depth => [pid1, pid2, ...]
# Modifies:
# nothing

sub group_by_depth {
    my ($root_pid) = @_;
    my %depth = calculate_depth($root_pid);
    my %by_depth; # depth => [pid1, pid2, ...]
    for my $pid (keys %depth) {
        push @{$by_depth{$depth{$pid}}}, $pid;
    }
    return %by_depth;
}

# New function:
# proc_kill_layered - kill processes layer-by-layer from deepest to root
# Inputs:
# $pid      - PID to kill
# $sig      - signal to send
# Returns:
# nothing
# Modifies:
# kills processes; refreshes process list between layers

sub proc_kill_layered {
    my ($pid, $sig) = @_;
    die "bad pid ($pid)\n" unless $pid =~ /^\d+$/;
    die "non-existent pid ($pid)\n" unless defined $proc{$pid};

    # Gather process tree and group by depth
    proc_gather();
    my %by_depth = group_by_depth($pid);
    
    # Find maximum depth
    my $max_depth = (sort { $b <=> $a } keys %by_depth)[0] // 0;

    # Kill from deepest layer to root
    for my $depth (reverse(0..$max_depth)) {
        my @pids = @{$by_depth{$depth} // []};
        next unless @pids;
        print STDERR "Killing layer $depth ($sig): @pids\n";
        my $killed = kill $sig, @pids;
        if ($killed != scalar(@pids)) {
            print STDERR "Could not kill all processes in layer $depth (@pids): $!\n";
        }
        sleep 1; # Yield 1 second between layers
        proc_gather(); # Refresh process list to catch respawns
    }
}

select STDOUT;
$| = 1; 

if (my $pid = pipe_from_fork('BAR')) {
  $SIG{ALRM} = sub {
    print "TIME LIMIT: Killed by timeout after $time seconds \n";
    system ("head -2 /proc/meminfo");

    # Let the user override the ps program location and flags
    $PS = $ENV{'PS'} // $defaultPS;
    $PSflags = $ENV{'PSflags'} // $defaultPSflags;

    # Polite termination (SIGTERM) layer-by-layer
    proc_kill_layered($pid, 15); # SIGTERM: polite
    
    # Wait a bit, then brutal kill (SIGKILL) if anything remains
    sleep 1;
    proc_kill_layered($pid, 9); # SIGKILL: brutal
    
    wait ;
    print "After kill :\n";
    system ("head -2 /proc/meminfo");
    exit 137 ;
  };

  alarm $time;
  # parent
  select BAR;
  $| = 1;
  select STDOUT;
  while (<BAR>) { print; }
  close BAR;
} else {
  # child
  # print "pipe_from_fork\n";
  # copy to cmd output to stdout
    
  exec @ARGV[($index+1)..$#ARGV];
}
exit(0);