# Salesforce ReactJS SPA Starter

A template project to create ReactJS-based single page application on Salesforce, with automatic build script (Gulp.js)

## Setup

Make sure you are installing Node.js 0.10.x .

```
$ node --version
```

```
$ npm install
$ bower install
```

## Build files
```
$ gulp
```

for automatic building

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

```
$ SF_USERNAME=yourname@example.org SF_PASSWORD=password gulp deploy
```
or prepare `.env` file in `KEY=VALUE` format:

```
SF_USERNAME=yourname@example.org
SF_PASSWORD=password
```

Then execute `gulp deploy` using `foreman`

```
$ nf run gulp deploy
```

The `nf` command will be installed by `npm install -g foreman`.
