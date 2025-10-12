#!/bin/bash
nvm use lts/fermium
cd $1
/home/ns/.nvm/versions/node/v14.14.0/bin/node $1/indexFromRtmp.js
