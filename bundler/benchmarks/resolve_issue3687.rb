require_relative 'support/benchmark_bundler.rb'

gemfile = proc do
  source 'http://rubygems.org'

  gem 'rails', '4.1.1'
  gem 'protected_attributes'
  gem 'puma', '~> 2.6'
  gem 'redis', '~> 3.0.7'
  gem 'newrelic_rpm'
  gem 'newrelic_resque_agent'
  gem 'mysql2'
  gem 'by_star'
  gem 'resque-scheduler'
  gem 'resque_mailer'
  gem 'exception_notification', '~> 4.0.1'
  gem 'exception_notification-rake', '~> 0.1.2'
  gem 'slack-notify'
  gem 'mandrill-api'
  gem 'mandrill_mailer'
  gem 'devise'
  gem 'cancan', '1.6.9'
  gem 'omniauth'
  gem 'omniauth-facebook'
  gem 'omniauth-twitter'
  gem 'omniauth-linkedin'
  gem 'omniauth-google-oauth2'
  gem 'savon'
  gem 'rest-client', '~> 1.6.7'
  gem 'nokogiri', '~> 1.6'
  gem 'khipu-rails', '~> 1.3.0', github: 'Janther/khipu-rails'
  gem 'khipu'
  gem 'finance', '~> 2.0.0'
  gem 'xirr_newton_calculator', '0.0.8'
  gem 'date_validator'
  gem 'decent_exposure'
  gem 'therubyracer'
  gem 'recaptcha', require: 'recaptcha/rails'
  gem 'tinymce-rails'
  gem 'ga_cookie_parser'
  gem 'state_machine'
  gem 'state_machine-audit_trail', github: 'Janther/state_machine-audit_trail'
  gem 'after_commit_queue'
  gem 'haml-rails'
  gem 'prawn_rails'
  gem 'prawn', github: 'prawnpdf/prawn', ref: '8a1415529c'
  gem 'pdfkit'
  gem 'paperclip', '~> 4.1'
  gem 'aws-sdk'
  gem 'jquery-fileupload-rails'
  gem 'remotipart', '~> 1.0'
  gem 'unf'
  gem 'acts-as-taggable-on'
  gem 'cocaine'
  gem 'cocoon'
  gem 'simple_form'
  gem 'best_in_place', github: 'bernat/best_in_place'
  gem 'will_paginate', '~> 3.0'
  gem 'will_paginate-bootstrap'
  gem 'number_to_words'
  gem 'gon'
  gem 'acts_as_list'
  gem 'wuparty'
  gem 'pipedrive-ruby', github: 'kitop/pipedrive-ruby'
  gem 'axlsx', '~> 2.0.1'
  gem 'axlsx_rails', '~> 0.1.5'
  gem 'html_truncator'
  gem 'active_link_to'
  gem 'spreadsheet'
  gem 'roo'
  gem 'google_drive'
  group :production, :staging do
    gem 'premailer-rails'
  end
  gem 'disqussion', github: 'jeremyvdw/disqussion'
  gem 'dalli'
  gem 'friendly_id', '~> 5.0'
  gem 'gritter'
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'backbone-on-rails'
  gem 'jquery-rails', '~> 2.1.4'
  gem 'jquery-ui-rails'
  gem 'underscore-rails'
  gem 'fancybox-rails'
  gem 'jquery-datatables-rails'
  gem 'jquery-tablesorter'
  gem 'select2-rails'
  gem 'chosen-rails'
  gem 'turbolinks'
  gem 'jquery-turbolinks'
  gem 'zurb-foundation', '4.0.9'
  gem 'font-awesome-sass-rails'
  gem 'flexslider'
  gem 'normalize-rails'
  gem 'zepto-rails'
  gem 'spinjs-rails'
  gem 'historyjs-rails'
  gem 'wysiwyg-rails'
  gem 'wysihtml5-rails'
  gem 'asset_sync', '~> 1.0'
  gem 'blueimp-templates-rails'
  gem 'bootstrap-switch-rails'
  gem 'momentjs-rails'
  gem 'accountingjs-rails'
  gem 'foundation-datetimepicker-rails', '~> 0.1.2'
  gem 'jquery-minicolors-rails'
  gem 'haml_coffee_assets'
  gem 'js-routes'
  gem 'rails-backbone-forms'
  gem 'time_diff'
  gem 'socket.io-rails'
  gem 'intercom-rails'
  gem 'intercom', "~> 2.4.4"
  gem 'mapbox-rails'
  gem 'activesupport-decorators', '~> 2.0'
  group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'byebug'
    gem 'guard-livereload', require: false
    gem 'rack-livereload'
    gem 'yajl-ruby'
    gem 'rails3-generators'
    gem 'railroady'
    gem 'rails-erd'
    gem 'erd'
    gem 'ruby-graphviz'
    gem 'letter_opener'
    gem 'foreman'
    gem 'rails-dev-boost'
    gem 'bullet'
    gem 'rack-mini-profiler'
  end
  group :development, :test do
    gem 'wirble'
    gem 'hirb'
    gem 'awesome_print'
    gem 'pry-rails'
    gem 'guard'
    gem 'rb-fsevent', require: false
    gem 'terminal-notifier-guard', require: false
    gem 'zeus', '~> 0.13.3'
    gem 'parallel_tests'
    gem 'zeus-parallel_tests'
  end
  group :test do
    gem 'rspec-rails'
    gem 'rspec-instafail'
    gem 'guard-rspec', require: false
    gem 'factory_girl_rails'
    gem 'capybara', '~> 2.1.0'
    gem 'poltergeist', '~> 1.5.1'
    gem 'shoulda', require: false
    gem 'launchy'
    gem 'selenium-webdriver', '~> 2.42.0'
    gem 'webmock'
    gem 'faker'
    gem 'database_cleaner', '~> 1.2.0'
    gem 'timecop'
    gem 'ci_reporter', '~> 1.9.2'
    gem 'resque_spec'
    gem 'pdf-reader', '~> 1.3.3'
  end
