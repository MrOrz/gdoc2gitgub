# gdoc2gitgub

Puts revision history of a specified google doc into a specified [github repository like this](https://github.com/MrOrz/president2016-history).

Works like [gitdriver](https://github.com/larsks/gitdriver), but is designed to run periodically.
It also pushes to specified github repository.


## Install

### Gem dependencies
```
$ bundle
```

### Google drive API credentials

Go to [Google API console](https://console.developers.google.com).
Create a project, go to `Credentails` page and create a new Client ID with
its type set to "Installed application" and "Other". After that, click "Download JSON" button to retrieve `client_secret_<xxxxx>.json`.

Rename the JSON file to `client_secrets.json` and move it under this project's directory.

Then we need to authenticate so that `gdoc2github` can access
the revision list of files we own.

```
$ bundle exec rake init #: Starts a browser and does authentication.
```

After this, a new JSON file, `initial_tokens.json` will be created.
Even though gdoc2github can store and refresh access tokens by itself,
initial token file is still crucial because it provides the very first credential data when the credential storage is not popualated yet.


### Redis server

We use Redis to save access tokens among executions, thus a running Redis server is required.

By default it reads Redis server URL from the environment variable `REDIS_URL`.
If no such environment variable is defined, `redis://127.0.0.1:6379` is used.

### Github credentials

gdoc2github pushes to github using your [personal access tokens in Github](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).
The token is fed to gdoc2github via environment variable `GF_REF`.
Also, `GF_REF` refines the github URL of the repository.

Sample github credentials:

```
export GH_REF=github.com/mrorz/president2016-history
export GH_TOKEN=aasdfasdf_YOUR_GITHUB_TOKEN_asdsdad
```

## Run

```
$ bundle exec rake
```

## Deploy

First, use `heroku create` to create a Heroku project.
With the remote origin `heroku` exists, use the command below to start deploying to Heroku:

```
$ bundle exec rake deploy
```

Under the hood this command would commit `initial_tokens.json` and `client_secrets.json` into a new, temporary branch and push the branch to Heroku.
