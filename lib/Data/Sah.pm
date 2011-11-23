package Data::Sah;
BEGIN {
  $Data::Sah::VERSION = '0.01';
}

use 5.010;
use Moo;
use Log::Any qw($log);
use vars qw($AUTOLOAD);

has _merger => (is => 'rw');

has compilers => (
    is      => 'rw',
    default => sub { {} },
);

has types => (
    is      => 'rw',
    default => sub { {} },
);

has func_sets => (
    is      => 'rw',
    default => sub { {} },
);

our $type_re     = qr/\A[A-Za-z_]\w*\z/;
our $compiler_re = qr/\A[A-Za-z_]\w*\z/;

sub get_compiler {
    my ($self, $name) = @_;
    $log->trace("-> get_compiler($name)");
    return $self->compilers->{$name} if $self->compilers->{$name};

    die "Invalid compiler name `$name`" unless $name =~ $compiler_re;
    my $module = "Data::Sah::Compiler::$name";
    if (!eval "require $module; 1") {
        die "Can't load compiler module $module".($@ ? ": $@" : "");
    }

    my $obj = $module->new(main => $self);
    $self->compilers->{$name} = $obj;

    #$log->trace("<- get_compiler($module)");
    return $obj;
}

sub _register_schema_as_type {
    my ($self, $schema, $typename) = @_;
    # XXX check syntax of typename, normalize schema, add into existing types
}

sub normalize_var {
    my ($self, $var, $curpath) = @_;
    die "Not yet implemented";
}

sub is_func {
    my ($self, $name) = @_;
    die "Not yet implemented";
}

sub compile {
    my ($self, $compiler_name, %args) = @_;
    my $c = $self->get_compiler($compiler_name);
    $c->compile(%args);
}

sub perl {
    my ($self, %args) = @_;
    return $self->compile('perl', %args);
}

sub human {
    my ($self, @args) = @_;
    return $self->get_compiler('human') unless @args;
    return $self->emit('human', @args);
}

sub js {
    my ($self, @args) = @_;
    return $self->get_compiler('js') unless @args;
    return $self->emit('js', @args);
}

sub perl_sub {
    die "Not yet implemented";
}

sub AUTOLOAD {
    my ($pkg, $sub) = $AUTOLOAD =~ /(.+)::(.+)/;
    die "Undefined subroutine $AUTOLOAD"
        unless $sub =~ /^(
                            _dump|
                            normalize_schema|
                            parse_string_shortcuts
                        )$/x;
    $pkg =~ s!::!/!g;
    require "$pkg/al_$sub.pm";
    goto &$AUTOLOAD;
}

1;
# ABSTRACT: Schema for data structures




__END__
=pod

=head1 NAME

Data::Sah - Schema for data structures

=head1 VERSION

version 0.01

=head1 SYNOPSIS

 use Data::Sah;
 my $sah = Data::Sah->new;

 # (NOT YET IMPLEMENTED) compile schema to Perl sub
 my $schema = ['array*' => {min_len=>1, of=>'int*'}];
 my $sub = $sah->perl_sub($schema);

 # validate data using the compiled sub
 my $res;
 $res = $sub->([1, 2, 3]);
 die $res->err_msg if !$res->is_success; # OK
 $res = $sub->({});
 die $res->err_msg if !$res->is_success; # dies: 'Data not an array'

 # (NOT YET IMPLEMENTED) convert schema to JavaScript code
 $schema = [int => {req=>1, min=>10, max=>99, div_by=>3}];
 print
   '<script>',
   $sah->js($schema, {name => '_validate'}),
   'function validate(data) {
      res = _validate(data)
      if (res.is_success) {
        return true
      } else {
        alert(res.err_msg)
        return false
      }
   }
   </script>
   <form onClick="return validate(this.form.data.value)">
     Please enter a number between 10 and 99 that is divisible by 3:
     <input name=data>
     <input type=submit>
   </form>';

=head1 DESCRIPTION

B<IMPLEMENTATION NOTE:> This is a very early release, only a tiny bit is
implemented.

Sah is a schema language to validate data structures.

Features/highlights:

=over 4

=item * Schema expressed as data structure

Using data structure as schema simplifies schema parsing, enables easier
manipulation (composition, merging, etc) of schema. For your convenience, Sah
accepts a variety of forms and shortcuts, which will be converted into a
normalized data structure form.

