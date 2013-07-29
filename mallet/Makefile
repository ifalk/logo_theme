### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/11 14:05:35 falk Exp $
## Keywords: 
## X-URL: 

LOGO_HOME=/home/falk/Logoscope
SCRIPT_DIR=bin
MALLET_HOME=/home/falk/mallet-2.0.7
MALLET_CMD=${MALLET_HOME}/bin/mallet

FEED_DIR=../onlineldavb
FEED_JOURNALS=lalibre lejdd lemonde lequipe liberation presseurop rue89 slate
FEED_FILES=$(addprefix $(FEED_DIR)/,$(addsuffix _rss.pl, $(FEED_JOURNALS)))


articles: ${SCRIPT_DIR}/make_mallet_input_texts.pl ${FEED_FILES} 
	mkdir articles ; \
rm articles/* ; \
perl $< --dir_name=articles ${FEED_FILES}

SL_DIR=${LOGO_HOME}/VC/theme/stoplists
stoplist: ${SCRIPT_DIR}/make_stoplist.pl ${SL_DIR}/snowball.stoplist ${SL_DIR}/okki.stoplist ${SL_DIR}/gma.stoplist ${SL_DIR}/textalyser.stoplist ${SL_DIR}/context.stoplist ${SL_DIR}/mallet.extra-stoplist.fr ${SL_DIR}/mallet.stoplist
	perl $< ${SL_DIR}/snowball.stoplist ${SL_DIR}/okki.stoplist ${SL_DIR}/gma.stoplist ${SL_DIR}/textalyser.stoplist ${SL_DIR}/context.stoplist ${SL_DIR}/mallet.extra-stoplist.fr ${SL_DIR}/mallet.stoplist > $@

lemonde.mallet: lemonde_articles stoplist
	${MALLET_CMD} import-dir --input lemonde_articles --output $@ --keep-sequence --stoplist-file stoplist --token-regex "[\pL\p{Mn}\p{Nd}\p{Pc}]+"


lemonde_20T-state.gz lemonde_20T-keys.txt lemonde_20T-composition.txt: lemonde.mallet
	${MALLET_CMD} train-topics  --input lemonde.mallet --num-topics 20 --optimize-interval 20 --output-state lemonde_20T-state.gz --output-topic-keys lemonde_20T-keys.txt --output-doc-topics lemonde_20T-compostion.txt --num-top-words 100 --word-topic-counts-file lemonde_20T-word-topic-counts.txt --xml-topic-report lemonde_20T-xml-topic-report.xml --xml-topic-phrase-report lemonde_20T-xml-topic-phrase-report.xml

lemonde_10T-state.gz lemonde_10T-keys.txt lemonde_10T-composition.txt: lemonde.mallet
	${MALLET_CMD} train-topics  --input lemonde.mallet --num-topics 10 --optimize-interval 10 --output-state lemonde_10T-state.gz --output-topic-keys lemonde_10T-keys.txt --output-doc-topics lemonde_10T-compostion.txt --num-top-words 100 --word-topic-counts-file lemonde_10T-word-topic-counts.txt --xml-topic-report lemonde_10T-xml-topic-report.xml --xml-topic-phrase-report lemonde_10T-xml-topic-phrase-report.xml



### Makefile ends here
