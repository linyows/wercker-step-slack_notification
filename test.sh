#!/bin/bash

export DEPLOY="true"

export WERCKER_SLACK_NOTIFICATION_CHANNEL="C03QYQ3H7"
#export WERCKER_SLACK_NOTIFICATION_TOKEN=""

export WERCKER_BUILD_URL="https://app.wercker.com/#build/54f036b2b05d633123007967"
export WERCKER_DEPLOY_URL="https://app.wercker.com/#build/54f036b2b05d633123007967"
export WERCKER_GIT_BRANCH="master"
export WERCKER_APPLICATION_OWNER_NAME="linyows"
export WERCKER_APPLICATION_NAME="wercker-step-slack_notification"
export WERCKER_STARTED_BY="linyows"
export WERCKER_DEPLOYTARGET_NAME="www001.foo.com"
export WERCKER_APPLICATION_LINK="https://github.com/linyows/wercker-step-slack_notification"

source ./run.sh
