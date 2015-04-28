# moodle_rake

`moodle_rake` is a simple rake file to perform server side moodle maintenance tasks. Assuming that there are multiple moodle instances on the same server it provides the following tasks

-  **rake showInstances**: list all instances on the machine. Instances are found by searching for moodle config files
-  **rake backup[instance]**: perform a site backup of that instance
-  **rake showBackups**: show all available backups
-  **rake restore[backup,instance]**: restore the backup to a particular instance

## prerequisites

* ruby 1.8.7 

## Installation

* ssh to your webserver
* create a new folder on your machine which is a sibling of your moodle installations
* cd to this folder, e.g. `cd moodle_rake`
* `$ git clone -b RELEASE git://github.com/bwl21/moodle_rake.git` in case of a new installation
* `$ git pull` to update

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
