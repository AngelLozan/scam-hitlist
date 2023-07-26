# Scam Reporting Full Stack Rails App

![Spam Banned Icon](https://github.com/AngelLozan/scam-hitlist/blob/main/app/assets/images/ban.png?raw=true)

An app to handle both database and user authentication for a scam reporting app.

Report IOCs and track their progress. Use a systematic approach to submitting and tracking IOCs with multiple API integrations.

Quicker and more efficient than using spreadsheets.

Allows for unauthorized users to submit IOCs. Allows for evidence attachment and tracking. Allows for multiple users to work on the same IOC.

## To import CSV data into Postgres. Need to set empty cells as null and placeholder timestamps for created and updated at if none. Order of columns must match order of columns in table.

run `heroku pg:psql -a scam-hitlist` to access postgres on heroku

```
\copy iocs(id,url,created_at,updated_at,removed_date,status,report_method_one,report_method_two,form,host,follow_up_date,follow_up_count,comments) FROM './lib/data.csv' WITH DELIMITER ',' NULL AS 'null' CSV HEADER;

```
Success message will be `copy 7000` or similar number.

## Setup
run `bundle install` to install dependencies
run `rails db:drop db:create db:migrate db:seed` to create database and seed with data

## To run
run `dev` to start server & run JS

If failing to see various features in front end, use `rails assets:precompile` to compile assets before running `dev`.


## Database setup
After seeding the database, you may need to manually find the next ID and set it in the rails console:

```
highest_id = Ioc.maximum(:id)

&&

next_available_id = highest_id + 1

ActiveRecord::Base.connection.execute("SELECT setval('iocs_id_seq', #{next_available_id}, false)")
```
In the case where you need to reset the sequence, you can run the following in the rails console (keep the `DATABASE` variable as is)):

```
heroku restart; heroku pg:reset DATABASE --confirm APP-NAME; heroku run rake db:migrate
```

## Deploying to Heroku:

In order to use `Grover` gem and `puppeteer` on Heroku, you need to add the following buildpacks:

Add Chrome buildpack:

```
heroku buildpacks:add heroku/google-chrome --index=1

```
Add Node/JS buildpack:

```
heroku buildpacks:add heroku/nodejs --index=2
```

Add Puppeteer buildpack (not sure if I still really need it or if Chrome build pack is enough will try at some point without it)

```
heroku buildpacks:add jontewks/puppeteer --index=3
```
Set the ENV variable to prevent downloading Chrominium:

```
heroku config:set PUPPETEER_SKIP_DOWNLOAD=true [--remote yourappname]

```
Configure the executable path in `config/initializers/grover.rb`:

```

Grover.configure do |config|
  config.options = {
    ...
    executable_path: "google-chrome"
  }
end
```

## Base Security Features

- Validates file size and limits to 5 mb and greater than 0
- Validates file type and only allows PDFs, .eml, jpeg, png, and txt
- Model Validations
- Uses built in methods to sanitize and remove xss attacks from form inputs (comments and url fields)
- Strong parameters
- CSRF meta tags used
- Strong Hash algorithm for cookies signatures (SHA-256)
- No open-uri use, no Marshal, no multiline, no use of html_safe, raw.
- Omniauth with limited users (2) and google enterprise account.

## Testing

- In controller rspec tests, create all model instances you would like to use. Then use `let` to create a variable that will be used in the tests. This will allow you to use the same variable in multiple tests without having to create a new instance each time. This will also allow you to use the same variable in multiple describe blocks. This is useful for testing the same variable in different contexts. For example, you can test the same variable in a context where it is valid and a context where it is invalid. This will allow you to test both the happy path and the sad path in the same test.