end

update = %w(paperclip bullet)

git_gems = {
  'git://github.com/jeremyvdw/disqussion.git (at master)' => Gem::Specification.new do |s|
    s.name = "disqussion"
    s.version = "0.0.7"
    s.add_runtime_dependency(%q<hashie>, ["~> 2.0"])
    s.add_runtime_dependency(%q<faraday>, ["~> 0.8"])
    s.add_runtime_dependency(%q<faraday_middleware>, [">= 0.9"])
    s.add_runtime_dependency(%q<multi_json>, ["~> 1.5"])
    s.add_runtime_dependency(%q<rash>, ["~> 0.3"])
  end,
  'git://github.com/kitop/pipedrive-ruby.git (at master)' => Gem::Specification.new do |s|
    s.name = "pipedrive-ruby"
    s.version = "0.2.6"
    s.add_runtime_dependency(%q<httparty>, [">= 0"])
    s.add_runtime_dependency(%q<json>, [">= 1.7.7"])
    s.add_runtime_dependency(%q<multi_xml>, [">= 0.5.2"])
    s.add_runtime_dependency(%q<webmock>, [">= 0"])
  end,
  'git://github.com/bernat/best_in_place.git (at master)' => Gem::Specification.new do |s|
    s.name = "best_in_place"
    s.version = "3.0.3"
    s.add_runtime_dependency(%q<actionpack>, [">= 3.2"])
    s.add_runtime_dependency(%q<railties>, [">= 3.2"])
  end,
  'git://github.com/prawnpdf/prawn.git (at 8a14155)' => Gem::Specification.new do |s|
    s.name = "prawn"
    s.version = "1.0.0.rc2"
    s.add_runtime_dependency(%q<pdf-reader>, ["~> 1.2"])
    s.add_runtime_dependency(%q<ttfunk>, ["~> 1.0.3"])
    s.add_runtime_dependency(%q<ruby-rc4>, [">= 0"])
    s.add_runtime_dependency(%q<afm>, [">= 0"])
  end,
  'git://github.com/Janther/state_machine-audit_trail.git (at master)' => Gem::Specification.new do |s|
    s.name = "state_machine-audit_trail"
    s.version = "0.1.0.1"
    s.add_runtime_dependency(%q<state_machine>, [">= 0"])
  end,
  'git://github.com/Janther/khipu-rails.git (at master)' => Gem::Specification.new do |s|
    s.name = "khipu-rails"
    s.version = "1.3.0"
    s.add_runtime_dependency(%q<rails>, [">= 3.1"])
    s.add_runtime_dependency(%q<jquery-rails>, [">= 0"])
    s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    s.add_runtime_dependency(%q<httpclient>, [">= 0"])
  end,
}

Benchmark.resolve_definition('issue3687', gemfile, unlock: update, lockfile: DATA.read, git_gems: git_gems)

__END__
GIT
  remote: git://github.com/Janther/khipu-rails.git
  revision: fab1db110cda88d0b6f35982ea28c1c194cd05c8
  specs:
    khipu-rails (1.3.0)
      httpclient
      jquery-rails
      nokogiri
      rails (>= 3.1)

GIT
  remote: git://github.com/Janther/state_machine-audit_trail.git
  revision: 8d0192732f4e501c237148f6e378a76ab589ce5c
  specs:
    state_machine-audit_trail (0.1.0.1)
      state_machine

GIT
  remote: git://github.com/bernat/best_in_place.git
  revision: 1ea07d3f362d63a938eb3b8f2c6c0f2037f86f0f
  specs:
    best_in_place (3.0.3)
      actionpack (>= 3.2)
      railties (>= 3.2)

GIT
  remote: git://github.com/jeremyvdw/disqussion.git
  revision: 5ad1b0325b7630daf41eb59fc8acbcb785cbc387
  specs:
    disqussion (0.0.7)
      faraday (~> 0.8)
      faraday_middleware (>= 0.9)
      hashie (~> 2.0)
      multi_json (~> 1.5)
      rash (~> 0.3)

GIT
  remote: git://github.com/kitop/pipedrive-ruby.git
  revision: 793a5e7abd64f1314eb9cd2e7690d9f364f8b919
  specs:
    pipedrive-ruby (0.2.6)
      httparty
      json (>= 1.7.7)
      multi_xml (>= 0.5.2)
      webmock

GIT
  remote: git://github.com/prawnpdf/prawn.git
  revision: 8a1415529c368a27f21edd6f8cf0303cb7788994
  ref: 8a1415529c
  specs:
    prawn (1.0.0.rc2)
      afm
      pdf-reader (~> 1.2)
      ruby-rc4
      ttfunk (~> 1.0.3)

