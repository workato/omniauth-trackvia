require 'spec_helper'

RSpec.describe OmniAuth::Strategies::Trackvia do
  let(:request) { double('Request', params: {}, cookies: {}, env: {}) }
  let(:profile) { raw_info_hash['profiles'].first }
  let(:token_object) { OpenStruct.new(params: token_params) }
  let(:token_params) do
    { "value" => "TOKEN_VALUE",
      "tokenType" => "bearer",
      "refreshToken" => {
        "value" => "REFRESH_TOKEN",
        "expiration" => "2090-01-01T00:00:00.000+0000" },
      "expiresIn" => 299,
      "expiration" => "2019-05-01T04:42:09.949+0000",
      "apiVersion" => "18.5",
      "oauth_id" => "valid_oauth_id",
      "accessToken" => "ACCESS_TOKEN" }
  end
  let(:raw_info_hash) do
    {
      "id": 10000,
      "currency": 'USD',
      "country": 'US',
      "timeZone": {
        "name": "UTC",
        "offset": 0
      },
      "language": nil,
      "username": 'testuser',
      "email": "example@trackvia.com",
      "updated": "2019-04-30T10:00:00.000Z",
      "created": "2019-04-30T10:00:00.000Z",
      "verified": true,
      "phone": "12345678",
      "supportUserRole": nil,
      "accounts": [
        {
          "id": 20000,
          "subDomain": nil,
          "databaseName": "test_db_432112",
          "packageName": "PLATFORM",
          "createdAt": "2019-04-30T10:00:00.000Z",
          "updatedAt": "2019-04-30T10:00:00.000Z",
          "userIsSuperAdmin": true,
          "accountFeatures": [
            {
              "id": 1,
              "name": "aws_lambda",
              "enabled": true,
              "editable": nil,
              "expiry": "2119-04-30T10:00:00.000Z",
              "trial": false,
              "status": nil,
              "isExpired": false,
              "enumName": "AWS_LAMBDA"
            }
          ],
          "accountTheme": {
            "themeAttributes": {},
            "company": "Test"
          },
          "domain": "trackvia.com",
          "sessionTimeout": 15,
          "onlySSO": nil,
          "sandboxName": nil,
          "isSandboxAccount": false,
          "logoutUrl": nil
        }
      ]
    }
  end

  subject do
    args = ['appid', 'secret', @options || {}].compact
    OmniAuth::Strategies::Trackvia.new(*args).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  it "has a version number" do
    expect(OmniAuth::Trackvia::VERSION).to eq '0.1.1'
  end

  describe 'client_options' do
    it 'has correct name' do
      expect(subject.options.name).to eq('trackvia')
    end

    it 'has correct site' do
      expect(subject.options.client_options.site).to eq('https://go.trackvia.com')
    end

    it 'has correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('https://go.trackvia.com/oauth/authorize')
    end

    it 'has correct token url' do
      expect(subject.options.client_options.token_url).to eq('https://go.trackvia.com/oauth/token')
    end
  end

  describe 'info' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
      allow(subject).to receive(:access_token).and_return(token_object)
    end

    it 'contains strict list of attrs' do
      expect(subject.info.keys).to contain_exactly(:uid, :name, :email)
    end

    it 'returns the uid' do
      expect(subject.info[:uid]).to eq(token_params['oauth_id'])
    end

    it 'returns the name' do
      expect(subject.info[:name]).to eq(raw_info_hash['username'])
    end

    it 'returns the email' do
      expect(subject.info[:email]).to eq(raw_info_hash['email'])
    end

    describe 'uid' do
      it 'returns the uid' do
        expect(subject.uid).to eq(token_params['oauth_id'])
      end
    end
  end

  describe 'request_phase' do
    context 'with a specified callback_url in the params' do
      before do
        params = { 'callback_url' => 'http://foo.dev/auth/trackvia/foobar' }
        allow(subject).to receive(:request) do
          double('Request', params: params)
        end
        allow(subject).to receive(:session) do
          double('Session', :[] => { 'callback_url' => params['callback_url'] })
        end
      end

      it 'returns the correct callback_path' do
        expect(subject.callback_path).to eq '/auth/trackvia/callback'
      end
    end

    context 'with no callback_url set' do
      it 'returns the default callback_path value' do
        expect(subject.callback_path).to eq '/auth/trackvia/callback'
      end
    end
  end
end
