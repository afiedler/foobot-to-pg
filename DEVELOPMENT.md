## Setting up a local development environment

```
git clone https://github.com/afiedler/foobot-to-pg
cd foobot-to-pg
bundle install
```

You'll need to configure some environment variables. Copy the template to start:

```
cp .env.example .env
```

Next, create a local Postgres database called `foobot_dev`. You'll need to modify the `DATABASE_URL`
in `.env` if you use a different name, or if you need a username and password to connect locally.

```
createdb foobot_dev
```

