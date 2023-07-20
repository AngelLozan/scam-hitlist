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
