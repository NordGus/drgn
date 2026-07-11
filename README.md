# DRGN

DRGN (read as Dragon) is a personal finance control platform to take control of your finances and start achieving your
dreams and goals.

## Setting Up Your Development Environment

### System Dependencies

To work on developing DRGN you need to install the following dependencies
- [mise-en-place](https://mise.jdx.dev/getting-started.html)

### Tooling and Ruby Dependencies

Install the tooling:
```shell
mise install
```

Install MailHog dependency:
```shell
go install github.com/mailhog/MailHog@latest
```

Now you can start the MailHog server during development while using:
```shell
MailHog
```

Setup bundle to store the gems inside the current project to prevent dependency collisions with other projects:
```shell
bundle config set --local path 'vendor/bundle'
```

Install all dependencies:

```shell
bundle install
```

Prepare the database and load some text data:
```shell
bin/rails db:setup db:fixtures:load
```

---

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
