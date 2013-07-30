#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_vocabulary.pl                   falk@lormoral
#                    30 Jul 2013

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

make_vocabulary.pl

=head1 USAGE

 perl make_vocabular.pl --sl=stoplist_file --fl=frequency_list   

=head1 DESCRIPTION

Produces a vocabulary from a frequency list.

The vocabulary is a list of words which we consider most meaningful for the construction of topics.

The vocabulary is built from a list of the most frequent words (currently the 10000 most frequent words as provided by Wortschatz). These words are in preprocessed as follows:

=over 2

=item lowercased 

=item I<'> and everything before it is discarded,

=item words with less than 3 characters are discarded

=item words in a stoplist given as option are discarded

=back

The vocabulary is returned as a perl hash with the words as keys.


=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=over 2

=item sl - stoplist

List of stopwords, a text file, one word per line.

=item fl - frequency list

List of frequent words, a text file , one word per line

=back


=cut

my %opts = (
  'sl' => '',
  'fl' => '',
  );

my @optkeys = (
  'sl:s',
  'fl=s',
  );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

my %sl = ();

if ($opts{sl}) {
  if (open (my $fh, '<:encoding(utf-8)', $opts{sl})) {
    while (my $line = <$fh>) {
      chomp($line);
      $sl{$line}++;
    }
    close $fh;
  } else {
    warn "Couldn't open $opts{sl} for input: $!\n";
  }
}

my %voc;

open (my $fh, '<:encoding(iso-8859-1)', $opts{fl}) or 
  die "Couldn't open $opts{fl} for input: $!\n";

while (my $line = <$fh>) {
  chomp($line);
  $line =~ s{ \A \s+ }{}xms;
  $line =~ s{ \s+ \z }{}xms;

  next if (length($line) <= 3);

  next if ($sl{$line});

  $line = lc($line);

  next if ($sl{$line});

  $line =~ s{ \A .+ ' }{}xms;
  
  next if ($sl{$line});

  $voc{$line}++;
}

close $fh;

print STDERR "Number of words in vocabulary: ", scalar(keys %voc), "\n";

print Dumper(\%voc);

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
