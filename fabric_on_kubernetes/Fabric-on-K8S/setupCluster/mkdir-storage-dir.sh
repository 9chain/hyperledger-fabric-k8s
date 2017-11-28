#!/usr/bin/env bash

DATAPATH=/opt/share/data

mkdir -p $DATAPATH/{orderer,peer}
mkdir -p $DATAPATH/orderer/orgorderer1/orderer0
mkdir -p $DATAPATH/peer/org{1,2}/{ca,peer0,peer1}
mkdir -p $DATAPATH/peer/org{1,2}/peer{0,1}/{couchdb,peerdata}