Some examples of schema:

 # a string
 'str'

 # a required string
 'str*'

 # same thing
 [str => {req=>1}]

 # a 3x3 matrix of required integers
 [array => {req=>1, len=>3, of=>
   [array => {req=>1, len=>3, of=>
     'int*'}]}]

See L<Data::Sah::Manual::Schema> for full description of the syntax.

=item * Easy conversion to other programming language (Perl, etc)

Sah schema can be converted into Perl, JavaScript, and any other programming
language as long as a compiler for that language exists. This means you only
need to write schema once and use it to validate data anywhere. Compilation to
target language enables faster validation speed. The generated Perl/JavaScript
code can run without this module.

=item * Conversion into human description text

Sah schema can also be converted into human text, technically it's just another
compiler. This can be used to generate specification document, error messages,
etc directly from the schema. This saves you from having to write for many
common error messages (but you can supply your own when needed).

The human text is translateable and can be output in various forms (as a single
sentence, single paragraph, or multiple paragraphs) and formats (text, HTML, raw
markup).

=item * Ability to express pretty complex schema

Sah supports common types and a quite rich set of type attributes for each type.
You can flexibly specify valid/invalid ranges of values, dependencies, conflict
rules, etc. There are also filters/functions and expressions.

=item * Extensible

You can add your own types, type attributes, and functions if what you need is
not supported out of the box.

=item * Emphasis on reusability

You can define schemas in terms of other schemas. Example:

 # array of unique gmail addresses
 [array => {uniq => 1, of => [email => {match => qr/gmail\.com$/}]}]

In the above example, the schema is based on 'email'. Email can be a type or
just another schema:

  # definition of email
  [str => {match => ".+\@.+"}]

You can also define in terms of other schemas with some modification, a la OO
inheritance.

 # schema: even
 [int => {div_by=>2}]

 # schema: pos_even
 [even => {min=>0}]

In the above example, 'pos_even' is defined from 'even' with an additional
clause (min=>0). As a matter of fact you can also override and B<remove>
restrictions from your base schema, for even more flexibility.

 # schema: pos_even_or_odd
 [pos_even => {"!div_by"=>2}] # remove the divisible_by attribute

The above example makes 'even_or_odd' effectively equivalent to positive
integer.

See L<Data::Sah::Manual::Schema> for more about clause set merging.

=back

To get started, see L<Data::Sah::Manual::Tutorial>.

This module uses L<Moo> for object system and L<Log::Any> for logging.

=head1 FAQ

=head3 Why choose Sah?

C<Flexibility>. Sah comes out of the box with a rich set of types and clauses.
It supports functions, prefilters/postfilters, expressions, and custom (&
translated) error messages, among other things. It can validate nested and
circular data structures.

B<Portability>. Instead of mixing Perl in schema, Sah lets users specify
functions/expressions using a minilanguage (L<Language::Expr>) which in turn
will be converted into target languages (Perl, JavaScript, etc). While this is
slightly more cumbersome, it makes schema easier to port/compile to languages
other than Perl. The default type hierarchy is also more language-neutral
instead of being more Perl-specific like the Moose type system.

B<Validation speed>. Many other validation modules interpret schema on the fly
instead of compiling it directly to Perl code. While this is sufficiently speedy
for many cases, it can be one order of magnitude or more slower than compiled
schema for more complex cases.

C<Reusability>. Sah emphasizes reusability by: 1) encouraging using the same
schema in multiple target languages (Perl, JavaScript, etc); 2) allowing a
schema to be based on a parent schema (a la OO inheritance), and allowing child
schema to add/replace/remove clauses.

C<Extensibility>. Sah makes it easy to add new clauses and new types.

=head3 The name?

Sah is an Indonesian word, meaning 'valid'. It's short.

The previous incarnation of this module uses the namespace Data::Schema, started
in 2009. Since then, there are many added features, a few removed ones, some
syntax and terminology changes, thus the new name.

=head1 MODULE ORGANIZATION

B<Data::Sah::Type::*> roles specifies a type, e.g. Data::Sah::Type::bool
specifies the bool type.

B<Data::Sah::FuncSet::*> roles specifies bundles of functions, e.g.
Data::Sah::FuncSet::Core specifies the core/standard functions.

B<Data::Sah::Compiler::$LANG::> is for compilers. Each compiler (if derived from
BaseCompiler) might further contain ::TH::* and ::FuncSet::* to implement
appropriate functionalities, e.g. Data::Sah::Compiler::perl::TH::bool is the
'boolean' type handler for the Perl compiler.

