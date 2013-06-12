### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/11 14:05:35 falk Exp $
## Keywords: 
## X-URL: 

LOGO_HOME=/home/falk/Logoscope
SCRIPT_DIR=${LOGO_HOME}/VC/theme/bin
GENRE_DIR=${LOGO_HOME}/VC/genre
MALLET_HOME=/home/falk/mallet-2.0.7
MALLET_CMD=${MALLET_HOME}/bin/mallet
MALLET_STOPLIST=${MALLET_HOME}/stoplists/fr.txt

lemonde_articles: ${SCRIPT_DIR}/make_mallet_input_texts.pl ${GENRE_DIR}/lemonde_articles.html
	mkdir lemonde_articles ; \
rm lemonde_articles/* ; \
perl $< --dir_name=lemonde_articles ${GENRE_DIR}/lemonde_articles.html

lemonde.mallet: lemonde_articles ${MALLET_STOPLIST} mallet.extra-stoplist.fr
	${MALLET_CMD} import-dir --input lemonde_articles --output $@ --keep-sequence --stoplist-file ${MALLET_STOPLIST} --extra-stopwords mallet.extra-stoplist.fr --token-regex "[\pL\p{Mn}\p{Nd}\p{Pc}]+"


lemonde-state.gz lemonde_keys.txt lemonde_composition.txt: lemonde.mallet
	${MALLET_CMD} train-topics  --input lemonde.mallet --num-topics 20 --optimize-interval 20 --output-state lemonde-state.gz --output-topic-keys lemonde_keys.txt --output-doc-topics lemonde_compostion.txt

### Makefile ends here
