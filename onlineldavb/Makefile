### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/07/25 14:02:28 falk Exp $
## Keywords: 
## X-URL: 

### how many feeds do we get when crawling www.lemonde.fr/rss ?

SCRIPT_DIR=bin

LEMONDE_FEEDS=http://www.lemonde.fr/rss/index.html
lemonde_rss.pl: ${SCRIPT_DIR}/get_feeds.pl 
	perl $< --journal=lemonde ${LEMONDE_FEEDS} > $@

LEJDD_FEEDS=http://www.lejdd.fr/rss/index.html
lejdd_rss.pl: ${SCRIPT_DIR}/get_feeds.pl 
	perl $< --journal=lejdd ${LEJDD_FEEDS} > $@

SLATE_FEEDS=http://www.slate.fr
slate_rss.pl: ${SCRIPT_DIR}/get_feeds.pl 
	perl $< --journal=slate ${SLATE_FEEDS} > $@

RUE89_FEEDS=http://www.rue89.com/les-flux-rss-de-rue89
rue89_rss.pl: ${SCRIPT_DIR}/get_feeds.pl 
	perl $< --journal=rue89 ${RUE89_FEEDS} > $@

PRESSEUROP_FEEDS=http://www.presseurop.eu/fr/rss
presseurop_rss.pl: ${SCRIPT_DIR}/get_feeds.pl 
	perl $< --journal=presseurop ${PRESSEUROP_FEEDS} > $@

LEQUIPE_FEEDS=http://www.lequipe.fr/rss/
lequipe_rss.pl: ${SCRIPT_DIR}/get_feeds.pl
	perl $< --journal=lequipe ${LEQUIPE_FEEDS} > $@

LALIBRE_FEEDS=http://www.lalibre.be/dossiers/_promo/RSS/
lalibre_rss.pl: ${SCRIPT_DIR}/get_feeds.pl
	perl $< --journal=lalibre ${LALIBRE_FEEDS} > $@

LIBE_FEEDS=http://www.liberation.fr/rss
liberation_rss.pl: ${SCRIPT_DIR}/get_feeds.pl
	perl $< --journal=liberation ${LIBE_FEEDS} > $@

DNA_FEEDS=http://www.dna.fr/rss
# Get categories directly from rss xml file
dna_rss.pl: ${SCRIPT_DIR}/get_articles_from_feed.pl 
	perl $< ${DNA_FEEDS} > $@

LMD=http://www.monde-diplomatique.fr/rss/
lmd_rss.pl: ${SCRIPT_DIR}/get_articles_from_feed.pl 
	perl $< ${LMD} > $@

### Makefile ends here
