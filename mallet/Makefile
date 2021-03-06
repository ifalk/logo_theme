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
# FEED_JOURNALS=lalibre lejdd lemonde lequipe liberation presseurop rue89 slate
FEED_JOURNALS=slate
FEED_FILES=$(addprefix $(FEED_DIR)/,$(addsuffix _rss.pl, $(FEED_JOURNALS)))

articles: ${SCRIPT_DIR}/make_mallet_input_texts.pl ${FEED_FILES} vocabulary.pl 
	mkdir articles ; \
rm articles/* ; \
perl $< --dir_name=articles --voc=vocabulary.pl ${FEED_FILES}

articles.mallet: articles stoplist
	${MALLET_CMD} import-dir --input articles --output $@ --keep-sequence --stoplist-file stoplist --token-regex "[\pL\p{Mn}\p{Nd}\p{Pc}]+"

SL_DIR=${LOGO_HOME}/VC/theme/mallet/stoplists
stoplist: ${SCRIPT_DIR}/make_stoplist.pl ${SL_DIR}/snowball.stoplist ${SL_DIR}/okki.stoplist ${SL_DIR}/gma.stoplist ${SL_DIR}/textalyser.stoplist ${SL_DIR}/context.stoplist ${SL_DIR}/mallet.extra-stoplist.fr ${SL_DIR}/mallet.stoplist
	perl $< ${SL_DIR}/snowball.stoplist ${SL_DIR}/okki.stoplist ${SL_DIR}/gma.stoplist ${SL_DIR}/textalyser.stoplist ${SL_DIR}/context.stoplist ${SL_DIR}/mallet.extra-stoplist.fr ${SL_DIR}/mallet.stoplist > $@

WS_FREQ_LIST=${LOGO_HOME}/VC/theme/top10000fr.txt

vocabulary.pl: ${SCRIPT_DIR}/make_vocabulary.pl ${WS_FREQ_LIST} stoplist
	perl $< --sl=stoplist --fl=${WS_FREQ_LIST} > $@




100T-hyper_opt-state.gz 100T-hyper_opt-keys.txt 100T-hyper_opt-composition.txt: articles.mallet
	${MALLET_CMD} train-topics  --input articles.mallet --num-topics 100  --optimize-interval 10 --output-state 100T-hyper_opt-state.gz --output-topic-keys 100T-hyper_opt-keys.txt --output-doc-topics 100T-hyper_opt-compostion.txt --num-top-words 20 --word-topic-counts-file 100T-hyper_opt-word-topic-counts.txt --xml-topic-report 100T-hyper_opt-xml-topic-report.xml --xml-topic-phrase-report 100T-hyper_opt-xml-topic-phrase-report.xml

10T-hyper_opt-state.gz 10T-hyper_opt-keys.txt 10T-hyper_opt-composition.txt 10T-hyper_opt-inferencer.mallet: articles.mallet
	${MALLET_CMD} train-topics  --input articles.mallet --num-topics 10  --optimize-interval 10 --output-state 10T-hyper_opt-state.gz --output-topic-keys 10T-hyper_opt-keys.txt --output-doc-topics 10T-hyper_opt-compostion.txt --num-top-words 100 --word-topic-counts-file 10T-hyper_opt-word-topic-counts.txt --xml-topic-report 10T-hyper_opt-xml-topic-report.xml --xml-topic-phrase-report 10T-hyper_opt-xml-topic-phrase-report.xml --inferencer-filename 10T-hyper_opt-inferencer.mallet


100T-state.gz 100T-keys.txt 100T-composition.txt: articles.mallet
	${MALLET_CMD} train-topics  --input articles.mallet --num-topics 100  --use-symmetric-alpha true  --alpha 10 --output-state 100T-state.gz --output-topic-keys 100T-keys.txt --output-doc-topics 100T-compostion.txt --num-top-words 20 --word-topic-counts-file 100T-word-topic-counts.txt --xml-topic-report 100T-xml-topic-report.xml --xml-topic-phrase-report 100T-xml-topic-phrase-report.xml

10T-state.gz 10T-keys.txt 10T-composition.txt: articles.mallet
	${MALLET_CMD} train-topics  --input articles.mallet --num-topics 10  --use-symmetric-alpha true  --alpha 10 --output-state 10T-state.gz --output-topic-keys 10T-keys.txt --output-doc-topics 10T-compostion.txt --num-top-words 100 --word-topic-counts-file 10T-word-topic-counts.txt --xml-topic-report 10T-xml-topic-report.xml --xml-topic-phrase-report 10T-xml-topic-phrase-report.xml




lemonde.mallet: lemonde_articles stoplist
	${MALLET_CMD} import-dir --input lemonde_articles --output $@ --keep-sequence --stoplist-file stoplist --token-regex "[\pL\p{Mn}\p{Nd}\p{Pc}]+"


lemonde_20T-state.gz lemonde_20T-keys.txt lemonde_20T-composition.txt: lemonde.mallet
	${MALLET_CMD} train-topics  --input lemonde.mallet --num-topics 20 --optimize-interval 20 --output-state lemonde_20T-state.gz --output-topic-keys lemonde_20T-keys.txt --output-doc-topics lemonde_20T-compostion.txt --num-top-words 100 --word-topic-counts-file lemonde_20T-word-topic-counts.txt --xml-topic-report lemonde_20T-xml-topic-report.xml --xml-topic-phrase-report lemonde_20T-xml-topic-phrase-report.xml

lemonde_10T-state.gz lemonde_10T-keys.txt lemonde_10T-composition.txt: lemonde.mallet
	${MALLET_CMD} train-topics  --input lemonde.mallet --num-topics 10 --optimize-interval 10 --output-state lemonde_10T-state.gz --output-topic-keys lemonde_10T-keys.txt --output-doc-topics lemonde_10T-compostion.txt --num-top-words 100 --word-topic-counts-file lemonde_10T-word-topic-counts.txt --xml-topic-report lemonde_10T-xml-topic-report.xml --xml-topic-phrase-report lemonde_10T-xml-topic-phrase-report.xml



### Makefile ends here