GEM
  remote: http://rubygems.org/
  specs:
    Ascii85 (1.0.2)
    CFPropertyList (2.3.1)
    accountingjs-rails (0.0.4)
    actionmailer (4.1.1)
      actionpack (= 4.1.1)
      actionview (= 4.1.1)
      mail (~> 2.5.4)
    actionpack (4.1.1)
      actionview (= 4.1.1)
      activesupport (= 4.1.1)
      rack (~> 1.5.2)
      rack-test (~> 0.6.2)
    actionview (4.1.1)
      activesupport (= 4.1.1)
      builder (~> 3.1)
      erubis (~> 2.7.0)
    active_link_to (1.0.3)
      actionpack
    activemodel (4.1.1)
      activesupport (= 4.1.1)
      builder (~> 3.1)
    activerecord (4.1.1)
      activemodel (= 4.1.1)
      activesupport (= 4.1.1)
      arel (~> 5.0.0)
    activesupport (4.1.1)
      i18n (~> 0.6, >= 0.6.9)
      json (~> 1.7, >= 1.7.7)
      minitest (~> 5.1)
      thread_safe (~> 0.1)
      tzinfo (~> 1.1)
    activesupport-decorators (2.1.0)
      railties (>= 3.2.8)
    acts-as-taggable-on (3.5.0)
      activerecord (>= 3.2, < 5)
    acts_as_list (0.7.2)
      activerecord (>= 3.0)
    addressable (2.3.8)
    afm (0.2.2)
    after_commit_queue (1.1.0)
      rails (>= 3.0)
    akami (1.3.1)
      gyoku (>= 0.4.0)
      nokogiri
    arel (5.0.1.20140414130214)
    asset_sync (1.1.0)
      activemodel
      fog (>= 1.8.0)
      unf
    autoparse (0.3.3)
      addressable (>= 2.3.1)
      extlib (>= 0.9.15)
      multi_json (>= 1.0.0)
    awesome_print (1.6.1)
    aws-sdk (2.0.47)
      aws-sdk-resources (= 2.0.47)
    aws-sdk-core (2.0.47)
      builder (~> 3.0)
      jmespath (~> 1.0)
      multi_json (~> 1.0)
    aws-sdk-resources (2.0.47)
      aws-sdk-core (= 2.0.47)
    axlsx (2.0.1)
      htmlentities (~> 4.3.1)
      nokogiri (>= 1.4.1)
      rubyzip (~> 1.0.0)
    axlsx_rails (0.1.5)
      axlsx
      rails (>= 3.1)
    backbone-on-rails (1.1.2.1)
      eco
      ejs
      jquery-rails
      railties
    bcrypt (3.1.10)
    better_errors (2.1.1)
      coderay (>= 1.0.0)
      erubis (>= 2.6.6)
      rack (>= 0.9.0)
    binding_of_caller (0.7.2)
      debug_inspector (>= 0.0.1)
    blueimp-templates-rails (2.2.2)
      railties (>= 3.0, < 5.0)
    bootstrap-sass (2.2.2.0)
      sass (~> 3.2)
    bootstrap-switch-rails (3.3.2)
    builder (3.2.2)
    bullet (4.14.7)
      activesupport (>= 3.0.0)
      uniform_notifier (~> 1.9.0)
    by_star (2.2.1)
      activesupport
    byebug (5.0.0)
      columnize (= 0.9.0)
    cancan (1.6.9)
    capybara (2.1.0)
      mime-types (>= 1.16)
      nokogiri (>= 1.3.3)
      rack (>= 1.0.0)
      rack-test (>= 0.5.4)
      xpath (~> 2.0)
    celluloid (0.16.0)
      timers (~> 4.0.0)
    childprocess (0.5.6)
      ffi (~> 1.0, >= 1.0.11)
    choice (0.2.0)
    chosen-rails (1.4.1)
      coffee-rails (>= 3.2)
      compass-rails (>= 1.1.2)
      railties (>= 3.0)
      sass-rails (>= 3.2)
    chunky_png (1.3.4)
    ci_reporter (1.9.3)
      builder (>= 2.1.2)
    climate_control (0.0.3)
      activesupport (>= 3.0)
    cliver (0.3.2)
    cocaine (0.5.7)
      climate_control (>= 0.0.3, < 1.0)
    cocoon (1.2.6)
    coderay (1.1.0)
    coffee-rails (4.1.0)
      coffee-script (>= 2.2.0)
      railties (>= 4.0.0, < 5.0)
    coffee-script (2.4.1)
      coffee-script-source
      execjs
    coffee-script-source (1.9.1.1)
    columnize (0.9.0)
    compass (1.0.3)
      chunky_png (~> 1.2)
      compass-core (~> 1.0.2)
      compass-import-once (~> 1.0.5)
      rb-fsevent (>= 0.9.3)
      rb-inotify (>= 0.9)
      sass (>= 3.3.13, < 3.5)
    compass-core (1.0.3)
      multi_json (~> 1.0)
      sass (>= 3.3.0, < 3.5)
    compass-import-once (1.0.5)
      sass (>= 3.2, < 3.5)
    compass-rails (2.0.4)
      compass (~> 1.0.0)
      sass-rails (<= 5.0.1)
      sprockets (< 2.13)
    crack (0.4.2)
      safe_yaml (~> 1.0.0)
    css_parser (1.3.6)
      addressable
    dalli (2.7.4)
    database_cleaner (1.2.0)
    date_validator (0.8.0)
      activemodel
    debug_inspector (0.0.2)
    decent_exposure (2.3.2)
    devise (3.5.1)
      bcrypt (~> 3.0)
      orm_adapter (~> 0.1)
      railties (>= 3.2.6, < 5)
      responders
      thread_safe (~> 0.1)
      warden (~> 1.2.3)
    diff-lcs (1.2.5)
    eco (1.0.0)
      coffee-script
      eco-source
      execjs
    eco-source (1.1.0.rc.1)
    ejs (1.1.1)
    em-websocket (0.5.1)
      eventmachine (>= 0.12.9)
      http_parser.rb (~> 0.6.0)
    erd (0.3.2)
      nokogiri
      rails-erd (>= 0.4.5)
    erubis (2.7.0)
    eventmachine (1.0.7)
    exception_notification (4.0.1)
      actionmailer (>= 3.0.4)
      activesupport (>= 3.0.4)
    exception_notification-rake (0.1.2)
      exception_notification (~> 4.0.1)
      rake (>= 0.9.0)
    excon (0.45.3)
    execjs (2.5.2)
    extlib (0.9.16)
    factory_girl (4.5.0)
      activesupport (>= 3.0.0)
    factory_girl_rails (4.5.0)
      factory_girl (~> 4.5.0)
      railties (>= 3.0.0)
    faker (1.4.3)
      i18n (~> 0.5)
    fancybox-rails (0.2.1)
      railties (>= 3.1.0)
    faraday (0.9.1)
      multipart-post (>= 1.2, < 3)
    faraday_middleware (0.9.1)
      faraday (>= 0.7.4, < 0.10)
    ffi (1.9.8)
    finance (2.0.0)
      flt (>= 1.3.0)
    fission (0.5.0)
      CFPropertyList (~> 2.2)
    flexslider (2.2.0)
      sass-rails (>= 3.1.0)
    flt (1.5.0)
    fog (1.30.0)
      fog-atmos
      fog-aws (~> 0.0)
      fog-brightbox (~> 0.4)
      fog-core (~> 1.27, >= 1.27.4)
      fog-ecloud
      fog-google (>= 0.0.2)
      fog-json
      fog-local
      fog-powerdns (>= 0.1.1)
      fog-profitbricks
      fog-radosgw (>= 0.0.2)
      fog-riakcs
      fog-sakuracloud (>= 0.0.4)
      fog-serverlove
      fog-softlayer
      fog-storm_on_demand
      fog-terremark
      fog-vmfusion
      fog-voxel
      fog-xml (~> 0.1.1)
      ipaddress (~> 0.5)
      nokogiri (~> 1.5, >= 1.5.11)
    fog-atmos (0.1.0)
      fog-core
      fog-xml
    fog-aws (0.4.0)
      fog-core (~> 1.27)
      fog-json (~> 1.0)
      fog-xml (~> 0.1)
      ipaddress (~> 0.8)
    fog-brightbox (0.7.1)
      fog-core (~> 1.22)
      fog-json
      inflecto (~> 0.0.2)
    fog-core (1.30.0)
      builder
      excon (~> 0.45)
      formatador (~> 0.2)
      mime-types
      net-scp (~> 1.1)
      net-ssh (>= 2.1.3)
    fog-ecloud (0.1.1)
      fog-core
      fog-xml
    fog-google (0.0.5)
      fog-core
      fog-json
      fog-xml
    fog-json (1.0.1)
      fog-core (~> 1.0)
      multi_json (~> 1.0)
    fog-local (0.2.1)
      fog-core (~> 1.27)
    fog-powerdns (0.1.1)
      fog-core (~> 1.27)
      fog-json (~> 1.0)
      fog-xml (~> 0.1)
    fog-profitbricks (0.0.2)
      fog-core
      fog-xml
      nokogiri
    fog-radosgw (0.0.4)
      fog-core (>= 1.21.0)
      fog-json
      fog-xml (>= 0.0.1)
    fog-riakcs (0.1.0)
      fog-core
      fog-json
      fog-xml
    fog-sakuracloud (1.0.1)
      fog-core
      fog-json
    fog-serverlove (0.1.2)
      fog-core
      fog-json
    fog-softlayer (0.4.6)
      fog-core
      fog-json
    fog-storm_on_demand (0.1.1)
      fog-core
      fog-json
    fog-terremark (0.1.0)
      fog-core
      fog-xml
    fog-vmfusion (0.1.0)
      fission
      fog-core
    fog-voxel (0.1.0)
      fog-core
      fog-xml
    fog-xml (0.1.2)
      fog-core
      nokogiri (~> 1.5, >= 1.5.11)
    font-awesome-rails (4.3.0.0)
      railties (>= 3.2, < 5.0)
    font-awesome-sass-rails (3.0.2.2)
      railties (>= 3.1.1)
      sass-rails (>= 3.1.1)
    foreman (0.78.0)
      thor (~> 0.19.1)
    formatador (0.2.5)
    foundation-datetimepicker-rails (0.1.3)
    friendly_id (5.1.0)
      activerecord (>= 4.0.0)
    ga_cookie_parser (0.2.0)
    gon (5.2.3)
      actionpack (>= 2.3.0)
      json
      multi_json
      request_store (>= 1.0.5)
    google-api-client (0.8.6)
      activesupport (>= 3.2)
      addressable (~> 2.3)
      autoparse (~> 0.3)
      extlib (~> 0.9)
      faraday (~> 0.9)
      googleauth (~> 0.3)
      launchy (~> 2.4)
      multi_json (~> 1.10)
      retriable (~> 1.4)
      signet (~> 0.6)
    google_drive (1.0.1)
      google-api-client (>= 0.7.0)
      nokogiri (>= 1.4.4, != 1.5.2, != 1.5.1)
      oauth (>= 0.3.6)
      oauth2 (>= 0.5.0)
    googleauth (0.4.1)
      faraday (~> 0.9)
      jwt (~> 1.4)
      logging (~> 2.0)
      memoist (~> 0.12)
      multi_json (= 1.11)
      signet (~> 0.6)
    gritter (1.1.0)
    guard (2.12.5)
      formatador (>= 0.2.4)
      listen (~> 2.7)
      lumberjack (~> 1.0)
      nenv (~> 0.1)
      notiffany (~> 0.0)
      pry (>= 0.9.12)
      shellany (~> 0.0)
      thor (>= 0.18.1)
    guard-compat (1.2.1)
    guard-livereload (2.4.0)
      em-websocket (~> 0.5)
      guard (~> 2.8)
      multi_json (~> 1.8)
    guard-rspec (4.5.1)
      guard (~> 2.1)
      guard-compat (~> 1.1)
      rspec (>= 2.99.0, < 4.0)
    gyoku (1.3.1)
      builder (>= 2.1.2)
    haml (4.0.6)
      tilt
    haml-rails (0.9.0)
      actionpack (>= 4.0.1)
      activesupport (>= 4.0.1)
      haml (>= 4.0.6, < 5.0)
      html2haml (>= 1.0.1)
      railties (>= 4.0.1)
    haml_coffee_assets (1.16.0)
      coffee-script (~> 2.0)
      sprockets (~> 2.0)
      tilt (~> 1.1)
    hashery (2.1.1)
    hashie (2.0.5)
    hike (1.2.3)
    hirb (0.7.3)
    historyjs-rails (1.0.1)
      railties (>= 3.0)
    hitimes (1.2.2)
    html2haml (2.0.0)
      erubis (~> 2.7.0)
      haml (~> 4.0.0)
      nokogiri (~> 1.6.0)
      ruby_parser (~> 3.5)
    html_truncator (0.4.1)
      nokogiri (~> 1.5)
    htmlentities (4.3.3)
    http_parser.rb (0.6.0)
    httparty (0.13.5)
      json (~> 1.8)
      multi_xml (>= 0.5.2)
    httpclient (2.6.0.1)
    httpi (2.4.0)
      rack
    i18n (0.7.0)
    inflecto (0.0.2)
    intercom (2.4.4)
      json (~> 1.8)
    intercom-rails (0.2.28)
      activesupport (> 3.0)
    ipaddress (0.8.0)
    jmespath (1.0.2)
      multi_json (~> 1.0)
    jquery-datatables-rails (3.3.0)
      actionpack (>= 3.1)
      jquery-rails
      railties (>= 3.1)
      sass-rails
    jquery-fileupload-rails (0.4.5)
      actionpack (>= 3.1)
      railties (>= 3.1)
      sass (>= 3.2)
    jquery-minicolors-rails (2.1.4.0)
      jquery-rails
      rails (>= 3.2.8)
    jquery-rails (2.1.4)
      railties (>= 3.0, < 5.0)
      thor (>= 0.14, < 2.0)
    jquery-tablesorter (1.17.1)
      railties (>= 3.2, < 5)
    jquery-turbolinks (2.1.0)
      railties (>= 3.1.0)
      turbolinks
    jquery-ui-rails (5.0.5)
      railties (>= 3.2.16)
    js-routes (1.0.1)
      railties (>= 3.2)
      sprockets-rails
    json (1.8.2)
    jwt (1.5.0)
    khipu (1.3.4)
    launchy (2.4.3)
      addressable (~> 2.3)
    letter_opener (1.4.1)
      launchy (~> 2.2)
    libv8 (3.16.14.7)
    listen (2.10.0)
      celluloid (~> 0.16.0)
      rb-fsevent (>= 0.9.3)
      rb-inotify (>= 0.9)
    little-plugger (1.1.3)
    logging (2.0.0)
      little-plugger (~> 1.1)
      multi_json (~> 1.10)
    lumberjack (1.0.9)
    macaddr (1.7.1)
      systemu (~> 2.6.2)
    mail (2.5.4)
      mime-types (~> 1.16)
      treetop (~> 1.4.8)
    mandrill-api (1.0.53)
      excon (>= 0.16.0, < 1.0)
      json (>= 1.7.7, < 2.0)
    mandrill_mailer (1.0.1)
      actionpack
      activesupport
      mandrill-api (~> 1.0.9)
    mapbox-rails (1.6.1.1)
    memoist (0.12.0)
    method_source (0.8.2)
    mime-types (1.25.1)
    mini_portile (0.6.2)
    minitest (5.7.0)
    momentjs-rails (2.10.2)
      railties (>= 3.1)
    mono_logger (1.1.0)
    multi_json (1.11.0)
    multi_xml (0.5.5)
    multipart-post (2.0.0)
    mysql2 (0.3.18)
    nenv (0.2.0)
    net-scp (1.2.1)
      net-ssh (>= 2.6.5)
    net-ssh (2.9.2)
    newrelic_plugin (1.0.3)
      faraday (>= 0.8.1)
      json
    newrelic_resque_agent (1.0.1)
      newrelic_plugin (= 1.0.3)
      redis (>= 3.0.4)
      resque (>= 1.24.1)
    newrelic_rpm (3.12.0.288)
    nokogiri (1.6.6.2)
      mini_portile (~> 0.6.0)
    nori (2.6.0)
    normalize-rails (3.0.3)
    notiffany (0.0.6)
      nenv (~> 0.1)
      shellany (~> 0.0)
    number_to_words (1.2.1)
    oauth (0.4.7)
    oauth2 (1.0.0)
      faraday (>= 0.8, < 0.10)
      jwt (~> 1.0)
      multi_json (~> 1.3)
      multi_xml (~> 0.5)
      rack (~> 1.2)
    omniauth (1.2.2)
      hashie (>= 1.2, < 4)
      rack (~> 1.0)
    omniauth-facebook (2.0.1)
      omniauth-oauth2 (~> 1.2)
    omniauth-google-oauth2 (0.2.6)
      omniauth (> 1.0)
      omniauth-oauth2 (~> 1.1)
    omniauth-linkedin (0.2.0)
      omniauth-oauth (~> 1.0)
    omniauth-oauth (1.1.0)
      oauth
      omniauth (~> 1.0)
    omniauth-oauth2 (1.3.0)
      oauth2 (~> 1.0)
      omniauth (~> 1.2)
    omniauth-twitter (1.2.0)
      json (~> 1.3)
      omniauth-oauth (~> 1.1)
    orm_adapter (0.5.0)
    paperclip (4.2.1)
      activemodel (>= 3.0.0)
      activesupport (>= 3.0.0)
      cocaine (~> 0.5.3)
      mime-types
    parallel (1.6.0)
    parallel_tests (1.3.9)
      parallel
    pdf-reader (1.3.3)
      Ascii85 (~> 1.0.0)
      afm (~> 0.2.0)
      hashery (~> 2.0)
      ruby-rc4
      ttfunk
    pdfkit (0.7.0)
    poltergeist (1.5.1)
      capybara (~> 2.1)
      cliver (~> 0.3.1)
      multi_json (~> 1.0)
      websocket-driver (>= 0.2.0)
    polyglot (0.3.5)
    prawn_rails (0.0.11)
      prawn (>= 0.11.1)
      railties (>= 3.0.0)
    premailer (1.8.4)
      css_parser (>= 1.3.6)
      htmlentities (>= 4.0.0)
    premailer-rails (1.8.2)
      actionmailer (>= 3, < 5)
      premailer (~> 1.7, >= 1.7.9)
    protected_attributes (1.0.9)
      activemodel (>= 4.0.1, < 5.0)
    pry (0.10.1)
      coderay (~> 1.1.0)
      method_source (~> 0.8.1)
      slop (~> 3.4)
    pry-rails (0.3.4)
      pry (>= 0.9.10)
    puma (2.11.3)
      rack (>= 1.1, < 2.0)
    rack (1.5.3)
    rack-livereload (0.3.15)
      rack
    rack-mini-profiler (0.9.3)
      rack (>= 1.1.3)
    rack-protection (1.5.3)
      rack
    rack-test (0.6.3)
      rack (>= 1.0)
    railroady (1.3.0)
    rails (4.1.1)
      actionmailer (= 4.1.1)
      actionpack (= 4.1.1)
      actionview (= 4.1.1)
      activemodel (= 4.1.1)
      activerecord (= 4.1.1)
      activesupport (= 4.1.1)
      bundler (>= 1.3.0, < 2.0)
      railties (= 4.1.1)
      sprockets-rails (~> 2.0)
    rails-backbone-forms (0.14.0)
    rails-dev-boost (0.3.0)
      railties (>= 3.0)
    rails-erd (1.4.0)
      activerecord (>= 3.2)
      activesupport (>= 3.2)
      choice (~> 0.2.0)
      ruby-graphviz (~> 1.2)
    rails3-generators (1.0.0)
      railties (>= 3.0.0)
    railties (4.1.1)
      actionpack (= 4.1.1)
      activesupport (= 4.1.1)
      rake (>= 0.8.7)
      thor (>= 0.18.1, < 2.0)
    rake (10.4.2)
    rash (0.4.0)
      hashie (~> 2.0.0)
    rb-fsevent (0.9.5)
    rb-inotify (0.9.5)
      ffi (>= 0.5.0)
    rdoc (4.2.0)
    recaptcha (0.4.0)
    redis (3.0.7)
    redis-namespace (1.5.2)
      redis (~> 3.0, >= 3.0.4)
    ref (1.0.5)
    remotipart (1.2.1)
    request_store (1.1.0)
    responders (1.1.2)
      railties (>= 3.2, < 4.2)
    resque (1.25.2)
      mono_logger (~> 1.0)
      multi_json (~> 1.0)
      redis-namespace (~> 1.3)
      sinatra (>= 0.9.2)
      vegas (~> 0.1.2)
    resque-scheduler (4.0.0)
      mono_logger (~> 1.0)
      redis (~> 3.0)
      resque (~> 1.25)
      rufus-scheduler (~> 3.0)
    resque_mailer (2.2.7)
      actionmailer (>= 3.0)
    resque_spec (0.16.0)
      resque (>= 1.19.0)
      rspec-core (>= 3.0.0)
      rspec-expectations (>= 3.0.0)
      rspec-mocks (>= 3.0.0)
    rest-client (1.6.8)
      mime-types (~> 1.16)
      rdoc (>= 2.4.2)
    retriable (1.4.1)
    roo (1.13.2)
      nokogiri
      rubyzip
      spreadsheet (> 0.6.4)
    rspec (3.2.0)
      rspec-core (~> 3.2.0)
      rspec-expectations (~> 3.2.0)
      rspec-mocks (~> 3.2.0)
    rspec-core (3.2.3)
      rspec-support (~> 3.2.0)
    rspec-expectations (3.2.1)
      diff-lcs (>= 1.2.0, < 2.0)
      rspec-support (~> 3.2.0)
    rspec-instafail (0.2.6)
      rspec
    rspec-mocks (3.2.1)
      diff-lcs (>= 1.2.0, < 2.0)
      rspec-support (~> 3.2.0)
    rspec-rails (3.2.1)
      actionpack (>= 3.0, < 4.3)
      activesupport (>= 3.0, < 4.3)
      railties (>= 3.0, < 4.3)
      rspec-core (~> 3.2.0)
      rspec-expectations (~> 3.2.0)
      rspec-mocks (~> 3.2.0)
      rspec-support (~> 3.2.0)
    rspec-support (3.2.2)
    ruby-graphviz (1.2.2)
    ruby-ole (1.2.11.8)
    ruby-rc4 (0.1.5)
    ruby_parser (3.7.0)
      sexp_processor (~> 4.1)
    rubyzip (1.0.0)
    rufus-scheduler (3.1.2)
    safe_yaml (1.0.4)
    sass (3.4.14)
    sass-rails (5.0.1)
      railties (>= 4.0.0, < 5.0)
      sass (~> 3.1)
      sprockets (>= 2.8, < 4.0)
      sprockets-rails (>= 2.0, < 4.0)
      tilt (~> 1.1)
    savon (2.11.0)
      akami (~> 1.2)
      builder (>= 2.1.2)
      gyoku (~> 1.2)
      httpi (~> 2.3)
      nokogiri (>= 1.4.0)
      nori (~> 2.4)
      uuid (~> 2.3.7)
      wasabi (~> 3.4)
    select2-rails (3.5.9.3)
      thor (~> 0.14)
    selenium-webdriver (2.42.0)
      childprocess (>= 0.5.0)
      multi_json (~> 1.0)
      rubyzip (~> 1.0)
      websocket (~> 1.0.4)
    sexp_processor (4.6.0)
    shellany (0.0.1)
    shoulda (3.5.0)
      shoulda-context (~> 1.0, >= 1.0.1)
      shoulda-matchers (>= 1.4.1, < 3.0)
    shoulda-context (1.2.1)
    shoulda-matchers (2.8.0)
      activesupport (>= 3.0.0)
    signet (0.6.0)
      addressable (~> 2.3)
      extlib (~> 0.9)
      faraday (~> 0.9)
      jwt (~> 1.0)
      multi_json (~> 1.10)
    simple_form (3.1.0)
      actionpack (~> 4.0)
      activemodel (~> 4.0)
    sinatra (1.4.6)
      rack (~> 1.4)
      rack-protection (~> 1.4)
      tilt (>= 1.3, < 3)
    slack-notify (0.4.1)
      faraday (~> 0.9)
      json (~> 1.8)
    slop (3.6.0)
    socket.io-rails (1.3.5)
      railties (>= 3.1)
    spinjs-rails (1.4)
      rails (>= 3.1)
    spreadsheet (1.0.3)
      ruby-ole (>= 1.0)
    sprockets (2.12.3)
      hike (~> 1.2)
      multi_json (~> 1.0)
      rack (~> 1.0)
      tilt (~> 1.1, != 1.3.0)
    sprockets-rails (2.3.1)
      actionpack (>= 3.0)
      activesupport (>= 3.0)
      sprockets (>= 2.8, < 4.0)
    state_machine (1.2.0)
    systemu (2.6.5)
    terminal-notifier-guard (1.6.4)
    therubyracer (0.12.2)
      libv8 (~> 3.16.14.0)
      ref
    thor (0.19.1)
    thread_safe (0.3.5)
    tilt (1.4.1)
    time_diff (0.3.0)
      activesupport
      i18n
    timecop (0.7.3)
    timers (4.0.1)
      hitimes
    tinymce-rails (4.1.6)
      railties (>= 3.1.1)
    treetop (1.4.15)
      polyglot
      polyglot (>= 0.3.1)
    ttfunk (1.0.3)
    turbolinks (2.5.3)
      coffee-rails
    tzinfo (1.2.2)
      thread_safe (~> 0.1)
    uglifier (2.7.1)
      execjs (>= 0.3.0)
      json (>= 1.8.0)
    underscore-rails (1.8.2)
    unf (0.1.4)
      unf_ext
    unf_ext (0.0.7.1)
    uniform_notifier (1.9.0)
    uuid (2.3.7)
      macaddr (~> 1.0)
    vegas (0.1.11)
      rack (>= 1.0.0)
    warden (1.2.3)
      rack (>= 1.0)
    wasabi (3.5.0)
      httpi (~> 2.0)
      nokogiri (>= 1.4.2)
    webmock (1.21.0)
      addressable (>= 2.3.6)
      crack (>= 0.3.2)
    websocket (1.0.7)
    websocket-driver (0.5.4)
      websocket-extensions (>= 0.1.0)
    websocket-extensions (0.1.2)
    will_paginate (3.0.7)
    will_paginate-bootstrap (1.0.1)
      will_paginate (>= 3.0.3)
    wirble (0.1.3)
    wuparty (1.2.6)
      httparty (>= 0.6.1)
      mime-types (~> 1.16)
      multipart-post (>= 1.0.1)
    wysihtml5-rails (0.0.4)
      railties (>= 3.1.0)
    wysiwyg-rails (1.2.7)
      font-awesome-rails (>= 4.2.0.0)
      railties (>= 3.2, < 5.0)
    xirr_newton_calculator (0.0.8)
    xpath (2.0.0)
      nokogiri (~> 1.3)
    yajl-ruby (1.2.1)
    zepto-rails (0.0.2)
    zeus (0.13.3)
      method_source (>= 0.6.7)
    zeus-parallel_tests (0.2.4)
      parallel_tests (>= 0.11.3)
      zeus (~> 0.13.3)
    zurb-foundation (4.0.9)
      sass (>= 3.2.0)

