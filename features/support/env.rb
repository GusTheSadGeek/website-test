# ======== Set Load Paths ======
support_dir = File.dirname(__FILE__)
path_to_root = File.join(support_dir, '/../../')
$LOAD_PATH.unshift File.expand_path(support_dir)

# ======= Setup Test Config =======
TEST_CONFIG = ENV.to_hash || {}
TEST_CONFIG['server'] = TEST_CONFIG['SERVER'].to_s.downcase || 'test'

# ======== Load gems and config ======
puts 'Loading gems and config...'
require 'env_gems'
require 'env_config'

TEST_CONFIG['debug'] = config_flag_on?(TEST_CONFIG['DEBUG'])
TEST_CONFIG['fail_fast'] = config_flag_on?(TEST_CONFIG['FAIL_FAST'])
TEST_CONFIG['js_log'] ||= config_flag_on?(TEST_CONFIG['JS_LOG'])

require 'env_logger'
logger.unknown("Logging level: #{TEST_CONFIG['log_level']}")

ARGV.each { |a| logger.debug("Argument: #{a}") } if TEST_CONFIG['debug']
logger.debug("TEST_CONFIG: #{TEST_CONFIG}")

# ======== Load environment specific test data ======
# initialise test data in order to fail fast, if config is incorrect or data is missing
initialise_test_data

# ======= load common helpers in a particular order =======
# custom method to log required local helper libraries
module RequireAllExtensions
  def require_rel_and_log(*args)
    # Handle passing an array as an argument
    args.flatten!
    args.each { |file| logger.debug("Loading #{file}") } if TEST_CONFIG['debug']
    require_rel(args)
  end
end
include RequireAllExtensions

require_rel_and_log 'formatter/*.rb'
require_rel_and_log 'utils/*.rb'
require_rel_and_log 'page_models/*.rb'
require_rel_and_log 'page_models/sections/blinkboxbooks_section.rb'
require_rel_and_log 'page_models/sections/*.rb'
require_rel_and_log 'page_models/pages/blinkboxbooks_page.rb'
require_rel_and_log 'page_models/pages/*.rb'

# ======= Setup PATH env. variable =======
logger.info("RUBY_PLATFORM: #{RUBY_PLATFORM}")

case Platform::OS
when :win32
  separator = ";"
  current_os = 'win'
when :unix
  separator = ":"
  if Platform::IMPL == :macosx
    current_os = 'mac'
  else
    current_os = 'unix'
  end
else
  fail "Current OS is not supported by ChromeDriver and/or BrowserStack Local (OS: #{Platform::OS}, Implementation: #{Platform::IMPL}):\r\n- http://code.google.com/p/chromium/downloads/list\r\n- http://www.browserstack.com/local-testing#command-line"
end

chromedriver_path = File.expand_path File.join(path_to_root, 'lib', 'chromedrv', current_os)
browserstack_path = File.expand_path File.join(path_to_root, 'lib', 'browserstacklocal', current_os)

ENV["PATH"] = "#{browserstack_path}#{separator}#{chromedriver_path}#{separator}#{ENV["PATH"]}"

# ======= Setup target environment =======
Capybara.app_host = server('web')

# ======== set up browser driver =======
# Capybara browser driver settings
Capybara.default_driver = :selenium
Capybara.default_wait_time = environment_data('sync_timeout')
World(Capybara::Angular::DSL)

# target browser
TEST_CONFIG['BROWSER_NAME'] ||= 'chrome'
TEST_CONFIG['BROWSER_NAME'] = 'ie' if TEST_CONFIG['BROWSER_NAME'].downcase == 'internet explorer'
if TEST_CONFIG['GRID'] =~ /browserstack/i
  caps = Selenium::WebDriver::Remote::Capabilities.new
else
  browser_name = TEST_CONFIG['BROWSER_NAME'].downcase.to_sym
  caps = case browser_name
         when :chrome
           if TEST_CONFIG['performance_logging']
             caps_perflog = Selenium::WebDriver::Remote::Capabilities.chrome(
               "LOGGING_PREFS" => {"LogType" => ["PERFORMANCE"]}
             )
           end
           Selenium::WebDriver::Remote::Capabilities.send(browser_name)
         when :firefox, :safari, :ie, :android
           Selenium::WebDriver::Remote::Capabilities.send(browser_name)
         else
           fail "Not supported browser: #{TEST_CONFIG['BROWSER_NAME']}"
         end
  caps.version = TEST_CONFIG['BROWSER_VERSION']
end

# Overriding the default native events settings for Selenium.
# This is to make mouse over action working. Without this setting mouse over actions (to activate my account drop down, etc) are not working.
caps.native_events = false

