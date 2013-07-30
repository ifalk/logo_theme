#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_mallet_input_texts.pl                   falk@lormoral
#                    29/07/2013

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

 perl make_mallet_input_texts.pl --voc=vocabulary.pl collection of links given as perl hashes

=head1 DESCRIPTION

Creates a text collection to be used as input for the mallet topic modeler.

Input is one or more perl hashes containing links where the texts should be retrieved from.

The script attempts to extract only the text content of the articles. The text is split into words at white spaces. 

Words which are not in a vocabulary given as argument are discarded.

=head1 REQUIRED ARGUMENTS

Perl hashes containing links where the texts should be retrieved from.

The expected format is the following. The links should be the keys of the perl hashes.

 $VAR1 = {
          'http://www.lalibre.be/regions/bruxelles/breve-51ea06d23570927a6c526427' => 1,
          'http://www.lalibre.be/debats/opinions/je-veux-ce-joooooob-tout-cela-est-il-legal-madame-fremault-51de6d82357057b2f57ab2fd' => 1,
          'http://www.lalibre.be/light/societe/le-printemps-pluvieux-sauve-l-ete-des-kayakistes-belges-51ed7beb35705d9341939304' => 1,
          'http://www.lalibre.be/culture/cinema/dans-l-image-manquante-rithy-panh-interroge-les-ideologies-meurtrieres-51b7359ae4b0de6db975b6ab' => 1,
          ...


=head1 OPTIONS

=over 2

=item dir_name, required

The directory name where the text files should be stored.

=item voc, the vocabulary (optional)

A perl hash, with words as keys, containing those words which are considered most meaningful for the topic construction.

Sample format:

 $VAR1 = {
          'sacs' => 1,
          "f\x{e9}d\x{e9}rations" => 1,
          'maystadt' => 1,
          'bande' => 1,
          'saisir' => 1,
          "\x{e9}conomiste" => 1,
          ....

=back


=cut


my %opts = (
  'dir_name' => '',
  'voc' => '',
  );

my @optkeys = (
  'dir_name=s',
  'voc:s',
  );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(20); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

my %voc;

if ($opts{voc}) {
  %voc = %{ do $opts{voc} };
}

sub filter_with_vocabulary {
  my ($text) = @_;

  my $filtered_text;

  $text =~ s{[«»"']}{}xmsg;
  $text =~ s{[\.\,!?(\)\][]]}{ }xmsg;
  $text =~ s{’}{'}xmsg;

  my @words = split(/\s+/, $text);
	
  my @filtered;
  foreach my $w (@words) {
    next if (length($w) <= 3);
    
    next if ($w =~ m{ \d+ }xms);

    next unless ($voc{$w});
    
    $w = lc($w);
    $w =~ s{ \A .+ ' }{}xms;
    
    next unless ($voc{$w});
    
    push(@filtered, $w);
  }
  
  if (@filtered) {
    $filtered_text = join(' ', @filtered);
  }

  return $filtered_text;
}


use XML::LibXML;
use URI::URL;
use File::Spec;
use LWP::UserAgent;
use XML::LibXML;


my $lwp_ua = LWP::UserAgent->new;
$lwp_ua->agent('Mozilla/6.0 (compatible;)');

my $xpc = XML::LibXML::XPathContext->new;

my %GETART_4_JOURNAL = (
  # 'lemonde' => sub {
  #   my ($link) = @_;
    
  #   my $text_content = [];
    
  #   my $dom;
  #   eval { $dom = XML::LibXML->load_html(
  # 	     location => $link,
  # 	     # encoding => 'iso-8859-1',
  # 	     recover => 2,
  # 	     suppress_warnings => 1,
  # 	     )
  #   };
  #   if ($@) {
  #     warn $@;
  #     return $text_content;
  #   }

  #   unless ($dom) {
  #     print STDERR "Unsuccessful parse\n";
  #     return $text_content;
  #   }

  #   my @article_nodes = $dom->findnodes('//article');
  #   my @blog_nodes = $dom->findnodes('//div[starts-with(@id, "post")]');

  #   push(@article_nodes, @blog_nodes);

  #   if (@article_nodes) {
  #     my @todo = grep { $_->nodeType() == 1 } $article_nodes[0]->childNodes();

  #     while (@todo) {
  # 	my $cur = shift(@todo);


  # 	my $name = $cur->localname();

  # 	if ($link =~ m{ turquie-la-police }xms) {
  # 	  if ($name eq 'p') {
  # 	    if (my $first = $cur->firstChild()) {
  # 	      next if ($first->nodeType() == 1 and
  # 		       $first->localname() eq 'section');
  # 	    }
  # 	  }
  # 	}

  # 	next if ($name eq 'p' and $cur->hasAttribute('class') and $cur->getAttribute('class') =~ m{ \b lire \b }xmsi);

  # 	next if ($name eq 'p' and $cur->hasAttribute('itemprop') and $cur->getAttribute('itemprop') =~ m{ \b author \b }xmsi);

  # 	if ($name eq 'p' or $name =~ m{ h [1-4] }xms) {
  # 	  my $text = $cur->textContent();

  # 	  if (%voc) {
  # 	    my @words = split(/\s+/, $text);

  # 	    my @filtered;
  # 	    foreach my $w (@words) {
  # 	      next if (length($w) <= 3);

  # 	      next if ($voc{$w});

  # 	      $w = lc($w);
  # 	      $w =~ s{ \A .+ ' }{}xms;

  # 	      next if ($voc{$w});

  # 	      push($w, @filtered);
  # 	    }

  # 	    if (@filtered) {
  # 	      my $text = join(' ', @filtered);
  # 	      push(@{ $text_content }, $text);
  # 	    }
  # 	  } else {
  # 	    push(@{ $text_content }, $text);
  # 	  }

  # 	} else {
  # 	  my @next = grep { $_->nodeType() == 1 } $cur->childNodes();
  # 	  push(@todo, @next);
  # 	}
  #     }
  #   }

  #   return $text_content;

  # },

  # 'slate' => sub {
  #   my ($link) = @_;

  #   my $text = '';
    
  #   my $dom;
  #   eval { $dom = XML::LibXML->load_html(
  # 	     location => $link,
  # 	     # encoding => 'iso-8859-1',
  # 	     recover => 2,
  # 	     suppress_warnings => 1,
  # 	     )
  #   };
  #   if ($@) {
  #     warn $@;
  #     return $text;
  #   }
    
  #   unless ($dom) {
  #     print STDERR "Unsuccessful parse\n";
  #     return $text;
  #   }

  #   my $text_content;


  #   my @article_nodes = $dom->findnodes('//div[@id="article_content" or @class="article_content" or @class="article_text"]');

  #   print STDERR "Number of article nodes: ", scalar(@article_nodes), "\n";

  #   foreach my $node (@article_nodes) {

  #     my $iter = XML::LibXML::Iterator->new( $node );      

  #     $iter->iterate( 
  # 	sub {
  # 	  my ($iter, $cur)=@_;


  # 	  $iter->last() if ($cur->localname() and $cur->localname() eq 'div' and $cur->hasAttribute('class') and $cur->getAttribute('class') eq 'clearer');

  # 	  $iter->nextNode() unless ($cur->nodeType() == 1);

  # 	  if ($cur->nodeType() == 1) {
  # 	    my $name = $cur->localname();
  # 	    if ($name eq 'p' or $name =~ m{ h [1-4] }xms) {
  # 	      my $text = $cur->textContent();
  # 	      $iter->nextNode() if ($text =~ m{ \A \s* \z }xms);

  # 	      if (%voc) {
  # 		my @words = split(/\s+/, $text);

  # 		my @filtered;
  # 		foreach my $w (@words) {
  # 		  next if (length($w) <= 3);
		  
  # 		  next if ($voc{$w});
		  
  # 		  $w = lc($w);
  # 		  $w =~ s{ \A .+ ' }{}xms;
		  
  # 		  next if ($voc{$w});
		  
  # 		  push($w, @filtered);
  # 		}
		
  # 		if (@filtered) {
  # 		  my $text = join(' ', @filtered);
  # 		  push(@{ $text_content }, $text);
  # 		}
  # 	      } else {
  # 		push(@{ $text_content }, $text);
  # 	      }
  # 	    }
  # 	  }
  # 	} 
  # 	);
  #   }

  #   return $text_content;

  # },

  # 'rue89' => sub {
  #   my ($link) = @_;

  #   my $text = '';
    
    
  #   my $dom;
  #   eval { $dom = XML::LibXML->load_html(
  # 	     location => $link,
  # 	     # encoding => 'iso-8859-1',
  # 	     recover => 2,
  # 	     suppress_warnings => 1,
  # 	     )
  #   };
  #   if ($@) {
  #     warn $@;
  #     return $text;
  #   }
    
  #   unless ($dom) {
  #     print STDERR "Unsuccessful parse\n";
  #     return $text;
  #   }

  #   my $text_content;

  #   my @div_nodes = $dom->findnodes('//div[@id="content"]');

  #   print STDERR "Number of div nodes: ", scalar(@div_nodes), "\n";

  #   if (@div_nodes) {

  #     my $iter = XML::LibXML::Iterator->new( $div_nodes[0] );      
    
  #     $iter->iterate( 
  # 	sub {
  # 	  my ($iter, $cur)=@_;
	    
  # 	  if ($cur->nodeType() == 1) {
  # 	    my $name = $cur->localname();

  # 	    if ($name eq 'div') {
  # 	      if ($cur->hasAttribute('id') and $cur->getAttribute('id') eq 'commentaires') {
  # 		$iter->last();
  # 	      }
  # 	    }

  # 	    if ($name eq 'p' or $name =~ m{ h [1-4] }xms) {
  # 	      my $text = $cur->textContent();
  # 	      unless ($text =~ m{ \A \s* \z }xms) {

  # 		if (%voc) {
  # 		  my @words = split(/\s+/, $text);

  # 		  my @filtered;
  # 		  foreach my $w (@words) {
  # 		    next if (length($w) <= 3);
		    
  # 		    next if ($voc{$w});
		    
  # 		    $w = lc($w);
  # 		    $w =~ s{ \A .+ ' }{}xms;
		    
  # 		    next if ($voc{$w});
		    
  # 		    push($w, @filtered);
  # 		  }
		  
  # 		  if (@filtered) {
  # 		    my $text = join(' ', @filtered);
  # 		    push(@{ $text_content }, $text);
  # 		  }
  # 		} else {
  # 		  push(@{ $text_content }, $text);
  # 		}
		
  # 	      }
  # 	    }
  # 	  }
  # 	} 
  # 	);
  #   }
  
  #   return $text_content;
  
  # },

  # 'presseurop' => sub {
  #   my ($link) = @_;

  #   my $text_content;

  #   my $dom;
  #   eval { $dom = XML::LibXML->load_html(
  # 	     location => $link,
  # 	     recover => 2,
  # 	     suppress_warnings => 1,
  # 	     )
  #   };
  #   if ($@) {
  #     warn $@;
  #     return $text_content;
  #   }
    
  #   unless ($dom) {
  #     print STDERR "Unsuccessful parse\n";
  #     return $text_content;
  #   }

  #   my @article_header = $dom->findnodes('//article/hgroup/h1');
    
  #   foreach my $node (@article_header) {
  #     my $text = $node->textContent();

  #     unless ($text =~ m{ \A \s* \z }xms) {

  # 	if (%voc) {
  # 	  my @words = split(/\s+/, $text);
	  
  # 	  my @filtered;
  # 	  foreach my $w (@words) {
  # 	    next if (length($w) <= 3);
	    
  # 	    next if ($voc{$w});
	    
  # 	    $w = lc($w);
  # 	    $w =~ s{ \A .+ ' }{}xms;
	    
  # 	    next if ($voc{$w});
	    
  # 	    push($w, @filtered);
  # 	  }
	  
  # 	  if (@filtered) {
  # 	    my $text = join(' ', @filtered);
  # 	    push(@{ $text_content }, $text);
  # 	  }
  # 	} else {
  # 	  push(@{ $text_content }, $text);
  # 	}
	
  #     }
  #   }


  #   my @article_nodes = $dom->findnodes('//article//div[@class="panel"]');

  #   if (@article_nodes) {
  #     my $iter = XML::LibXML::Iterator->new( $article_nodes[0] );      
  #     $iter->iterate( 
  # 	sub {
  # 	  my ($iter, $cur)=@_;
	  
  # 	  if ($cur->nodeType() == 1) {
  # 	    my $name = $cur->localname();
	    
  # 	    if ($name eq 'aside') {
  # 	      $iter->last();
  # 	    }

  # 	    if ($name eq 'p') {
  # 	      my $text = $cur->textContent();
  # 	      unless ($text =~ m{ \A \s* \z }xms) {

  # 		if (%voc) {
  # 		  my @words = split(/\s+/, $text);
		  
  # 		  my @filtered;
  # 		  foreach my $w (@words) {
  # 		    next if (length($w) <= 3);
		    
  # 		    next if ($voc{$w});
		    
  # 		    $w = lc($w);
  # 		    $w =~ s{ \A .+ ' }{}xms;
		    
  # 		    next if ($voc{$w});
		    
  # 		    push($w, @filtered);
  # 		  }
		  
  # 		  if (@filtered) {
  # 		    my $text = join(' ', @filtered);
  # 		    push(@{ $text_content }, $text);
  # 		  }
  # 		} else {
  # 		  push(@{ $text_content }, $text);
  # 		}
		
  # 	      }
  # 	    }
  # 	  }
  # 	} 
  # 	)
  #   };
  
  #   return $text_content;
  # },

  # 'lequipe' => sub {
  #   my ($link) = @_;

  #   my $text_content = [];

  #   my $dom;

  #   my $content = $lwp_ua->get($link)->decoded_content;

  #   eval { $dom = XML::LibXML->load_html(
  # 	     string => $content,
  # 	     recover => 2,
  # 	     suppress_warnings => 1,
  # 	     )
  #   };
  #   if ($@) {
  #     warn $@;
  #     return $text_content;
  #   }
    
  #   unless ($dom) {
  #     print STDERR "Unsuccessful parse\n";
  #     return $text_content;
  #   }

  #   my @article_nodes = $dom->findnodes('//article');

  #   foreach my $article (@article_nodes) {

  #     my $iter = XML::LibXML::Iterator->new( $article );
      
  #     while ($iter->nextNode()) {
	
  # 	my $current = $iter->current();
  # 	if ($current->nodeType() eq '1') {
  # 	  my $name = $current->localname();
  # 	  if ($name =~ m{ h[1-4] }xms) {
  # 	    my $text = $current->textContent();
  # 	    unless ($text =~ m{ \A \s* \z }xms) {
  # 	      $text =~ s{ \s+ }{ }xms;
	      
  # 	      if (%voc) {
  # 		my @words = split(/\s+/, $text);
		
  # 		my @filtered;
  # 		foreach my $w (@words) {
  # 		  next if (length($w) <= 3);
		  
  # 		  next if ($voc{$w});
		  
  # 		  $w = lc($w);
  # 		  $w =~ s{ \A .+ ' }{}xms;
		  
  # 		  next if ($voc{$w});
		  
  # 		  push($w, @filtered);
  # 		}
		
  # 		if (@filtered) {
  # 		  my $text = join(' ', @filtered);
  # 		  push(@{ $text_content }, $text);
  # 		}
  # 	      } else {
  # 		push(@{ $text_content }, $text);
  # 	      }
  # 	    }
  # 	  } elsif ($name eq 'div') {
  # 	    if ($current->hasAttribute('class')) {
  # 	      my $class = $current->getAttribute('class');
  # 	      if ($class =~ m{ paragr \b }xms) {
		
  # 		my $text = $current->textContent();
		
  # 		if ($text and $text !~ m{ \A \s* \z }xms) {
  # 		  if (%voc) {
  # 		    my @words = split(/\s+/, $text);
		    
  # 		    my @filtered;
  # 		    foreach my $w (@words) {
  # 		      next if (length($w) <= 3);
		      
  # 		      next if ($voc{$w});
		      
  # 		      $w = lc($w);
  # 		      $w =~ s{ \A .+ ' }{}xms;
		      
  # 		      next if ($voc{$w});
		      
  # 		      push($w, @filtered);
  # 		    }
		    
  # 		    if (@filtered) {
  # 		      my $text = join(' ', @filtered);
  # 		      push(@{ $text_content }, $text);
  # 		    }
  # 		  } else {
  # 		    push(@{ $text_content }, $text);
  # 		  }
		  
  # 		}
  # 	      } elsif ($current->hasAttribute('id')) {
  # 		my $id = $current->getAttribute('id');
  # 		last if ($id eq 'new_bloc_bas_breve');
  # 		last if ($id eq 'ensavoirplus');
  # 	      }
  # 	    }
  # 	  }
  # 	}
  #     }

  #     return $text_content;
  #   },

  # 'lalibre' => sub {
  #   my ($link) = @_;
    
  #   my $text_content;
    
  #   my $dom;
    
  #   my $content = $lwp_ua->get($link)->decoded_content;
    
  #   eval { $dom = XML::LibXML->load_html(
  # 	     string => $content,
  # 	     recover => 2,
  # 	     suppress_warnings => 1,
  # 	     )
  #   };
  #   if ($@) {
  #     warn $@;
  #     return $text_content;
  #   }
    
  #   unless ($dom) {
  #     print STDERR "Unsuccessful parse\n";
  #     return $text_content;
  #   }

  #   my $header = ($dom->findnodes('//h1'))[1]->textContent();
  #   $header =~ s{ \A \s+ }{}xms;
  #   $header =~ s{ \s+ \z }{}xms;
  #   $header =~ s{ \s+ }{ }xmsg;
  #   $header =~ s{ \222 }{'}xmsg;
    
  #   unless ($header =~ m{ \A \s* \z }xms) {
  #     push(@{ $text_content }, [ 'h1', $header ]);
  #   }

  #   my @hat = $dom->findnodes('//div[@id="articleHat"]');

  #   foreach my $h_node (@hat) {
  #     my $text = $h_node->textContent();
  #     unless ($text =~ m{ \A \s* \z }xms) {
  # 	$text =~ s{ \A \s+ }{}xms;
  # 	$text =~ s{ \s+ \z }{}xms;
  # 	$text =~ s{ \s+ }{ }xmsg;
  # 	$text =~ s{ \222 }{'}xmsg;

  # 	if (%voc) {
  # 	  my @words = split(/\s+/, $text);
	  
  # 	  my @filtered;
  # 	  foreach my $w (@words) {
  # 	    next if (length($w) <= 3);
	    
  # 	    next if ($voc{$w});
	    
  # 	    $w = lc($w);
  # 	    $w =~ s{ \A .+ ' }{}xms;
	    
  # 	    next if ($voc{$w});
	    
  # 	    push($w, @filtered);
  # 	  }
	  
  # 	  if (@filtered) {
  # 	    my $text = join(' ', @filtered);
  # 	    push(@{ $text_content }, $text);
  # 	  }
  # 	} else {
  # 	  push(@{ $text_content }, $text);
  # 	}
  #     }
  #   }

  #   my @article = $dom->findnodes('//div[@id="articleText"]/p');

  #   foreach my $a_node (@article) {

  #     my $text = $a_node->textContent();
  #     $text =~ s{ \A \s+ }{}xms;
  #     $text =~ s{ \s+ \z }{}xms;
  #     $text =~ s{ \s+ }{ }xmsg;
  #     $text =~ s{ \222 }{'}xmsg;

  #     if (%voc) {
  # 	my @words = split(/\s+/, $text);
	
  # 	my @filtered;
  # 	foreach my $w (@words) {
  # 	  next if (length($w) <= 3);
	  
  # 	  next if ($voc{$w});
	  
  # 	  $w = lc($w);
  # 	  $w =~ s{ \A .+ ' }{}xms;
	  
  # 	  next if ($voc{$w});
	  
  # 	  push($w, @filtered);
  # 	}
	
  # 	if (@filtered) {
  # 	  my $text = join(' ', @filtered);
  # 	  push(@{ $text_content }, $text);
  # 	}
  #     } else {
  # 	push(@{ $text_content }, $text);
  #     }
      
  #   }

  #   return $text_content;
  # },

  'liberation' => sub {
    my ($link) = @_;
    
    my $text_content;
    
    my $dom;
    
    my $content = $lwp_ua->get($link)->decoded_content;
    
    eval { $dom = XML::LibXML->load_html(
  	     string => $content,
  	     recover => 2,
  	     suppress_warnings => 1,
  	     )
    };
    if ($@) {
      warn $@;
      return $text_content;
    }
    
    unless ($dom) {
      print STDERR "Unsuccessful parse\n";
      return $text_content;
    }

    my $header_el = ($dom->findnodes('//h1[@itemprop="headline"]'))[0];
    if ($header_el) {
      my $header = $header_el->textContent();
      unless ($header =~ m{ \A \s* \z }xms) {

	if (%voc) {
	  my $filtered_text = filter_with_vocabulary($header);
	  if ($filtered_text) {
	    push(@{ $text_content }, $filtered_text);
	  }
	} else {
	  push(@{ $text_content }, $header);
	}
      }
    } else {
      print STDERR "No h1 for $link\n";
    }
    

    my @article = $dom->findnodes('//div[@itemprop="articleBody"]/p');

    foreach my $a_node (@article) {

      my $text = $a_node->textContent();
      $text =~ s{ \A \s+ }{}xms;
      $text =~ s{ \s+ \z }{}xms;
      $text =~ s{ \s+ }{ }xmsg;
      $text =~ s{ \222 }{'}xmsg;

      if (%voc) {
	my $filtered_text = filter_with_vocabulary($text);
	if ($filtered_text) {
	  push(@{ $text_content }, $filtered_text);
	}
      } else {
	push(@{ $text_content }, $text);
      }
      
    }

    return $text_content;
  },
  );

foreach my $file (@ARGV) {
  my %feeds = %{ do $file };

  my $journal = $file;
  $journal =~ s{\A .* /}{}xms;
  $journal =~ s{ _rss\.pl }{}xms;

  print STDERR $journal;

  my $count = 1;

  unless ($GETART_4_JOURNAL{$journal}) {
    warn "$journal not supported\n";
    next;
  };

  foreach my $link (keys %feeds) {


    my $text = $GETART_4_JOURNAL{$journal}->($link);

    unless ($text) {
      print STDERR "No text for link $link\n";
      next;
    }

    unless (@{ $text }) {
      print STDERR "No text for link $link\n";
      next;
    }

    my $file_name = join('-', $journal, $count);
    $file_name = join('.', $file_name, 'txt');
    $file_name = join('/', $opts{dir_name}, $file_name);
    
    if (open (my $fh, '>:encoding(utf-8)', $file_name)) {
      print $fh join("\n", @{ $text }), "\n";
      close $fh;
    } else {
      warn "Couldn't open $file_name for output: $!\n";
    }
    
    $count++;

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
