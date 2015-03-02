Slack-Notification Step
=======================

Posts a message to an Slack channel.

[![wercker status](https://img.shields.io/wercker/ci/54f036adb05d633123007959.svg?style=flat-square)][wercker]
[wercker]: https://app.wercker.com/#applications/54f036adb05d633123007959

Preview
-------

<img width="265" src="https://raw.githubusercontent.com/linyows/wercker-step-slack_notification/master/preview.png">

Options
-------

- token (required)
- subdomain (optional, default: nil)
- channel (optional, default: #general)
- endpoint (optional, default: https://slack.com/api/chat.postMessage)
- username (optional, default: Wercker)
- icon_emoji (optional, default: )
- icon_url (optional, default: )
- title (optional, default: owner/project)
- title_link (optional, default: project url)
- passed-text (optional, default: )
- passed-color (optional, default: )
- failed-text (optional, default: )
- failed-color (optional, default: )
- on (optional, default: always)

Example
-------

### If use API:

```yaml
build:
    after-steps:
        - linyows/slack_notification:
            token: $SLACK_TOKEN
            channel: C038M2LE1
```

channel_id: https://api.slack.com/methods/channels.list/test

### If use incomming webhook:

```yaml
build:
    after-steps:
        - linyows/slack_notification:
            token: $SLACK_TOKEN
            channel: #general
            subdomain: foo
```

License
-------

The MIT License (MIT)
