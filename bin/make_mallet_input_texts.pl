#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_mallet_input_texts.pl                   falk@lormoral
#                    12 Jun 2013

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

make_mallet_input_texts.pl

=head1 USAGE

 perl make_mallet_input_texts.pl text collection in html format   

=head1 DESCRIPTION

Creates a text collection to be used as input for the mallet topic modeler.

Input is an html file containing the texts previously collected from the web.

=head1 REQUIRED ARGUMENTS

The html input file.

=head1 OPTIONS

=over 2

=item dir_name, required

The directory name where the text files should be stored.

=back


=cut


my %opts = (
	    'dir_name' => '',
	   );

my @optkeys = (
	       'dir_name=s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(20); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

use XML::LibXML;
use URI::URL;
use File::Spec;

my $dom;
my %file_names;

eval { $dom = XML::LibXML->load_html(
	 location => $ARGV[0],
	 recover => 2,
	 suppress_warnings => 1,
	 )
};

if ($@) {
  die $@;
}

unless ($dom) {
  die "Unsuccessful parse\n";
}

my @articles = $dom->findnodes('//div[@class="article"]');

foreach my $article (@articles) {
  my $dd_link = ($article->findnodes('.//dt[text()="URL"]/following-sibling::dd/a'))[0]->textContent();
  $dd_link =~ s{ \s+ }{}xms;

  my $url = new URI::URL $dd_link;
  my $url_path = $url->path();
  $url_path =~ s{ / \s* \z }{}xms;
  my (undef, undef, $file_name) = File::Spec->splitpath($url_path, 0);
  $file_name =~ s{ \. html \s* \z }{}xms;
  $file_name =~ s{ ( _ \d+ ) + \z }{}xms;

  $file_name = "$file_name.txt";

  $file_name = join('/', $opts{dir_name}, $file_name);
  print STDERR $file_name, "\n";

  my $article_text = ($article->findnodes('.//div[@class="text-content"]'))[0]->textContent();

  if (open (my $fh, '>:encoding(utf-8)', $file_name)) {
    print $fh $article_text, "\n";
    close $fh;
  } else {
    warn "Couldn't open $file_name for output: $!\n";
  }
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
