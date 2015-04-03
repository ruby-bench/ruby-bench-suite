require_relative 'support/app_base.rb'
require_relative 'support/benchmark_rails.rb'

m = Benchmark.rails(100, "app") do
  AppBenchmark.accept = "application/json"

  2.times do
    AppBenchmark.request(:post, "/posts", body: { post: { title: Faker::Food.herb_or_spice, body: Faker::HipsterIpsum.words(50).join(" "), author: Faker::Name.name }})
  end

  req = AppBenchmark.request(:get, "/posts")
  unless JSON.parse(req[2][0]).any?
    raise "no posts"
  end

  Post.all.each do |post|
    post_path = "/posts/#{post.id}"
    req = AppBenchmark.request(:get, post_path)

    unless JSON.parse(req[2][0]).present?
      raise "blank post"
    end

    AppBenchmark.request(:post, "#{post_path}/comments", body: {
      comment: {
        body: Faker::HipsterIpsum.words(50).join(" "),
        email: Faker::Internet.email,
        author: Faker::Name.name
      }
    })
    if post.comments.count.zero?
      raise "comment not inserted"
    end

    AppBenchmark.request(:get, post_path)
    AppBenchmark.request(:delete, post_path)
    begin
      AppBenchmark.request(:get, post_path)
    rescue AppBenchmark::FailedRequest
    end
  end
end

puts m.to_json