# grid setup
if config_flag_on?(TEST_CONFIG['GRID'])
  # target platform
  TEST_CONFIG['PLATFORM'] ||= 'FIRST_AVAILABLE'
  case TEST_CONFIG['PLATFORM'].upcase
  when 'MAC', 'XP', 'VISTA', 'WIN8', 'WINDOWS', 'LINUX' # *WINDOWS* stands for Windows 7
    TEST_CONFIG['GRID_HUB_IP'] ||= '172.17.51.12'
    caps.platform = TEST_CONFIG['PLATFORM'].upcase.to_sym
  when 'ANDROID'
    TEST_CONFIG['GRID_HUB_IP'] ||= 'localhost'
    caps.platform = TEST_CONFIG['PLATFORM'].downcase.to_sym
  when 'FIRST_AVAILABLE'
    TEST_CONFIG['GRID_HUB_IP'] ||= '172.17.51.12'
    #do not set caps.platform, in order to force selenium grid hub to pick up the first available node,
    #which matches other specified capabilities. NB nodes are ordered by the order of registration with the hub.
  else
    fail "Not supported platform: #{TEST_CONFIG['PLATFORM']}"
  end

  # register the remote driver
  grid_url = "http://#{TEST_CONFIG['GRID_HUB_IP']}:4444/wd/hub"
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote,
                                   :url => grid_url,
                                   :desired_capabilities => caps)
  end

elsif TEST_CONFIG['GRID'] =~ /browserstack/i
  # Default values
  TEST_CONFIG['BROWSER_NAME'] ||= 'chrome'
  TEST_CONFIG['BROWSER_VERSION'] ||= '30.0'
  TEST_CONFIG['OS'] ||= 'Windows'
  TEST_CONFIG['OS_VERSION'] ||= '7'

  # TODO: Logger
  logger.info('-- BrowserStack settings --')
  logger.info("Browser name: #{TEST_CONFIG['BROWSER_NAME']}")
  logger.info("Browser version: #{TEST_CONFIG['BROWSER_VERSION']}")
  logger.info("OS: #{TEST_CONFIG['OS']}")
  logger.info("OS version: #{TEST_CONFIG['OS_VERSION']}")

  caps["browser"] = TEST_CONFIG['BROWSER_NAME']
  caps["browser_version"] = TEST_CONFIG['BROWSER_VERSION']
  caps["os"] = TEST_CONFIG['OS']
  caps["os_version"] = TEST_CONFIG['OS_VERSION']
  caps["browserstack.debug"] = "true"
  caps["name"] = TEST_CONFIG['BROWSERSTACK_SESSION_TITLE'].nil? ? "Untitled BrowserStack session" : TEST_CONFIG['BROWSERSTACK_SESSION_TITLE']
  caps["project"] = TEST_CONFIG['BROWSERSTACK_PROJECT'].nil? ? "on_demand" : TEST_CONFIG['BROWSERSTACK_PROJECT']
  caps["build"] = TEST_CONFIG['BROWSERSTACK_BUILD'] unless TEST_CONFIG['BROWSERSTACK_BUILD'].nil?
  caps["browserstack.debug"] = "false"
  TEST_CONFIG['BROWSERSTACK_USERNAME'] ||= "TEST"
  TEST_CONFIG['BROWSERSTACK_KEY'] ||= "TEST"

  # Check BrowserStack availability
  fail 'No more parallel sessions available!' unless APIMethods::Browserstack.new(TEST_CONFIG['BROWSERSTACK_USERNAME'], TEST_CONFIG['BROWSERSTACK_KEY']).session_available?
  fail 'The specified project does not exists in BrowserStack!' unless APIMethods::Browserstack.new(TEST_CONFIG['BROWSERSTACK_USERNAME'], TEST_CONFIG['BROWSERSTACK_KEY']).project_exists?(TEST_CONFIG['BROWSERSTACK_PROJECT'])
  fail 'Not supported BrowserStack capabilities!' unless APIMethods::Browserstack.new(TEST_CONFIG['BROWSERSTACK_USERNAME'], TEST_CONFIG['BROWSERSTACK_KEY']).valid_capabilities?(TEST_CONFIG['BROWSER_NAME'], TEST_CONFIG['BROWSER_VERSION'], TEST_CONFIG['OS'], TEST_CONFIG['OS_VERSION'])

  if TEST_CONFIG['SERVER'] == "PRODUCTION"
    caps["browserstack.local"] = "false"
  else
    caps["browserstack.local"] = "true"
    # Running tunneling binary as background process
    $browser_stack_tunnel = BrowserstackUtilities::BrowserstackTunnel.new(TEST_CONFIG['BROWSERSTACK_KEY'], environments(TEST_CONFIG['SERVER']))
    $browser_stack_tunnel.start
  end

  grid_url = "http://#{TEST_CONFIG['BROWSERSTACK_USERNAME']}:#{TEST_CONFIG['BROWSERSTACK_KEY']}@hub.browserstack.com/wd/hub"

  # register the remote driver
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote,
                                   :url => grid_url,
                                   :desired_capabilities => caps)
  end

else
  # register local browser driver
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => browser_name,
                                   :desired_capabilities => caps)
  end

end

#======== Headless Mode ======
if config_flag_on?(TEST_CONFIG['HEADLESS'])
  logger.info('Headless mode.')

  require 'headless'

  headless = Headless.new
  headless.start
end
