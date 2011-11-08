package Algorithm::ConvexHull;

our $VERSION = 0.01;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(convex_hull_2d);

BEGIN {
    local ($@, $SIG{__DIE__});
    unless (eval "use Sort::Key::Radix qw(nkeysort); 1") {
        no strict 'refs';
        *nkeysort = sub (&@) {
            shift;
            sort { $a->[0] <=> $b->[0] } @_
        }
    }
}

sub convex_hull_2d {
    return @_ if @_ < 2;

    my @p = nkeysort { $_->[0] } @_;

    my (@u, @l);
    my $i = 0;
    while ($i < @p) {
        my $iu = my $il = $i;
        my ($x, $yu) = @{$p[$i]};
        my $yl = $yu;
        # search for upper and lower Y for the current X
        while (++$i < @p and $p[$i][0] == $x) {
            my $y = $p[$i][1];
            if ($y < $yl) {
                $il = $i;
                $yl = $y;
            }
            elsif ($y > $yu) {
                $iu = $i;
                $yu = $y;
            }
        }
        while (@l >= 2) {
            my ($ox, $oy) = @{$l[-2]};
            last if ($l[-1][1] - $oy) * ($x - $ox) < ($yl - $oy) * ($l[-1][0] - $ox);
            pop @l;
        }
        push @l, $p[$il];
        while (@u >= 2) {
            my ($ox, $oy) = @{$u[-2]};
            last if ($u[-1][1] - $oy) * ($x - $ox) > ($yu - $oy) * ($u[-1][0] - $ox);
            pop @u;
        }
        push @u, $p[$iu];
    }

    # remove points from the upper hull extremes when they are already
    # on the lower hull:
    shift @u if $u[0][1] == $l[0][1];
    pop @u if @u and $u[-1][1] == $l[-1][1];

    return (@l, reverse @u);
}

1;
__END__


=head1 NAME

Algorithm::ConvexHull - Calculate the convex hull of a set of 2D points

=head1 SYNOPSIS

  use Algorithm::ConvexHull qw(convex_hull_2d);
  my @ch = convex_hull_2d([$x0, $y0], [$x1, $y1],...,[$xn, $yn]);

=head1 DESCRIPTION

This package implements a variation of the Andrew's monotone chain
convex hull algorithm that is able to generate the convex hull of an
arbitrary set of 2D points.

When the module L<Sort::Key::Radix> is also installed, this module
uses it to sort the set of points making the algorithm O(N).

Otherwise, Perl builtin sorting algorithm is using resulting in a
O(N*logN) complexity algorithm.

=head2 API

This module provides the following functions:

=over 4

=item @ch = convex_hull_2d(@points2d)

Return the ordered list of points forming the convex hull.

The values returned are not copies but references to the same arrays
passed as input.

=back

=head1 SEE ALSO

There are other modules in CPAN implementing convex hull algorithms:
L<Math::ConvexHull>, L<Math::Geometry::Planar>,
L<Math::Polygon::Convex>.

Wikipedia page about the convex hull: L<http://en.wikipedia.org/wiki/Convex_hull_algorithms>.

Monotone chain algorithm description at Wikibooks:
L<http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain>

Monotone chain algorithm description at Algorithmist:
L<http://www.algorithmist.com/index.php/Monotone_Chain_Convex_Hull>.

=head1 TODO

Implement other algorithms and support the 3D case.

Add an XS version.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador FandiE<ntilde>o (sfandino@yahoo.com).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
