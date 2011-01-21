package Data::Localize::Storage::MongoDB;
use Any::Moose;
use MongoDB;

with 'Data::Localize::Storage';

has 'database'   => ( is => 'ro', isa => 'MongoDB::Database', required => 1 );
has 'collection' => (
    is      => 'ro',
    isa     => 'MongoDB::Collection',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->database->get_collection( $self->lang );
    }
);

sub get {
    my ( $self, $key ) = @_;
    my $result = $self->collection->find_one({ _id => $key });
    return () unless $result;
    return $result->{'msg'};
}

sub set {
    my ( $self, $key, $value ) = @_;
    $self->collection->save({ _id => $key, msg => $value }, { safe => 1 });
    return;
}

__PACKAGE__->meta->make_immutable();

no Any::Moose; 1;

# ABSTRACT: A MongoDB storage backend for Data::Localize

=head1 SYNOPSIS

  use Data::Localize::Storage::MongoDB;

  my $conn =  MongoDB::Connection->new( host => 'localhost' );

  my $loc = Data::Localize->new;
  $loc->add_localizer(
      class         => 'Gettext',
      path          => 't/001-basic/*.po',
      storage_class => 'MongoDB',
      storage_args  => {
          database => $conn->get_database('i18n')
      }
  );

  $loc->set_languages('ja');
  print $loc->localize('Hello, stranger!', '牧大輔');

  $loc->set_languages('en');
  print $loc->localize_for('Hello, stranger!', 'Stevan');

=head1 DESCRIPTION

This is a simple L<MongoDB> storage backend for L<Data::Localize>.

=method get

This is used internally by L<Data::Localize>.

=method set

This is used internally by L<Data::Localize>.

