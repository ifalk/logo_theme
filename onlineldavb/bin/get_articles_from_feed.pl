#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# get_dna_feeds_by_column.pl                   falk@lormoral
#                    06 May 2013

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

get_dna_feeds_by_column.pl

=head1 USAGE

 perl get_dna_feeds_by_columns.pl dna rss xml page
   

=head1 DESCRIPTION

Parses the rss xml page and extracts items, their links and contents and the corresponding column (or topic).


=head1 REQUIRED ARGUMENTS

Feed xml file.


=head1 OPTIONS

=cut


my %opts = (
	    'an_option' => 'default value',
	   );

my @optkeys = (
	       'an_option:s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use XML::LibXML;
use LWP::UserAgent;

my $xpc = XML::LibXML::XPathContext->new;

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/6.0 (compatible;)');

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0], 
  );


my $feed = $ARGV[0];

my $journal;
if ($feed =~ m{ dna }xms) {
  $journal = 'dna';
} elsif ($feed =~ m{ monde-diplomatique }xms) {
  $journal = 'lmd';
}

my %GETFEED_4_JOURNAL = (
  'dna' => sub {
    my ($item) = @_;

    my ($link, $category, $date) = ('', {}, '');

    $link = ($item->findnodes('./link'))[0]->textContent();


    ### check redirection
    my $request  = HTTP::Request->new( GET => $link );
    my $response = $ua->request($request);
    if ( $response->is_success) {
      $link = $response->request->uri;
    } else {
      print STDERR "Request unsuccessfull\n";
      return ($link, $category, $date);
    }

    foreach my $col ($item->findnodes('category')) {
      my $col_content = $col->textContent();
      $category->{$col_content}++;
    }

    $date = ($item->findnodes('./pubDate'))[0]->textContent();

    return ($link, $category, $date);
  },
  'lmd' => sub {
    my ($item) = @_;

    my ($link, $category, $date) = ('', {}, '');

    $link = ($item->findnodes('./link'))[0]->textContent();
    

    ### check redirection
    my $request  = HTTP::Request->new( GET => $link );
    my $response = $ua->request($request);
    if ( $response->is_success) {
      $link = $response->request->uri;
    } else {
      print STDERR "Request unsuccessfull\n";
      return ($link, $category, $date);
    }

    foreach my $n ($item->findnodes('dc:subject')) {
      my $cat = $n->textContent();
      $category->{$cat}++;
    }

    my $date = ($item->findnodes('dc:date'))[0]->textContent();

    return ($link, $category, $date);

  },
  );


my %GETART_4_JOURNAL = (
  'dna' => sub {
  my ($link) = @_;

  my $text = '';


  my $dom;
  eval { $dom = XML::LibXML->load_html(
	   location => $link,
	   # string => $html_string,
	   # encoding => 'iso-8859-1',
	   recover => 2,
	   suppress_warnings => 1,
	   )
  };
  if ($@) {
    warn $@;
    return $text;
  }

  ### article content

  my @article_els;
  eval { @article_els = $xpc->findnodes('//div[contains(concat(" ", @class, " "), " article ")]/h4 | //div[contains(concat(" ", @class, " "), " article ")]/p', $dom); } ;
  if ($@) {
    warn "$@ when parsing $link\n";
    return $text;
  }

  foreach my $div (@article_els) {
    my $new_text = $div->textContent();
    next if ($new_text =~ m{ \A \s* \z }xms);
    $text = join('', $text, $new_text, "\n");
  }

  return $text;
  },
  'lmd' => sub {
  my ($link) = @_;

  my $text = '';

  my $dom;
  eval { $dom = XML::LibXML->load_html(
	   location => $link,
	   # string => $html_string,
	   # encoding => 'iso-8859-1',
	   recover => 2,
	   suppress_warnings => 1,
	   )
  };
  if ($@) {
    warn $@;
    return $text;
  }

  ### article content

  my $div = ($dom->findnodes('//div[contains(@class, "contenu-principal")]'))[0];

  my @p_nodes = $div->findnodes('.//p');

  foreach my $n (@p_nodes) {
    my $new_text = $n->textContent();
    $text = join("\n", $text, $new_text);
  }


  return $text;


  $div = ($dom->findnodes('//div[contains(@class, "texte")]'))[0];

  @p_nodes = $div->findnodes('*[self::h1 or self::h2 or self::h3 or self::p]');

  foreach my $n (@p_nodes) {
    my $new_text = $n->textContent();
    $text = join("\n", $new_text);
  }

  return $text;
  },
  );

unless ($GETART_4_JOURNAL{$journal}) {
  print STDERR "Unknown journal: $feed\n";
  exit 1;
}

my %articles;
my $art_nbr = 0;
my %links;


my @items = $dom->findnodes('//item');

foreach my $item (@items) {

  my ($link, $category, $date) = $GETFEED_4_JOURNAL{$journal}->($item); 

  next unless ($link);
  next if ($links{$link});
  $links{$link}++;

  next unless ($category);

  foreach my $column (keys %{ $category }) {
    $articles{$journal}->{$feed}->{$link}->{column}->{$column}++;
  }

  if ($date) {
    $articles{$journal}->{$feed}->{$link}->{date} = $date;
  } else {
    warn "No date for $link\n";
  }

}

print STDERR "Number of links: ", scalar(keys %links), "\n";

print Dumper(%links);

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
