require 'spec_helper'

describe file('/tmp/cron_stopped') do
  it { should be_file }
  its(:content) do
    expect(subject.content.lines.size).to eq 1
  end
end

# FIXME: cron service is not running in docker...
#
# root@3450c6da6ea5:/# ps -C cron
#   PID TTY          TIME CMD
# root@3450c6da6ea5:/# service cron start
# Rather than invoking init scripts through /etc/init.d, use the service(8)
# utility, e.g. service cron start
#
# Since the script you are attempting to invoke has been converted to an
# Upstart job, you may also use the start(8) utility, e.g. start cron
# root@3450c6da6ea5:/# ps -C cron
#   PID TTY          TIME CMD
# root@3450c6da6ea5:/#

# describe file('/tmp/cron_running') do
#   it { should be_file }
#   its(:content) do
#     expect(subject.content.lines.size).to eq 2
#   end
# end
