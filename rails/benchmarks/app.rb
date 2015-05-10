require_relative 'support/app_base'
require_relative 'support/benchmark_rails'

post_params =  {
  post: {
    title: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    author: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
  }
}

comment_params = {
  comment: {
    body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    email: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
    author: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
  }
}

Benchmark.rails("overall_app", time: 10) do
  AppBenchmark.request(:get, "/posts")

  2.times do
    AppBenchmark.request(:get, "/posts/new")
    AppBenchmark.request(:post, "/posts", body: post_params)
  end

  Post.all.each do |post|
    post_path = "/posts/#{post.id}"
    AppBenchmark.request(:get, post_path)
    AppBenchmark.request(:post, "#{post_path}/comments", body: comment_params)

    if Comment.count.zero?
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