B<Data::Sah::Lang::$LANGCODE::*> namespace is reserved for modules that contain
translations. $LANGCODE is 2-letter language code, or
2-letter+underscore+2-letter locale code (e.g. C<id> for Indonesian, C<zh_CN>
for Mandarin). Language submodules follows the organization of other modules,
e.g. Data::Sah::Lang::en::Type::int, Data::Sah::Lang::id::FuncSet::Core, etc.

B<Data::Sah::Schema::> namespace is reserved for modules that contain bundles of
schemas. For example, L<Data::Sah::Schema::CPANMeta> contains the schema to
validate CPAN META.yml. L<Data::Sah::Schema::Sah> contains the schema for Sah
schema itself.

B<Data::Sah::TypeX::$TYPENAME::$CLAUSENAME> namespace can be used to name
distributions that extend an existing Sah type by introducing a new clause for
it. It must also contain Perl and Human compiler implementations for it, and
English translations. For example, Data::Sah::TypeX::int::is_prime is a
distribution that adds C<is_prime> clause to the C<int> type. It will contain
the following packages inside: Data::Sah::Type::int,
Data::Sah::Compiler::{perl,human}::TH::int. Other compilers' implementation can
be packaged under B<Data::Sah::TypeX::$TYPENAME::$CLAUSENAME::$COMPILERNAME>,
e.g. Data::Sah::TypeX::int::is_prime::js distribution. Language can be put in
B<Data::Sah::Lang::$LANGCODE::TypeX::int::is_prime>.

=head1 SEE ALSO

B<Moose> has a type system. B<MooseX::Params::Validate>, among others, can
validate method parameters based on this.

Some other data validation and data schema modules on CPAN:
L<Data::FormValidator>, L<Params::Validate>, L<Data::Rx>, L<Kwalify>,
L<Data::Verifier>, L<Data::Validator>, L<JSON::Schema>, L<Validation::Class>.

=head1 ATTRIBUTES

=head2 compilers => HASH

A mapping of compiler name and compiler (Data::Sah::Compiler::*) objects.

=head2 types => HASH

List of currently known types (keys are type names, e.g. 'int', values are
strings (role name) or hashes (schema). Schemas can also be types (e.g.
'even_int' => ['int' => {div_by=>2}]).

During compilation, since a schema can define subschemas (in other words, new
types), some types might be added locally for the duration of compilation for
that schema.

=head2 func_sets => HASH

List of currently known function sets (keys are set names, e.g. 'Core', values
are Data::Sah::FuncSet::* objects).

=head1 METHODS

=head2 new() => OBJ

Create a new Data::Sah instance.

=head2 $sah->get_compiler($name) => OBJ

Get compiler object. "Data::Sah::Compiler::$name" will be loaded first if not
already so.

Example:

 my $plc = $sah->get_compiler("perl"); # loads Data::Sah::Compiler::perl

=head2 $sah->parse_string_shortcuts($str)

Parse string form shortcut notations, like "int*", "str[]", etc and return
either string $str unchanged if there is no shortcuts found, or array form, or
undef if there is an error.

Example: parse_string_shortcuts("int*") -> [int => {required=>1}]

Autoloaded.

=head2 $sah->normalize_schema($schema) => HASH

Normalize a schema into the hash form ({type=>..., clause_sets=>..., def=>...)
as well as do some sanity checks on it. Returns the normalized schema if
succeeds, or an error message string if fails.

Can also be used as a function. Autoloaded.

=head2 $sah->normalize_var($var) => STR

Normalize a variable name in expression into its fully qualified/absolute form.
For example: foo -> schema:/abs/path/foo.

 [int => {min => 10, 'max=' => '2*$min'}]

$min in the above expression will be normalized as 'schema:/clause_sets/0/min'.

Autoloaded. Not yet implemented.

=head2 is_func($name) -> BOOL

Check whether function named $name is known. Alternatively you can also search
in B<func_sets()> yourself.

Not yet implemented.

=head2 compile($compiler_name, %compiler_args) => RES

Basically just a shortcut for get_compiler() and set %compiler_args to the
particular compiler.

=head2 perl(%args) => RES

Shortcut for $sah->compile('perl', %args).

=head2 human(%args) => RES

Shortcut for $sah->compile('human', %args).

=head2 js(%args) => RES

Shortcut for $sah->compile('js', %args).

=head2 perl_sub(%args) => CODEREF

Shortcut for $sah->compile('perl', form=>'sub', %args) and eval'ing the
resulting code into a Perl subroutine.

Not yet implemented.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

