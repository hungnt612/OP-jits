#!/bin/bash
function echo_noti {
    echo "$(tput setaf 2)$1"
} 

function echo_job_detail {
    echo "$(tput setaf 1)$(tput setab 7)$1$(tput sgr 0)"
} 

function echo_error {
    echo "$(tput setaf 1)$1"
} 

function echo_multi_line {
    echo "hihi"
}