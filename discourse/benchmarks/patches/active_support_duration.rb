# https://github.com/rails/rails/issues/21296
# https://bugs.ruby-lang.org/issues/11465
# This has been fixed in Rails 4.2 but we run Ruby trunk benchmarks against Discourse
# on Rails 4.1
module ActiveSupport
  refine Duration do
    def respond_to_missing?(method, include_private=false)
      @value.respond_to?(method, include_private)
    end
  end
end
