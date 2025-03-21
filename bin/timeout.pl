#!/usr/bin/perl

$index = 0;

if ($ARGV[0] =~ /-s/) {
    $index = 2; 
}

$time = $ARGV[$index] or die "Arg $index is time limit";
$cmd = join (" ", @ARGV[($index+1)..$#ARGV]);

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
    %proc = ();    # Clear previous data
    %parproc = (); # Clear previous data
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
                depth => undef, # Initialize depth field
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
    return () unless defined $parproc{$pid};
    my $s = $parproc{$pid};
    while ($s =~ /^(?<pid>\d+)\s+(?<rest>.*)/x) {
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
sub proc_get_children_r($); # Forward declaration

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
# nothing
# Modifies:
# kills processes
sub proc_kill($ $) {
    my ($pid, $sig) = @_;
    if (!defined $proc{$pid}) {
        # print STDERR "Warning: PID $pid not found, skipping kill ($sig)\n";
        return;
    }
    my @arr = ($pid, proc_get_children_r $pid);
    # print STDERR "Killing ($sig): @arr\n";
    my $killed = kill $sig, @arr;
    if ($killed != scalar @arr) {
        # print STDERR "Could not kill all: killed $killed of " . scalar(@arr) . "\n";
    }
}

# New function:
# calculate_depth   - calculate depth of each process bottom-up, store in %proc
# Inputs:
# $root_pid   - root process ID
# Returns:
# nothing (updates %proc with depth values)
# Modifies:
# %proc (adds depth field)

sub calculate_depth {
    my ($pid) = @_;
    sub depth_of {
        my ($pid) = @_;
        return $proc{$pid}->{depth} if defined $proc{$pid}->{depth};
        my @children = proc_get_children($pid);
        if (!@children) {
            $proc{$pid}->{depth} = 0;
        } else {
            my $max_child_depth = 0;
            for my $child (@children) {
                my $child_depth = depth_of($child);
                $max_child_depth = $child_depth if $child_depth > $max_child_depth;
            }
            $proc{$pid}->{depth} = $max_child_depth + 1;
        }
        return $proc{$pid}->{depth};
    }
    depth_of($pid);
}

# New function:
# group_by_depth    - group processes by their depth in %proc
# Inputs:
# $root_pid   - root process ID
# Returns:
# hash of depth => [pid1, pid2, ...]
# Modifies:
# nothing

sub group_by_depth {
    my ($pid) = @_;
    calculate_depth($pid);
    my %by_depth;
    for my $pid (keys %proc) {
        next unless defined $proc{$pid}->{depth};
        push @{$by_depth{$proc{$pid}->{depth}}}, $pid;
    }
    return %by_depth;
}

# Debug: uncomment to trace process tree
# sub print_tree {
#    my ($pid, $indent) = @_;
#    my $depth = $proc{$pid}->{depth} // "N/A";
#    my $cmd = $proc{$pid}->{cmd};
#    my $args = $proc{$pid}->{args} || "";
#    print "  " x $indent . "PID=$pid, PPID=$proc{$pid}->{ppid}, Depth=$depth, Cmd=$cmd $args\n";
#    my @children = proc_get_children($pid);
#    for my $child (@children) {
#        print_tree($child, $indent + 1);
#    }
#}

# New function:
# proc_kill_layered - kill processes layer-by-layer from leaves to root
# Inputs:
# $pid      - PID to kill
# $sig      - signal to send
# Returns:
# nothing
# Modifies:
# kills processes
sub proc_kill_layered {
    my ($pid, $sig) = @_;
    if (!defined $proc{$pid}) {
        # print STDERR "Warning: PID $pid not found, skipping layered kill\n";
        return;
    }
    my %by_depth = group_by_depth($pid);
    my $max_depth = (sort { $b <=> $a } keys %by_depth)[0] // 0;

    for my $depth (0..$max_depth) {
        my @pids_to_kill = @{$by_depth{$depth} // []};
        next unless @pids_to_kill;
        my @all_pids;
        for my $target_pid (@pids_to_kill) {
            push @all_pids, $target_pid, proc_get_children_r($target_pid);
        }
        my %seen;
        @all_pids = grep { !$seen{$_}++ } @all_pids;
        # print STDERR "Killing layer at depth $depth ($sig): @all_pids\n";
        my $killed = kill $sig, @all_pids;
        if ($killed != scalar @all_pids) {
            # print STDERR "Could not kill all at depth $depth: killed $killed of " . scalar(@all_pids) . "\n";
        }
        sleep 1 unless $depth == $max_depth; # No sleep after the last layer
    }
}

select STDOUT;
$| = 1; 

if (my $pid = pipe_from_fork('BAR')) {
    $SIG{ALRM} = sub {
        print "TIME LIMIT: Killed by timeout after $time seconds\n";
        system("head -2 /proc/meminfo");
        proc_gather();
        # print "Gathering processes for PID $pid\n";
        # print "Initial process tree for PID $pid:\n";
        # print_tree($pid, 0);
        proc_kill_layered($pid, 15); # SIGTERM layered
        proc_gather();
        # if (defined $proc{$pid}) {
        #    print "Remaining processes after SIGTERM:\n";
        #    print_tree($pid, 0);
        # } else {
        #    print "No processes remaining for PID $pid after SIGTERM\n";
        # }
        sleep 1;
        proc_kill($pid, 9); # SIGKILL
        # print "Waiting for all children to terminate...\n";
        while (wait() != -1) { }
        print "After kill:\n";
        system("head -2 /proc/meminfo");
        exit 137;
    };

    alarm $time;
    select BAR;
    $| = 1;
    select STDOUT;
    while (<BAR>) { print; }
    close BAR;
} else {
    exec @ARGV[($index+1)..$#ARGV];
}
exit(0);

