# Minor bugfix for earlier version of Discourse. Can remove when I only use 1.8.0+ Discourse?
Rails.application.config.assets.precompile += %w( jquery_include.js )
