#!/bin/bash

function error() {
    echo $1
}
function info() {
    echo -ne "\\033[1;34m$1\\033[0;39m"
}
function success() {
    echo -e "\\033[1;32m ok\\033[0;39m"
}
function failure() {
    echo -e "  \\033[1;31m ng\\033[0;39m"
}
function unset_variables() {
    unset WERCKER_SLACK_NOTIFICATION_PASSED_TEXT
    unset WERCKER_SLACK_NOTIFICATION_FAILED_TEXT
    unset WERCKER_SLACK_NOTIFICATION_PASSED_COLOR
    unset WERCKER_SLACK_NOTIFICATION_FAILED_COLOR
    unset COLOR
}

export WERCKER_SLACK_NOTIFICATION_CHANNEL="C03RQJ7HT"
export WERCKER_SLACK_NOTIFICATION_TOKEN=$SLACK_TOKEN
export WERCKER_STEP_TEMP="/tmp"

export WERCKER_BUILD_URL="https://app.wercker.com/#build/54f036b2b05d633123007967"
export WERCKER_DEPLOY_URL="https://app.wercker.com/#build/54f036b2b05d633123007967"
export WERCKER_GIT_BRANCH="master"
export WERCKER_APPLICATION_OWNER_NAME="linyows"
export WERCKER_APPLICATION_NAME="wercker-step-slack_notification"
export WERCKER_STARTED_BY="linyows"
export WERCKER_DEPLOYTARGET_NAME="www001.foo.com"
export WERCKER_APPLICATION_LINK="https://github.com/linyows/wercker-step-slack_notification"
unset WERCKER_SLACK_NOTIFICATION_FAILED_TEXT
unset WERCKER_SLACK_NOTIFICATION_PASSED_TEXT

ERR=0

info 'A build successful:'
export WERCKER_RESULT="passed"
source ./run.sh

if [ $? -eq 0 ]; then
    success
else
    failure
    ERR=1
fi
unset_variables
sleep 1

info 'A build failed:'
export WERCKER_RESULT="failed"
source ./run.sh

if [ $? -eq 0 ]; then
    success
else
    failure
    ERR=1
fi
unset_variables
sleep 1

export DEPLOY="true"

info 'A deploy successful:'
export WERCKER_RESULT="passed"
source ./run.sh

if [ $? -eq 0 ]; then
    success
else
    failure
    ERR=1
fi
sleep 1
unset_variables

info 'A deploy failed:'
WERCKER_RESULT="failed"
source ./run.sh

if [ $? -eq 0 ]; then
    success
else
    failure
    ERR=1
fi

if [ $ERR -eq 1 ]; then
    exit 1
fi