PLATFORMS
  ruby

DEPENDENCIES
  accountingjs-rails
  active_link_to
  activesupport-decorators (~> 2.0)
  acts-as-taggable-on
  acts_as_list
  after_commit_queue
  asset_sync (~> 1.0)
  awesome_print
  aws-sdk
  axlsx (~> 2.0.1)
  axlsx_rails (~> 0.1.5)
  backbone-on-rails
  best_in_place!
  better_errors
  binding_of_caller
  blueimp-templates-rails
  bootstrap-sass (~> 2.2.2.0)
  bootstrap-switch-rails
  bullet
  by_star
  byebug
  cancan (= 1.6.9)
  capybara (~> 2.1.0)
  chosen-rails
  ci_reporter (~> 1.9.2)
  cocaine
  cocoon
  coffee-rails
  compass-rails
  dalli
  database_cleaner (~> 1.2.0)
  date_validator
  decent_exposure
  devise
  disqussion!
  erd
  exception_notification (~> 4.0.1)
  exception_notification-rake (~> 0.1.2)
  factory_girl_rails
  faker
  fancybox-rails
  finance (~> 2.0.0)
  flexslider
  font-awesome-sass-rails
  foreman
  foundation-datetimepicker-rails (~> 0.1.2)
  friendly_id (~> 5.0)
  ga_cookie_parser
  gon
  google_drive
  gritter
  guard
  guard-livereload
  guard-rspec
  haml-rails
  haml_coffee_assets
  hirb
  historyjs-rails
  html_truncator
  intercom (~> 2.4.4)
  intercom-rails
  jquery-datatables-rails
  jquery-fileupload-rails
  jquery-minicolors-rails
  jquery-rails (~> 2.1.4)
  jquery-tablesorter
  jquery-turbolinks
  jquery-ui-rails
  js-routes
  khipu
  khipu-rails (~> 1.3.0)!
  launchy
  letter_opener
  mandrill-api
  mandrill_mailer
  mapbox-rails
  momentjs-rails
  mysql2
  newrelic_resque_agent
  newrelic_rpm
  nokogiri (~> 1.6)
  normalize-rails
  number_to_words
  omniauth
  omniauth-facebook
  omniauth-google-oauth2
  omniauth-linkedin
  omniauth-twitter
  paperclip (~> 4.1)
  parallel_tests
  pdf-reader (~> 1.3.3)
  pdfkit
  pipedrive-ruby!
  poltergeist (~> 1.5.1)
  prawn!
  prawn_rails
  premailer-rails
  protected_attributes
  pry-rails
  puma (~> 2.6)
  rack-livereload
  rack-mini-profiler
  railroady
  rails (= 4.1.1)
  rails-backbone-forms
  rails-dev-boost
  rails-erd
  rails3-generators
  rb-fsevent
  recaptcha
  redis (~> 3.0.7)
  remotipart (~> 1.0)
  resque-scheduler
  resque_mailer
  resque_spec
  rest-client (~> 1.6.7)
  roo
  rspec-instafail
  rspec-rails
  ruby-graphviz
  sass-rails
  savon
  select2-rails
  selenium-webdriver (~> 2.42.0)
  shoulda
  simple_form
  slack-notify
  socket.io-rails
  spinjs-rails
  spreadsheet
  state_machine
  state_machine-audit_trail!
  terminal-notifier-guard
  therubyracer
  time_diff
  timecop
  tinymce-rails
  turbolinks
  uglifier
  underscore-rails
  unf
  webmock
  will_paginate (~> 3.0)
  will_paginate-bootstrap
  wirble
  wuparty
  wysihtml5-rails
  wysiwyg-rails
  xirr_newton_calculator (= 0.0.8)
  yajl-ruby
  zepto-rails
  zeus (~> 0.13.3)
  zeus-parallel_tests
  zurb-foundation (= 4.0.9)

BUNDLED WITH
   1.10.1
