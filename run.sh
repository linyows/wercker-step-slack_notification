#!/bin/bash

POST_MESSAGE_API_ENDPOINT="https://slack.com/api/chat.postMessage"
USERNAME="\"username\":\"Wercker\","
AVATAR="\"icon_url\":\"https://raw.githubusercontent.com/linyows/wercker-step-slack_notification/master/wercker-icon.png\","
CHANNEL="\"channel\": \"#general\","

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
  USERNAME="\"username\":\"$WERCKER_SLACK_NOTIFICATION_USERNAME\","
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_ICON_EMOJI" ]; then
  AVATAR="\"icon_emoji\":\"$WERCKER_SLACK_NOTIFICATION_ICON_EMOJI\","
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_ICON_URL" ]; then
  AVATAR="\"icon_url\":\"$WERCKER_SLACK_NOTIFICATION_ICON_URL\","
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_CHANNEL" ]; then
  CHANNEL="\"channel\": \"$WERCKER_SLACK_NOTIFICATION_CHANNEL\","
fi

ENDPOINT=$ENDPOINT?token=$WERCKER_SLACK_NOTIFICATION_TOKEN

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_FAILED_TEXT" ]; then
  if [ ! -n "$DEPLOY" ]; then
    export WERCKER_SLACK_NOTIFICATION_FAILED_TEXT=":package: <$WERCKER_BUILD_URL|build> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY failed."
  else
    export WERCKER_SLACK_NOTIFICATION_FAILED_TEXT=":rocket: <$WERCKER_DEPLOY_URL|deploy> of $WERCKER_GIT_BRANCH to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY failed."
  fi
fi

if [ ! -n "$WERCKER_SLACK_NOTIFICATION_PASSED_TEXT" ]; then
  if [ ! -n "$DEPLOY" ]; then
    export WERCKER_SLACK_NOTIFICATION_PASSED_TEXT=":package: <$WERCKER_BUILD_URL|build> of $WERCKER_GIT_BRANCH by $WERCKER_STARTED_BY passed."
  else
    export WERCKER_SLACK_NOTIFICATION_PASSED_TEXT=":rocket: <$WERCKER_DEPLOY_URL|deploy of $WERCKER_GIT_BRANCH> to $WERCKER_DEPLOYTARGET_NAME by $WERCKER_STARTED_BY passed."
  fi
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_TITLE" ]; then
  WERCKER_SLACK_NOTIFICATION_TITLE="$WERCKER_APPLICATION_OWNER_NAME/$WERCKER_APPLICATION_NAME"
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_TITLE_LINK" ]; then
  WERCKER_SLACK_NOTIFICATION_TITLE_URL="$WERCKER_APPLICATION_LINK"
fi

TITLE=$WERCKER_APPLICATION_NAME

if [ -n "$WERCKER_SLACK_NOTIFICATION_PASSED_COLOR" ]; then
  COLOR=$WERCKER_SLACK_NOTIFICATION_PASSED_COLOR
fi

if [ -n "$WERCKER_SLACK_NOTIFICATION_FAILED_COLOR" ]; then
  COLOR=$WERCKER_SLACK_NOTIFICATION_FAILED_COLOR
fi

if [ "$WERCKER_RESULT" = "passed" ]; then
  export WERCKER_SLACK_NOTIFICATION_MESSAGE="$WERCKER_SLACK_NOTIFICATION_PASSED_MESSAGE"
  if [ ! -n "$COLOR" ]; then
    COLOR="good"
  fi
else
  export WERCKER_SLACK_NOTIFICATION_MESSAGE="$WERCKER_SLACK_NOTIFICATION_FAILED_MESSAGE"
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

json="{$CHANNEL $USERNAME $AVATAR \"text\": \"\", \"attachments\": \"[{\"color\": \"$COLOR\", \"title\": \"$WERCKER_SLACK_NOTIFICATION_TITLE\", \"title_link\": \"$WERCKER_SLACK_NOTIFICATION_TITLE_LINK\", \"text\": \"$WERCKER_SLACK_NOTIFICATION_MESSAGE\", \"fallback\": \"$WERCKER_SLACK_NOTIFICATION_MESSAGE\"}]\", \"link_names\": 1}"

RESULT=`curl -s -d "payload=$json" "$ENDPOINT" --output $WERCKER_STEP_TEMP/result.txt -w "%{http_code}"`

if [ "$RESULT" = "500" ]; then
  if grep -Fqx "No token" $WERCKER_STEP_TEMP/result.txt; then
    fatal "No token is specified."
  fi

  if grep -Fqx "No hooks" $WERCKER_STEP_TEMP/result.txt; then
    fatal "No hook can be found for specified subdomain/token"
  fi

  if grep -Fqx "Invalid channel specified" $WERCKER_STEP_TEMP/result.txt; then
    fatal "Could not find specified channel for subdomain/token."
  fi

  if grep -Fqx "No text specified" $WERCKER_STEP_TEMP/result.txt; then
    fatal "No text specified."
  fi
fi

if [ "$RESULT" = "404" ]; then
  error "Subdomain or token not found."
  exit 1
fi
