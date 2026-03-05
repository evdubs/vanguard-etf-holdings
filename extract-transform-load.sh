#!/usr/bin/env bash

today=$(date "+%F")
dir=$(dirname "$0")
current_year=$(date "+%Y")

racket -y ${dir}/extract.rkt
racket -y ${dir}/transform-load.rkt -p "$1"

7zr a /var/local/vanguard/etf-holdings/${current_year}.7z /var/local/vanguard/etf-holdings/${today}
