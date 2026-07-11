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

Configure MailHog for development by running:
```shell
bin/rails mailhog:configure
```

Now you can start MailHog by running:
```shell
bin/rails mailhog:serve
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

### Setup development environment

Generate a new MailHog password:
```shell
MailHog bcrypt password
```

Copy the output of the above command and paste it in a new file `.mailhog/auth-file` in the follwing way
```shell
developer:<bycrypt-password-output-from-above-command>
```

This will allow you to start MailHog with the correct credentials and by running the script:
```shell
bin/rails mailhog
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
