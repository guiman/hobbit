require 'minitest_helper'

describe Hobbit::Base do
  include Rack::Test::Methods

  def app
    TestBaseApp.new
  end

  %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
    str = <<EOS
  describe "::#{verb.downcase}" do
    it 'must add a route to @routes' do
      #route = TestBaseApp.routes['#{verb}'].first
      #route[:path].must_equal '/'
    end

    it 'must extract the extra_params' do
      route = TestBaseApp.routes['#{verb}'].last
      route[:extra_params].must_equal [:name]
    end
  end
EOS
    class_eval str
  end

  describe '::settings' do
    let(:settings) { TestBaseApp.settings }

    it 'must return a hash with (at least) a request_class and response_class keys' do
      settings.must_be_kind_of Hash
      settings.must_include :request_class
      settings.must_include :response_class
    end

    it 'must be initialized with request_class as Rack::Request' do
      settings[:request_class].must_equal Rack::Request
    end

    it 'must be initialized with request_class as Hobbit::Response' do
      settings[:response_class].must_equal Hobbit::Response
    end
  end

  describe '::stack' do
    it 'must return an instance of Rack::Builder' do
      TestBaseApp.stack.must_be_kind_of Rack::Builder
    end
  end

  describe '::map' do
    it 'must mount a application to the rack stack' do
      skip '::map'
    end
  end

  describe '::new' do
    it 'should return an instance of Rack::Builder' do
      TestBaseApp.new.must_be_kind_of Rack::Builder
    end
  end

  describe '::routes' do
    it 'must return a Hash' do
      TestBaseApp.routes.must_be_kind_of Hash
    end
  end

  describe '::use' do
    it 'must add a middleware to the rack stack' do
      skip '::use'
    end
  end

  describe '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      str = <<EOS
    describe 'when the request matches a route' do
      it 'must match #{verb} /' do
        #{verb.downcase} '/'
        last_response.must_be :ok?
        last_response.body.must_equal '#{verb}'
      end

      it 'must match #{verb} /route.json' do
        #{verb.downcase} '/route.json'
        last_response.must_be :ok?
        last_response.body.must_equal '#{verb} /route.json'
      end

      it 'must match #{verb} /route/:id.json' do
        #{verb.downcase} '/route/1.json'
        last_response.must_be :ok?
        last_response.body.must_equal '1'
      end

      it 'must match #{verb} /:name' do
        #{verb.downcase} '/hobbit'
        last_response.must_be :ok?
        last_response.body.must_equal 'hobbit'

        #{verb.downcase} '/hello-hobbit'
        last_response.must_be :ok?
        last_response.body.must_equal 'hello-hobbit'
      end
    end

    describe 'when the request not matches a route' do
      it 'must respond with 404 status code' do
        #{verb.downcase} '/not/found'
        last_response.must_be :not_found?
        last_response.body.must_equal ''
      end
    end
EOS
      class_eval str
    end
  end

  it 'must respond to call' do
    app = TestBaseApp.new
    app.must_respond_to :call
  end
end