package SingletonMethod;
use strict;
use warnings;
use Carp qw/croak/;
use Exporter qw/import/;
use Scalar::Util qw/blessed refaddr/;
our $VERSION = '0.01';

our @EXPORT_OK = qw(define_singleton_methods);

sub define_singleton_methods {
    my ($instance, $spec) = @_;
    my $base_class = blessed $instance;
    croak 'first argument must be blessed object' unless $base_class;
    my $pkg = create_temporary_package($instance);
    install_methods($pkg, $base_class, $spec);
    bless $instance, $pkg;
}

sub create_temporary_package {
    my $obj = shift;
    my $suffix = refaddr $obj;
    my $pkg = "SingletonMethod::__ANON__::$suffix";
    {
        no strict 'refs';
        *{"$pkg\::DESTROY"} = sub {
            delete $SingletonMethod::__ANON__::{"$suffix\::"}
                or die "deleting temporary package failed";
        };
    }
    return $pkg;
}

sub install_methods {
    my ($pkg, $base_class, $methods) = @_;
    no strict 'refs';
    push @{"$pkg\::ISA"}, $base_class;
    for my $method_name (keys %$methods) {
        *{"$pkg\::$method_name"} = $methods->{$method_name};
    }
}

1;
__END__

=head1 NAME

SingletonMethod - define singleton method

=head1 SYNOPSIS

  use SingletonMethod qw/define_singleton_methods/;
  
  my $foo = Foo->new();
  
  define_singleton_methods($foo, {
      foo => sub { say 'foo!' },
      bar => sub { say 'bar!' },
  });
  
  # now you can use `foo', `bar'
  $foo->foo(); # prints 'foo!'
  $foo->bar(); # prints 'bar!'

=head1 DESCRIPTION

SingletonMethod module is utility to define singleton methods.

=head1 AUTHOR

Tom Tsuruhara E<lt>tom.lpsd@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
