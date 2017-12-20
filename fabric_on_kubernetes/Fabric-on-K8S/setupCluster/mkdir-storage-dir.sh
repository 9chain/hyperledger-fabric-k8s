#!/usr/bin/env bash

DATAPATH=/opt/data

rm -rf   $DATAPATH/{orderer,peer}
mkdir -p $DATAPATH/{orderer,peer}
mkdir -p $DATAPATH/orderer/orgorderer1/orderer0
mkdir -p $DATAPATH/peer/org{1,2}/ca
mkdir -p $DATAPATH/peer/org{1,2}/peer{0,1}/{couchdb,peerdata}

