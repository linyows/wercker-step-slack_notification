#!/bin/bash

POST_MESSAGE_API_ENDPOINT="https://slack.com/api/chat.postMessage"
USERNAME="username=wercker"
AVATAR="icon_url=https://raw.githubusercontent.com/linyows/wercker-step-slack_notification/master/wercker-icon.png"
CHANNEL="channel=general"
ENDPOINT=""

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_TOKEN" ]; then
  error 'Please specify token property'
  exit 1
fi

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_CHANNEL" ]; then
  error 'Please specify a channel'
  exit 1
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_SUBDOMAIN" ]; then
  ENDPOINT="https://$WERCKER_SLACK_NOTIFICATION_SUBDOMAIN.slack.com/services/hooks/incoming-webhook"
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_ENDPOINT" ]; then
  ENDPOINT=$WERCKER_SLACK_NOTIFICATION_ENDPOINT
fi

if [ ! -n "$ENDPOINT" ]; then
  ENDPOINT=$POST_MESSAGE_API_ENDPOINT
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_USERNAME" ]; then
  USERNAME="username=$WERCKER_SLACK_NOTIFICATION_USERNAME"
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_ICON_EMOJI" ]; then
  AVATAR="icon_emoji=$WERCKER_SLACK_NOTIFICATION_ICON_EMOJI"
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_ICON_URL" ]; then
  AVATAR="icon_url=$WERCKER_SLACK_NOTIFICATION_ICON_URL"
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_CHANNEL" ]; then
  CHANNEL="channel=$WERCKER_SLACK_NOTIFICATION_CHANNEL"
fi

ENDPOINT="$ENDPOINT?token=$WERCKER_SLACK_NOTIFICATION_TOKEN"

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_FAILED_TEXT" ]; then
  if [ ! -n "$DEPLOY" ]; then
    export WERCKER_SLACK_NOTIFICATION_FAILED_TEXT="<$WERCKER_BUILD_URL|Build> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY failed. :package:"
  else
    export WERCKER_SLACK_NOTIFICATION_FAILED_TEXT="<$WERCKER_DEPLOY_URL|Deploy> of $WERCKER_GIT_BRANCH to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY failed. :rocket:"
  fi
fi

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_PASSED_TEXT" ]; then
  if [ ! -n "$DEPLOY" ]; then
    export WERCKER_SLACK_NOTIFICATION_PASSED_TEXT="<$WERCKER_BUILD_URL|Build> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY passed. :package:"
  else
    export WERCKER_SLACK_NOTIFICATION_PASSED_TEXT="<$WERCKER_DEPLOY_URL|Deploy> of $WERCKER_GIT_BRANCH to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY passed. :rocket:"
  fi
fi

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_TITLE" ]; then
  WERCKER_SLACK_NOTIFICATION_TITLE="$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY"
fi

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_TITLE_LINK" ]; then
  WERCKER_SLACK_NOTIFICATION_TITLE_LINK="$WERCKER_APPLICATION_URL"
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_PASSED_COLOR" ]; then
  COLOR=$WERCKER_SLACK_NOTIFICATION_PASSED_COLOR
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_FAILED_COLOR" ]; then
  COLOR=$WERCKER_SLACK_NOTIFICATION_FAILED_COLOR
fi

if [ "$WERCKER_RESULT" = "passed" ]; then
  export WERCKER_SLACK_NOTIFICATION_TEXT="$WERCKER_SLACK_NOTIFICATION_PASSED_TEXT"
  if [ ! -n "$COLOR" ]; then
    COLOR="good"
  fi
else
  export WERCKER_SLACK_NOTIFICATION_TEXT="$WERCKER_SLACK_NOTIFICATION_FAILED_TEXT"
  if [ ! -n "$COLOR" ]; then
    COLOR="danger"
  fi
fi

if [ "$WERCKER_SLACK_NOTIFICATION_ON" = "failed" ]; then
  if [ "$WERCKER_RESULT" = "passed" ]; then
    echo "Skipping.."
    return 0
  fi
fi

OUTPUT="$WERCKER_STEP_TEMP/slack_notification_result.txt"
ATTACHEMENTS="attachments=[{\"color\":\"$COLOR\",\"title\":\"$WERCKER_SLACK_NOTIFICATION_TITLE\",\"title_link\":\"$WERCKER_SLACK_NOTIFICATION_TITLE_LINK\",\"text\":\"$WERCKER_SLACK_NOTIFICATION_TEXT\",\"fallback\":\"$WERCKER_SLACK_NOTIFICATION_TEXT\"}]"

if [ -n "$DEBUG" ]; then
    echo $CHANNEL
    echo $AVATAR
    echo $USERNAME
    echo $ATTACHEMENTS
fi

RESULT=`curl -s \
    -F $CHANNEL \
    -F $AVATAR \
    -F "text=" \
    -F $USERNAME \
    -F "$ATTACHEMENTS" \
    "$ENDPOINT" --output $OUTPUT -w "%{http_code}"`

if [ "$RESULT" != "200" ]; then
    error "http-status is $RESULT"
    test -f $OUTPUT && cat $OUTPUT
    exit 1
fi

if cat $OUTPUT | grep '"ok":false' > /dev/null; then
    error 'ok is false'
    test -f $OUTPUT && cat $OUTPUT
    exit 1
fi
