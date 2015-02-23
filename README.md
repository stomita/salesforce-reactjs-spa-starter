# Salesforce ReactJS SPA Starter
A template project to create ReactJS-based single page application on Salesforce, with automatic build script (Gulp.js)

## Setup
```
$ npm install
$ bower install
```

## Build files
```
$ gulp build
```

## Preview
Start web server by following command

```
$ gulp serve
```

Then access to `http://localhost:8000`.

## Deploy to Salesforce

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
