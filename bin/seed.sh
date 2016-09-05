#!/bin/bash
# 
# Seeds the RDF store with pension yearbook data
# 

set -e

cd bin

# Create SPARQLab database
./stardog-admin db create -n sparqlab

# Load data
./stardog data add sparqlab /data/duchodci-v-cr-krajich-okresech.trig \
                            /data/rocenka-vocabulary.trig \
                            /data/duchodci-v-cr-krajich-okresech-metadata.trig \
                            /data/pomocne-ciselniky.trig
./stardog data add sparqlab -g http://purl.org/linked-data/cube /data/cube.ttl

# Transform data
./stardog query sparqlab /setup/sparql/fix_https_in_pension_kinds_1.ru
./stardog query sparqlab /setup/sparql/fix_https_in_pension_kinds_2.ru
./stardog query sparqlab /setup/sparql/rewrite_genders.ru
