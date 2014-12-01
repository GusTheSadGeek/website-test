require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'
require 'capybara/angular'
require 'site_prism'
require 'active_support'
require 'active_support/core_ext'
require 'rspec'
require 'rspec/expectations'
require 'rspec/collection_matchers'
require 'benchmark'
require 'yaml'
require 'cucumber/blinkbox/environment'
require 'cucumber/blinkbox/data_dependencies'
require 'platform'
require 'require_all'

World(Capybara::Angular::DSL)