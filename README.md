# Salesforce ReactJS SPA Starter

A template project to create ReactJS-based single page application on Salesforce, with automatic build script (Gulp.js)

## Setup

Make sure you are installing Node.js 0.10.x or later.

```
$ node --version
```

Then execute following commands in project directory root:

```
$ npm install
$ bower install
```

## Build Files

Run the `gulp` command to build runnable codes from source code :

```
$ gulp
```

for automatic building you can specify `watch` task option for gulp

```
$ gulp watch
```

## Preview

Start web server by following command :

```
$ gulp dev
```

Then access to `http://localhost:8000`.

The command watches source code update and builds automatically.


## Test

Run unit tests

```
$ gulp test
```

For automatic test execution: (update watch)

```
$ gulp test:watch
```


## Deploy (Salesforce)

With username and password (may include security token) as environment variables to connect to Salesforce,
execute `gulp deploy` command :

```
$ SF_USERNAME=yourname@example.org SF_PASSWORD=password gulp deploy
```
or prepare `.env` file in `KEY=VALUE` format:

```
SF_USERNAME=yourname@example.org
SF_PASSWORD=password
```

Then execute `gulp deploy` using `foreman` :

```
$ nf run gulp deploy
```

The `nf` command can be installed by `npm install -g foreman`.
