# Manage a local mccutchen/go-httpbin container for the integration tests.
#
# The public httpbin.org service is flaky and, under the CI matrix, receives
# so many simultaneous requests that it returns 500s. Running an httpbin-compatible
# server locally removes that external dependency.
#
# The `http_request` resource issues the HTTP request from the itamae process
# itself (`Net::HTTP`), so the reachable URL differs per backend:
#   - docker backend: itamae runs on the host    -> host_url    (published port)
#   - local  backend: itamae runs in a container -> NETWORK_URL (shared network)
# The container therefore exposes both a published loopback port and a shared network.
module HttpbinServer
  IMAGE     = 'ghcr.io/mccutchen/go-httpbin:2.24.0'
  NETWORK   = 'itamae-test'
  CONTAINER = 'httpbin'
  PORT      = 8080 # container port; also the port in NETWORK_URL
  NETWORK_URL = "http://#{CONTAINER}:#{PORT}".freeze # reachable from a container on NETWORK

  module_function

  # Host port to publish go-httpbin on. Overridable so local runs can avoid a
  # port already in use on the host (CI runners always have the default free).
  def host_port
    ENV.fetch('HTTPBIN_HOST_PORT', PORT.to_s)
  end

  # URL reachable from the itamae host (docker backend). Kept in sync with the
  # recipe default in spec/integration/recipes/*.rb.
  def host_url
    "http://127.0.0.1:#{host_port}"
  end

  def start
    create_network
    remove_container # drop any stale container from a previous run
    run! 'docker', 'run', '-d', '--name', CONTAINER,
         '--network', NETWORK,
         '-p', "127.0.0.1:#{host_port}:#{PORT}",
         IMAGE
  end

  def stop
    remove_container
    quiet 'docker', 'network', 'rm', NETWORK
  end

  def create_network
    return if system('docker', 'network', 'inspect', NETWORK, out: File::NULL, err: File::NULL)
    run! 'docker', 'network', 'create', NETWORK
  end

  def remove_container
    quiet 'docker', 'rm', '-f', CONTAINER
  end

  def run!(*cmd)
    system(*cmd) or raise "command failed: #{cmd.join(' ')}"
  end

  def quiet(*cmd)
    system(*cmd, out: File::NULL, err: File::NULL)
  end
end
