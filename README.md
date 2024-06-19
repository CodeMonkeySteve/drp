= DRP, Directed Ruby Programming

Grammatical Evolution + Genetic Programming = Directed Programming

DRP is a generative programming system which lets you do GP, GE, hybrid GP and GE, and which like GE separates the search algorithm from the program representation.

The Web site of DRP is http://drp.rubyforge.org.
Documentation can be found at http://drp.rubyforge.org/rdoc.
For a much more in depth explanation see the INTRO file in the rdoc.
The RubyForge project page is http://rubyforge.org/projects/drp, where the latest
version of DRP may be downloaded. 
DRP is also available as a RubyGem, see installation instructions below.

== Dependencies

DRP does not require any other packages. The test suite in the tests
directory requires the testing framework TestUnit, which comes with Ruby 1.8
and later and can also be found in the Ruby Application Archive
(http://raa.ruby-lang.org).

Deployment is handled by RubyGems and Rake.

== Installation

=== RubyGems Installation

To install drp as a gem, type:

    $ gem install drp

To update it if previously installed as a gem:

    $ gem update drp

To remove drp (although I'm sure you want want to do that):

    $ gem uninstall drp

You may need root privileges to install, update, or remove the gem.
You can also download the compressed archive, but installing
as a gem is much more highly recomended.

== Testing

To run the test suite if you have the gem installed:

    $ gem check -t drp

Note, it disconcertingly prints nothing on success.

If you are manually installing the archive:

    $ rake test

runs all of the tests in the test directory. 

= Support

* Visit the forums, bug list, and mailing list pages at
  http://rubyforge.org/projects/drp

* Send email to Christophe McKeon at mailto:polypus@yahoo.com

* Ask on the ruby-talk mailing list or ruby forum

= Administrivia

:include:AUTHORS
Copyright (c) 2006, Christophe McKeon
Software License:: Distributed under the GNU GPL, see LICENSE
Documentation and Website:: Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License

== Warranty

This software is provided "as is" and without any express or implied
warranties, including, without limitation, the implied warranties of
merchantability and fitness for a particular purpose.
