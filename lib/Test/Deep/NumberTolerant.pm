use strict;
use warnings;
package Test::Deep::NumberTolerant;
# ABSTRACT: A Test::Deep plugin for testing numbers within a tolerance range
# KEYWORDS: testing tests plugin numbers tolerance range epsilon uncertainty
# vim: set ts=8 sw=4 tw=78 et :

use parent 'Test::Deep::Cmp';
use Number::Tolerant;
use namespace::clean;
use Exporter 'import';

our @EXPORT = qw(within_tolerance);

sub within_tolerance
{
    my ($number, @tolerance_args) = @_;
    return __PACKAGE__->new($number, @tolerance_args);
}

sub init
{
    my $self = shift;
    $self->{tolerance} = tolerance(@_);
}

sub descend
{
    my ($self, $got) = @_;
    return $got == $self->{tolerance};
}

sub diag_message
{
    my ($self, $where) = @_;

    return 'Checking ' . $where . ' against ' . $self->{tolerance};
}

# we do not define a diagnostics sub, so we get the one produced by deep_diag
# showing exactly what part of the data structure failed. This calls renderGot
# and renderVal:

sub renderGot
{
    my ($self, $got) = @_;
    return defined $self->{error_message}
        ? $self->{error_message}
        : 'failed';  # TODO?  $got . ' is not ' . $self->{tolerance};
}

sub renderExp
{
    my $self = shift;
    return 'no error';
}

1;
__END__

=pod

=head1 SYNOPSIS

    use Test::More;
    use Test::Deep;
    use Test::Deep::NumberTolerant;

    cmp_deeply(
        {
            counter => 123,
        },
        {
            counter => within_tolerance(100, plus_or_minus => 50),
        },
        'counter field is 100 plus or minus 50',
    );

=head1 DESCRIPTION

C<Test::Deep::NumberTolerant> provides the sub C<within_tolerance> to indicate
that the data being tested matches the equivalent C<tolerance(...)> value
from L<Number::Tolerant>.

I wrote this because I found myself doing this a lot:

    cmp_deeply(
        $thing,
        methods(
            delete_time => methods(epoch => code( sub { $_[0] == tolerance(time(), offset => (-2,0)) || (0, "got $_[0], expected ", time()) } )),
        ),
        'object has been deleted',
    );

With this module, this can be simplified to the much more readable:

    cmp_deeply(
        $thing,
        methods(
            delete_time => methods(epoch => within_tolerance(time(), offset => (-2,0))),
        ),
        'object has been deleted',
    );

(Note that for the simple C<plus_or_minus> case, you can also use L<Test::Deep/num>.)

=head1 FUNCTIONS

=head2 C<within_tolerance>

Exported by default; to be used within a L<Test::Deep> comparison function
such as L<cmp_deeply|Test::Deep/COMPARISON FUNCTIONS>.  Accepted arguments are
the same as for C<L<Number::Tolerant/tolerance>>.

=for Pod::Coverage
descend
diag_message
init
renderExp
renderGot

=head1 SUPPORT

=for stopwords irc

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Test-Deep-NumberTolerant>
(or L<bug-Test-Deep-NumberTolerant@rt.cpan.org|mailto:bug-Test-Deep-NumberTolerant@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 SEE ALSO

=for :list
* L<Test::Deep>
* L<Number::Tolerant>
* L<Test::Deep::Between>

=cut
