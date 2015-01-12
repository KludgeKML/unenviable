unenviable
==========

A gem to make ENV vars more explicit and manageable.

Twelve-factor rails applications use ENV vars to manage configuration that should not be in the repository - backing and service endpoints, passwords, per instance settings, and so forth. Because they can't be kept in the repo, it can be hard to keep track of which ENV vars are necessary for a project and why, and which branch of development a particular ENV var is scoped to.

By reading an environment variable description file (which contains no values and therefore can be checked into the repo), unenviable can compare it with the development environment (a combination of the current shell environment and a .env file if one exists), and make sure that all necessary variables are present. For any that are missing, it can prompt the user and describe why they are necessary.

### INSTALL:

From RubyGems: [![Gem Version](https://badge.fury.io/rb/unenviable.svg)](http://badge.fury.io/rb/unenviable)

### EXAMPLE USAGE:

In the config/ directory of your rails app, the file unenviable.yml should contain values like these:

    GOOGLE_MAPS_ENDPOINT:
       description:
       required: development, test, staging, production
    TEST_DISABLE_HTTPS:
       description: Disables the HTTPS section of tests
       forbidden: production
       initial_value: false

The structure is:

    <ENV VAR NAME>:
      description: <description of what the variable is used for>
      required: <optional, comma-separated list of environments that need the var to be set>
      forbidden: <optional, comma-separated list of environments in which the var must not be set>
      initial_value: <optional, initial value to suggest the variable is set to if missing>

### TOOLS:

unenviable can be called from a command line. 

    $ unenviable check 
 
...can provide a post-checkout or merge hook, comparing the current environment to the one specified in the file.

    $ unenviable generate

...will make a .env file with required variables (optional ones will be commented out, descriptions will be included with each variable and initial values will be included)

### RAILS USE:



Unenviable installs a railties object that will close the ENV file, raising errors if you have installed the ENV wrapper and a call to ENV is made after initialization.
