require 'chef_helper'

describe 'enabling letsencrypt' do
  before do
    allow(Gitlab).to receive(:[]).and_call_original
    stub_gitlab_rb(external_url: 'https://fakehost.example.com')
  end

  let(:chef_run) { ChefSpec::SoloRunner.converge('gitlab::default') }

  context 'unspecified uses LetsEncrypt.should_auto_enable?' do
    it 'true' do
      allow(LetsEncrypt).to receive(:should_auto_enable?).and_return(true)

      expect(chef_run).to include_recipe('letsencrypt::enable')
    end

    it 'false' do
      allow(LetsEncrypt).to receive(:should_auto_enable?).and_return(false)

      expect(chef_run).not_to include_recipe('letsencrypt::enable')
    end
  end

  context 'specified' do
    it 'true' do
      stub_gitlab_rb(letsencrypt: { enable: true })

      expect(chef_run).to include_recipe('letsencrypt::enable')
    end

    it 'false' do
      stub_gitlab_rb(letsencrypt: { enable: false })

      expect(chef_run).not_to include_recipe('letsencrypt::enable')
    end
  end
end

describe 'letsencrypt::enable' do
  let(:chef_run) { ChefSpec::SoloRunner.converge('gitlab::default') }
  let(:node) { chef_run.node }

  let(:redirect_block) do
    <<-EOF
server {
  listen *:80;

  server_name fakehost.example.com;
  server_tokens off; ## Don't show the nginx version number, a security best practice

  location /.well-known {
    root /var/opt/gitlab/nginx/www/;
  }

  location / {
    return 301 https://fakehost.example.com:443$request_uri;
  }

  # health checks configuration
  include /var/opt/gitlab/nginx/conf/gitlab-health.conf;

  access_log  /var/log/gitlab/nginx/gitlab_access.log gitlab_access;
  error_log   /var/log/gitlab/nginx/gitlab_error.log;
}
    EOF
  end

  before do
    allow(Gitlab).to receive(:[]).and_call_original
    allow(LetsEncrypt).to receive(:should_auto_enable?).and_return(false)
    allow_any_instance_of(OmnibusHelper).to receive(:service_up?).and_return(false)
    allow_any_instance_of(OmnibusHelper).to receive(:service_up?).with('nginx').and_return(true)
  end

  context 'default' do
    it 'does not run' do
      expect(chef_run).not_to include_recipe('letsencrypt::enable')
    end
  end

  context 'enabled' do
    before do
      stub_gitlab_rb(
        external_url: 'https://fakehost.example.com',
        letsencrypt: {
          enable: true
        }
      )
    end

    it 'is included' do
      expect(chef_run).to include_recipe('letsencrypt::enable')
    end

    it 'Updates nginx configuration' do
      expect(node['gitlab']['nginx']['redirect_http_to_https']).to be_truthy
      expect(chef_run).to render_file('/var/opt/gitlab/nginx/conf/gitlab-http.conf')
        .with_content(redirect_block)
    end

    it 'uses http authorization by default' do
      expect(chef_run).to include_recipe('letsencrypt::http_authorization')
    end

    it 'creates a self signed certificate' do
      expect(chef_run).to create_acme_selfsigned('fakehost.example.com').with(
        key: '/etc/gitlab/ssl/fakehost.example.com.key',
        crt: '/etc/gitlab/ssl/fakehost.example.com.crt'
      )
    end

    it 'creates a letsencrypt certificate' do
      expect(chef_run).to create_letsencrypt_certificate('fakehost.example.com').with(
        key: '/etc/gitlab/ssl/fakehost.example.com.key',
        crt: '/etc/gitlab/ssl/fakehost.example.com.crt'
      )
    end

    it 'warns the user' do
      prod_cert = chef_run.letsencrypt_certificate('fakehost.example.com')
      expect(prod_cert).to notify('ruby_block[display_le_message]').to(:run)
    end

    context 'auto_renew' do
      context 'default' do
        it 'enables crond' do
          expect(chef_run).to include_recipe('crond::enable')
        end

        it 'adds a crond_job' do
          expect(chef_run).to create_crond_job('letsencrypt-renew').with(
            user: "root",
            hour: 0,
            minute: 31,
            day_of_month: "*/4",
            command: "/opt/gitlab/bin/gitlab-ctl renew-le-certs"
          )
        end

        it 'does not log a warning' do
          expect(LoggingHelper).not_to receive(:warning)
          chef_run.ruby_block('display_le_message').block.call
        end
      end

      context 'false' do
        before { stub_gitlab_rb(letsencrypt: { enable: true, auto_renew: false }) }

        it 'does not enable crond' do
          expect(chef_run).not_to include_recipe('crond::enable')
        end

        it 'warns that we do not setup automatic renewal' do
          expect(LoggingHelper).to receive(:warning).with(/does not setup/)
          chef_run.ruby_block('display_le_message').block.call
        end
      end
    end

    context 'external_url uses http' do
      before do
        stub_gitlab_rb(
          external_url: 'http://plainhost.example.com',
          letsencrypt: {
            enable: true
          }
        )
      end

      it 'logs a warning' do
        expect(chef_run).to run_ruby_block('http external-url')
      end
    end
  end
end

# This should work standalone for renewal purposes
describe 'letsencrypt::renew' do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge('gitlab::letsencrypt_renew')
  end

  before do
    allow_any_instance_of(OmnibusHelper).to receive(:service_up?).and_return(false)
    allow_any_instance_of(OmnibusHelper).to receive(:service_up?).with('nginx').and_return(true)
  end

  context 'letsencrypt enabled' do
    before do
      allow(Gitlab).to receive(:[]).and_call_original
      stub_gitlab_rb(
        external_url: 'https://standalone.fakehost.com',
        letsencrypt: {
          enable: true
        }
      )
    end

    it 'executes letsencrypt_certificate' do
      expect(chef_run).to create_letsencrypt_certificate('standalone.fakehost.com')
    end
  end

  context 'letsencrypt auto-enabled' do
    before do
      allow(Gitlab).to receive(:[]).and_call_original
      allow(OpenSSL::X509::Certificate).to receive(:not_after).and_return(Time.now - 1)
      stub_gitlab_rb(
        external_url: 'https://standalone.fakehost.com'
      )
    end

    it 'executes letsencrypt_certificate' do
      expect(chef_run).to create_letsencrypt_certificate('standalone.fakehost.com')
    end
  end
end
