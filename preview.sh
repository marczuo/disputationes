#!/bin/bash
./site build
./site server &
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "http://localhost:8000"
