{
    servers => {
        windows => {
            firefox => {
                1 => {
                   #ip       => '192.168.56.103',
                    ip       => '192.168.56.101',
                    port     => 4444,
                    vboxname => "IE10 - Win7",
                    desc     => 'ff 1 (informative)',

                    #vm_host_ip => '192.168.56.1',
                    vm_host_ip => '172.22.98.219',
                },
                2 => {
                    ip       => '192.168.56.101',
                   #ip       => '192.168.56.103',
                    port     => 4444,
                    vboxname => "IE10 - Win7",
                    desc     => 'ff 2',

                    #vm_host_ip => '192.168.56.1',
                    vm_host_ip => '172.22.98.219',
                },
            },
            chrome => {
                1 => {
                    ip       => '192.168.56.101',
                   #ip       => '192.168.56.103',
                    port     => 4444,
                    vboxname => "IE10 - Win7",
                    desc     => 'chrome 1',

                    #vm_host_ip => '192.168.56.1',
                    vm_host_ip => '172.22.98.219',
                },
                2 => {
                    ip       => '192.168.56.101',
                   #ip       => '192.168.56.103',
                    port     => 4444,
                    vboxname => "IE10 - Win7",
                    desc     => 'chrome 2 windows',

                    #vm_host_ip => '192.168.56.1',
                    vm_host_ip => '172.22.98.219',
                },
            }
        }
    }
}
