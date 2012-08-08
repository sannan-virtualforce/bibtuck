Bib + Tuck
==========

Hosting and Server Administration
------------

Currently all hosting is on BlueBoxGrid. This includes the database, web application, and files. Everything is managed using the 'deploy' user. To gain access to the server, make sure to copy your SSH public key to the 'authorized_keys' file found in:

    /home/deploy/.ssh/authorized_keys

The database being used is PostgreSQL.

Integrations
------------

AVIARY: All relevant JavaScript necessary for integration can be found in app/views/photos/_aviary.html.haml

PAYPAL: We are using PayPal Express in conjunction with activmerchant to build and facilitate payment processing. Currently PayPal is connected to the Paypal sandbox, with relevant API keys and gateway setup found in the appropriate config/environments/<your environment>.rb files. You will need a PayPal developer account to connect to the Paypal sandbox.

ENDICIA: All Endicia integration can be found in app/models/item.rb . All interaction with Endicia happens through the 'Endicia' class. The gem being used is a forked version on GitHub that improves on the shipping label generation.


Installation
------------

### Download repository

    git clone git@github.com:subseta/bibandtuck_com.git

### Move into project

    cd bibandtuck_com

### Install gems

    gem install bundler
    bundle install

### Configure database

    cp config/database.yml.example config/database.yml

### Create, migrate, and seed database

    RAILS_ENV=development be rake db:drop db:create db:migrate db:seed

### Start server

    rails s

### Navigate to homepage

    http://localhost:3000/

### Run tests

    rake

### Configure SMTP settings

    cp config/smtp.yml.example config/smtp.yml

Deploy to Bluebox
-----------------

Be sure to run all migrations like so:

    cap deploy
    cap deploy:migrations

Further Documentation
-------------

Information architecture (IA) and user experience (UX) documents can be found in doc/ia and doc/ux respectively. Please keep these up to date as new sitemaps and mockups are designed and delivered.

Annotate
--------

    annotate -p before -i -m
