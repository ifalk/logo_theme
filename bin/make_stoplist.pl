#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_stoplist.pl                   falk@lormoral
#                    13 Jun 2013

use warnings;
use strict;
use English;

use Data::Dumper;
use Carp;
use Carp::Assert;

use Pod::Usage;
use Getopt::Long;

use utf8;

=head1 NAME

make_stoplist.pl

=head1 USAGE

  perl make_stoplist.pl list-of-stoplists

=head1 DESCRIPTION

Produces one unique stoplist from several stoplist files.

=head1 REQUIRED ARGUMENTS

A list of files containing stoplists (list of words to be ignored). The stoplist files are expected to contain one word per line in the utf-8 encoding.

=head1 OPTIONS

=cut


my %opts = (
	    'an_option' => 'default value',
	   );

my @optkeys = (
	       'an_option:s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2) };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

my %sl;

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

foreach my $file (@ARGV) {
  if (open my $fh, '<:encoding(utf-8)', $file) {
    while (my $line = <$fh>) {
      chomp($line);
      next if ($line =~ m{ \A \s* \z }xms);
      my $word = lc($line);
      $word =~ s{ \A \s+ }{}xms;
      $word =~ s{ \s+ \z }{}xms;
      $sl{$word}++;
    }
  } else {
    warn "Couldn't open $file for input: $!\n";
  }
}

use locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE, 'fr_FR.utf8');

foreach my $word (sort keys %sl) {
  print $word, "\n";
}

1;





__END__

=head1 EXIT STATUS

=head1 CONFIGURATION

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

created by template.el.

It looks like the author of this script was negligent
enough to leave the stub unedited.


=head1 AUTHOR

Ingrid Falk, E<lt>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ingrid Falk

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
