#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# get_feeds_by_column.pl                   falk@lormoral
#                    17 May 2013

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

get_feeds.pl

=head1 USAGE

 perl get_feeds.pl --journal='lemonde' rss html page   

=head1 DESCRIPTION

Parses the html page given as input and collects the links.


=head1 REQUIRED ARGUMENTS

Html file (or url) containing list of RSS feeds.


=head1 OPTIONS

=over 2

=item journal

Journal name for which the feeds should be collected.

=back

=cut


my %opts = (
	    'journal' => '',
	   );

my @optkeys = (
	       'journal=s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use XML::LibXML;
use XML::LibXML::Iterator;
use LWP::UserAgent;
use Encode;

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/6.0 (compatible;)');


my %GET_FEED4JOURNAL = (
  'lemonde' => sub {
    my ($link) = @_;

    my $feeds;

    my $dom = XML::LibXML->load_html(
      location => $link, 
      recover => 2,
      encoding => 'iso-8859-1',
      );


    my @rss = $dom->findnodes('//td[@class="lien_texte"]/a');

    foreach my $node (@rss) {
      my $link = $node->getAttribute('href');
      my $column_name = $node->textContent();
      
      next if ($column_name =~ m{(vidéo|podcast)}i);
      
      $column_name =~ s{ \A \s+ }{}xms;
      $column_name =~ s{ \s+ \z }{}xms;
      $column_name =~ s{ \s+ }{ }xmsg;
      
      $feeds->{$link}->{$column_name}++;
    }

    return $feeds;
  },

  'lejdd' => sub {
    my ($link) = @_;

    my $dom = XML::LibXML->load_html(
      location => $link, 
      recover => 2,
      # encoding => 'iso-8859-1',
      );
    
    my @rss = $dom->findnodes('//select/option');
    
    my $feeds;
    
    foreach my $node (@rss) {
      my $link = $node->getAttribute('value');
      next if ($link eq '0');
      my $column_name = $node->textContent();
      $column_name =~ s{ \A \s+ }{}xms;
      $column_name =~ s{ \s+ \z }{}xms;
      $column_name =~ s{ \s+ }{ }xmsg;
      
      $feeds->{$link}->{$column_name}++;
    }

    return $feeds;
  },

  'slate' => sub {
    my ($link) = @_;

    my $dom = XML::LibXML->load_html(
      location => $link, 
      recover => 2,
      );

    my @rss = $dom->findnodes('//div[@class="footer_block_title" and text()="Flux rss"]/following-sibling::div/a');

    my $feeds;

    foreach my $node (@rss) {
      my $rel_link = $node->getAttribute('href');
      my $link = join('/', $ARGV[0], $rel_link);
      
      my $column_name = $node->textContent();
      $column_name =~ s{ \A \s+ }{}xms;
      $column_name =~ s{ \s+ \z }{}xms;
      $column_name =~ s{ \s+ }{ }xmsg;
      
      if ($column_name eq 'Slate') {
	$column_name = 'General';
      }

      $feeds->{$link}->{$column_name}++;
    }

    return $feeds;
  },

  'rue89' => sub {
    my ($link) = @_;

    my $feeds;

    my $dom = XML::LibXML->load_html(
      location => $link, 
      recover => 2,
      );


    my @rss = $dom->findnodes('//h1[@class="title89"]/following-sibling::div/a');

    foreach my $node (@rss) {

      my $link = $node->getAttribute('href');

      my $column_name = $node->textContent();
      $column_name =~ s{ \A \s+ }{}xms;
      $column_name =~ s{ \s+ \z }{}xms;
      $column_name =~ s{ \s+ }{ }xmsg;
      
      $column_name =~ s{\ALe flux RSS de (Rue89 )?}{};

      $feeds->{$link}->{$column_name}++;
      
    }
    
    return $feeds;
  },

  'presseurop' => sub {
    my ($link) = @_;

    my $feeds;

    my $dom = XML::LibXML->load_html(
      location => $link, 
      recover => 2,
      );

    my @rss = $dom->findnodes('//h2[text()="Flux généraux"]/following-sibling::ul//a');

    my $base_url = 'http://www.presseurop.eu';

    foreach my $node (@rss) {

      my $rel_link = $node->getAttribute('href');
      my $link = join('', $base_url, $rel_link);

      my $column_name = $node->textContent();
      $column_name =~ s{ \A \s+ }{}xms;
      $column_name =~ s{ \s+ \z }{}xms;
      $column_name =~ s{ \s+ }{ }xmsg;

      $column_name = join('; ', 'Généraux', $column_name);

      $feeds->{$link}->{$column_name}++;

    };

    @rss = $dom->findnodes('//h3/following-sibling::ul/li[1]/a');

    foreach my $node (@rss) {
      my $column_name = $node->textContent();
      $column_name =~ s{ \A \s+ }{}xms;
      $column_name =~ s{ \s+ \z }{}xms;
      $column_name =~ s{ \s+ }{ }xmsg;
      
      my $rel_link = $node->getAttribute('href');
      my $link = join('', $base_url, $rel_link);
      
      $feeds->{$link}->{$column_name}++;
    }

    return $feeds;
  },

  'lequipe' => sub {
    my ($link) = @_;

    my $feeds;
    
    my $content = $ua->get($link)->decoded_content;


    my $dom = XML::LibXML->load_html(
      string => $content, 
      recover => 2,
      );

    my @tr = $dom->findnodes('//tr');
    
  ROW:
    foreach my $row (@tr) {
      my $column_name;
      my $link;
      my @cells = $row->findnodes('td');
      foreach my $td (@cells) {
	my $class = $td->getAttribute('class');
	if ($class eq 'td1') {
	  $column_name = $td->textContent();
	  next ROW if ($column_name =~ m{ vidéo }xmsi);
	  $column_name =~ s{ \s+ }{ }xmsg;
	  $column_name =~ s{ \A \s+ }{}xms;
	  $column_name =~ s{\A Flux \s Rss \s }{}xms;
	  print STDERR "$column_name\n";
	}
	if ($class eq 'td2') {
	  my @rss = $td->findnodes('a[img[@src="RSS/xml.gif"]]');
	  foreach my $node (@rss) {
	    my $link = $node->getAttribute('href');
	    next ROW if ($link =~ m{ video }xmsi);
	    if ($column_name) {
	      $feeds->{$link}->{$column_name}++;
	    } else {
	      print STDERR "No column name for $link\n";
	    }
	  }
	}
      }
    }

    return $feeds;
  },

  'lalibre' => sub {
    my ($link) = @_;

    my $feeds;
    
    my $content = $ua->get($link)->decoded_content;


    my $dom = XML::LibXML->load_html(
      string => $content, 
      recover => 2,
      );

    my $feed_header = ($dom->findnodes('//h3[contains(., "Page d\'accueil")]'))[0];

    my @links = $dom->findnodes('//td[@class="linkRSS"]/a');

    foreach my $a (@links) {
      my $link = $a->getAttribute('href');
      $link = "http://www.lalibre.be/$link";
      print STDERR $link, "\n";
      $feeds->{$link}->{dummy}++;
    }


    return $feeds;
  },
  
  'liberation' => sub {
    my ($link) = @_;

    my $feeds;
    
    my $content = $ua->get($link)->decoded_content;

    my $dom = XML::LibXML->load_html(
      string => $content, 
      recover => 2,
      );

    my @links = $dom->findnodes('//ul[@class="list-rss-stream"]/li/a[1]');

    foreach my $a (@links) {
      my $link = $a->getAttribute('href');
      print STDERR $link, "\n";
      $feeds->{$link}->{dummy}++;
    }

    return $feeds;
  },

  );

my $journal = $opts{journal};

unless ($GET_FEED4JOURNAL{$journal}) {
  print STDERR "Don't know how to collect feeds for journal $journal\n";
};

my $feeds = $GET_FEED4JOURNAL{$journal}->($ARGV[0]);

my %articles;
my %links;

foreach my $feed (keys %{ $feeds }) {

  print STDERR "Parsing $feed\n";

  my $content = $ua->get($feed)->decoded_content;

  my $dom;
  if ($content) {
    eval { $dom = XML::LibXML->load_xml(
	     string => $content,
	     )
    };
    if ($@) {
      warn $@;
      next;
    }
  }
  next unless ($dom);

  my @items = $dom->findnodes('//item');

  foreach my $item (@items) {
    my $link = ($item->findnodes('./link'))[0]->textContent();

    next if ($links{$link});

    ### check redirection
    my $request  = HTTP::Request->new( GET => $link );
    my $response = $ua->request($request);
    if ( $response->is_success) {
      $link = $response->request->uri;
    } else {
      $links{$link}++;
      print STDERR "Request unsuccessfull\n";
      next;
    }
    next if ($links{$link});
    
    $links{$link}++;
    
    foreach my $column (keys %{ $feeds->{$feed} }) {
      $articles{$journal}->{$feed}->{$link}->{column}->{$column}++;
    }

    ### add additional categories if present in item 

    my @categories = map { $_->textContent() } $item->findnodes('./category');

    foreach my $cat (@categories) {
      $articles{$journal}->{$feed}->{$link}->{column}->{$cat}++;
    }
   
    my $date;
    my @date_elements = $item->findnodes('./pubDate');
    if (@date_elements) {
      $date = $date_elements[0]->textContent();
      $articles{$journal}->{$feed}->{$link}->{date} = $date;
    } else {
      print STDERR "No date for $link\n";
    }
  }
}

print Dumper(\%links);

print STDERR "Number of links: ", scalar(keys %links), "\n";


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
