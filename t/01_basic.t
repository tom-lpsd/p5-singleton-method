use strict;
use warnings;
use Test::More tests => 8;
use Test::Exception;
use SingletonMethod qw/define_singleton_methods/;

my ($foo1, $foo2) = (Foo->new(), Foo->new());
is($foo1->foo, 100, 'original method foo');
is($foo1->bar, 200, 'original method bar');

define_singleton_methods($foo1, {
    baz => sub { return 300 },
});

is($foo1->baz, 300, 'singleton method baz');
is($foo1->foo, 100, 'still can use original method foo');
is($foo1->bar, 200, 'still can use original method bar');

is($foo2->foo, 100, 'foo2: method foo');
is($foo2->bar, 200, 'foo2: method bar');
dies_ok { $foo2->baz } 'foo2 cannot respond to baz';

package Foo;
use strict;
use warnings;

sub new {
    my $class = shift;
    return bless { @_ }, $class;
}

sub foo {
    return 100;
}

sub bar {
    return 200;
}
