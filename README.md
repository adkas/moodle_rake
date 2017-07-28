# moodle_rake

`moodle_rake` is a simple rake file to perform server side moodle
maintenance tasks. Assuming that there are multiple moodle instances on
the same server it provides backup / restore tasks.


## prerequisites

-   ruby 1.8.7 - this version is stil found on most of the shared
    hosters ..

-   I even run it with travelling ruby (http://phusion.github.io/traveling-ruby/) as our
    web hoster no longer supports ruby in shared hosting plans.


## Installation

-   ssh to your webserver
-   crate a directory structure as follows

        <somewhere>
         +-- moodle_live
         |    |
         |    +-- moodle_code          # webserver domain root hardcoded in rakefile.rb
         |    +-- moodle_data          # moodle datafolder - foldername taken from config.php
         |    +-- install_config       # hardcoded in rakefile.rb
         |        |
         |        +--  config.php      # the config file for moodle_live  
         |        +--  .htaccess
         |        +--  php.ini         
         |    +-- rakefile.rb          # rakfile of this project
         |
         +-- <another moodle instance>
         |
         +-- moodle_backups

-   cd to root of this folder
-   `$ git clone -b release https://github.com/bwl21/moodle_rake.git .`
    in case of a new installation
-   `$ git pull` to update

## usage

-   ssh to your webserver
-   cd to root of your moodle-instance, e.g. `cd /www/moodle_live`
-   enter one of the following commands

    `rake backup` to produce a full backup

    `rake showBackups` to list the available backups

    `rake restore[<name of backup>]` to restore the backup into the
    current instance. Note that all exisiting data will be overwritten

## further hints

-   Note that you should have the configuration of the target instance
    prepared and stored in `<instance>/install_config/config.php`. The
    raketask investigates this config file and performs the necessary
    changes in the moodle links as indicated in
    <https://docs.moodle.org/20/en/Site_backup> respectively
    <https://docs.moodle.org/20/en/Moodle_migration>.

-   this rake task assumes that the moodle code lives in the folder
    `<instance>/moodle_code` while the data folder is taken from the
    config files.

-   you can run a cron-job to automate the backup. Use
    `cron_backup_moodle.sh` to do so.
    
-   note that install_config is there to keep current versions of file
    for your paticular installation. You need to copy them to moodle_code
    manually if needed.    
    
## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
