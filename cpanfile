requires 'perl' => 5.014000;

requires 'Moose';
requires 'Pod::Weaver::Role::Dialect';
requires 'Pod::Elemental::Transformer';
requires 'Capture::Tiny';
requires 'Moose::Autobox';
requires 'namespace::clean';

on test => sub {
   requires 'Test::More' => 0.88;
   requires 'Pod::Elemental';
   requires 'Pod::Elemental::Transformer::Pod5';
};
