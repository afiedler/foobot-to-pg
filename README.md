# Foobot to Postgres
Extracts data from the Foobot API and stores it in a Postgres database. Ideal if you want to pull
your data down and store it on Heroku.

## Setting up on Herkou

### The no-console way

Click the deploy to Herkou button below:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Then, you'll need to create a Heroku account if you don't already have one. Next, Heroku will
deploy a copy of this repo for you. When that is finished, click on "My Apps" in the Heroku web
interface. Find the app you just created and click on it.

Next, choose "Settings", and click "Reveal Config Variables".

You'll need to set a few config variables for this to work. Set these ones:
```
FOOBOT_NAME=<the name of your Foobot, case-sensitive>
USERNAME=<the email address you set up your Foobot>
PASSWORD=<your Foobot password>
```

Next, click "Resources" and add the "Heroku Scheduler" addon. After you add it, click on it and add
a new scheduled task. In the field for task to run, enter `rake fetch` and schedule it for every 10
minutes.

You now should have your Foobot data being pulled into your DB!

To access your data, go to Settings and select "Reveal Config Variables" again. Copy the
`DATABASE_URL` into a Postgres client like [Postico](https://eggerapps.at/postico/) to see your
data.

### The console way
Do this in a console. Requires the Heroku Toolbelt and Git:
```
git clone https://github.com/afiedler/foobot-to-pg
cd foobot-to-pg
heroku create
git push heroku master
heroku config:set USERNAME=<username>
heroku config:set PASSWORD=<password>
heroku config:set FOOBOT_NAME=<name>
```

You'll need to add and configure the scheduler as described above.

## Questions or want to contribute?
Email andy@andyfiedler.com or create a PR.

