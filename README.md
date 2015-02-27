Slack-Notification Step
=======================

Posts a message to an Slack channel.

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

```yaml
build:
    after-steps:
        - linyows/slack_notification:
            token: $SLACK_TOKEN
            channel: C038M2LE1
```

License
-------

The MIT License (MIT)
