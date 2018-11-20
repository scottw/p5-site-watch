package Site::Types;

use Type::Library -base;
use Type::Tiny;
use Mojo::URL;

my $URL = "Type::Tiny"->new(
    name       => "URL",
    constraint => sub { Mojo::URL->new($_)->to_string eq $_ },
    message    => sub {"$_ doesn't look like a URL"},
);

__PACKAGE__->meta->add_type($URL);
__PACKAGE__->meta->make_immutable;

1;
