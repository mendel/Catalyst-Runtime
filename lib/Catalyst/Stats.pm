package Catalyst::Stats;

use Moose;

use namespace::clean -except => 'meta';

extends 'Devel::TimingStats';

__PACKAGE__->meta->make_immutable();

1;

__END__

=for stopwords addChild getNodeValue mysub rollup setNodeValue

=head1 NAME

Catalyst::Stats - Catalyst Timing Statistics Class

=head1 SYNOPSIS

    $stats = $c->stats;
    $stats->enable(1);
    $stats->profile($comment);
    $stats->profile(begin => $block_name, comment =>$comment);
    $stats->profile(end => $block_name);
    $elapsed = $stats->elapsed;
    $report = $stats->report;

See L<Catalyst>.

=head1 DESCRIPTION

This module provides the default, simple timing stats collection functionality for Catalyst.
If you want something different set C<< MyApp->stats_class >> in your application module,
e.g.:

    __PACKAGE__->stats_class( "My::Stats" );

If you write your own, your stats object is expected to provide the interface described here.

Catalyst uses this class to report timings of component actions.  You can add
profiling points into your own code to get deeper insight. Typical usage might
be like this:

  sub mysub {
    my ($c, ...) = @_;
    $c->stats->profile(begin => "mysub");
    # code goes here
    ...
    $c->stats->profile("starting critical bit");
    # code here too
    ...
    $c->stats->profile("completed first part of critical bit");
    # more code
    ...
    $c->stats->profile("completed second part of critical bit");
    # more code
    ...
    $c->stats->profile(end => "mysub");
  }

Supposing mysub was called from the action "process" inside a Catalyst
Controller called "service", then the reported timings for the above example
might look something like this:

  .----------------------------------------------------------------+-----------.
  | Action                                                         | Time      |
  +----------------------------------------------------------------+-----------+
  | /service/process                                               | 1.327702s |
  |  mysub                                                         | 0.555555s |
  |   - starting critical bit                                      | 0.111111s |
  |   - completed first part of critical bit                       | 0.333333s |
  |   - completed second part of critical bit                      | 0.111000s |
  | /end                                                           | 0.000160s |
  '----------------------------------------------------------------+-----------'

which means mysub took 0.555555s overall, it took 0.111111s to reach the
critical bit, the first part of the critical bit took 0.333333s, and the second
part 0.111s.


=head1 METHODS

=head2 new

Constructor.

    $stats = Catalyst::Stats->new;

=head2 enable

    $stats->enable(0);
    $stats->enable(1);

Enable or disable stats collection.  By default, stats are enabled after object creation.

=head2 profile

    $stats->profile($comment);
    $stats->profile(begin => $block_name, comment =>$comment);
    $stats->profile(end => $block_name);

Marks a profiling point.  These can appear in pairs, to time the block of code
between the begin/end pairs, or by themselves, in which case the time of
execution to the previous profiling point will be reported.

The argument may be either a single comment string or a list of name-value
pairs.  Thus the following are equivalent:

    $stats->profile($comment);
    $stats->profile(comment => $comment);

The following key names/values may be used:

=over 4

=item * begin => ACTION

Marks the beginning of a block.  The value is used in the description in the
timing report.

=item * end => ACTION

Marks the end of the block.  The name given must match a previous 'begin'.
Correct nesting is recommended, although this module is tolerant of blocks that
are not correctly nested, and the reported timings should accurately reflect the
time taken to execute the block whether properly nested or not.

=item * comment => COMMENT

Comment string; use this to describe the profiling point.  It is combined with
the block action (if any) in the timing report description field.

=item * uid => UID

Assign a predefined unique ID.  This is useful if, for whatever reason, you wish
to relate a profiling point to a different parent than in the natural execution
sequence.

=item * parent => UID

Explicitly relate the profiling point back to the parent with the specified UID.
The profiling point will be ignored if the UID has not been previously defined.

=back

Returns the UID of the current point in the profile tree.  The UID is
automatically assigned if not explicitly given.

=head2 created

    ($seconds, $microseconds) = $stats->created;

Returns the time the object was created, in C<gettimeofday> format, with
Unix epoch seconds followed by microseconds.

=head2 elapsed

    $elapsed = $stats->elapsed

Get the total elapsed time (in seconds) since the object was created.

=head2 report

    print $stats->report ."\n";
    $report = $stats->report;
    @report = $stats->report;

In scalar context, generates a textual report.  In array context, returns the
array of results where each row comprises:

    [ depth, description, time, rollup ]

The depth is the calling stack level of the profiling point.

The description is a combination of the block name and comment.

The time reported for each block is the total execution time for the block, and
the time associated with each intermediate profiling point is the elapsed time
from the previous profiling point.

The 'rollup' flag indicates whether the reported time is the rolled up time for
the block, or the elapsed time from the previous profiling point.

=head1 COMPATIBILITY METHODS

Some components might expect the stats object to be a regular Tree::Simple object.
We've added some compatibility methods to handle this scenario:

=head2 accept

=head2 addChild

=head2 setNodeValue

=head2 getNodeValue

=head2 traverse

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
