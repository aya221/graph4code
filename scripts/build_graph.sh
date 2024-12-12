#!/bin/bash
export SOURCE_DIR=$PWD
echo $SOURCE_DIR
JENA_LOC=$1
QUADS_LOC=$2
JENA_DB_LOC=$3

cd $JENA_LOC
#sudo sysctl -w vm.max_map_count=500000
#mkdir logs
cd bin
chmod +x ./tdb2.tdbloader
#export JVM_ARGS=-Xmx1T
#echo $QUADS_LOC/*.nq.bz2 
#echo $PWD
#echo $(ls /pfss/mlde/workspaces/mlde_wsp_KIServiceCenter/ec38sifi/graph4code/scripts/graph4code_quads/*.nq.bz2)

chmod +r $SOURCE_DIR/graph4code/scripts/graph4code_quads/*
#./tdb2.tdbloader --loader=parallel --loc=$JENA_DB_LOC $QUADS_LOC/*.nq.bz2 > ../logs/load_graph_v1.log 2>&1 
./tdb2.tdbloader --loader=parallel --loc=$JENA_DB_LOC $QUADS_LOC/*

