sub {

    my $linux = {
        firefox => {
            33 => {
                ip => '192.168.56.104',
                port       => 4444,
                vboxname   => "SeleniumLinux",
                desc       => 'ff 33',
                vm_host_ip => '192.168.56.1',
            },
        },
        chrome => {
            42 => {

                ip       => '192.168.56.104',
                port     => 4444,
                vboxname => "SeleniumLinux",
                desc     => 'chrome 42',

                vm_host_ip => '192.168.56.1',
            },
        },
    };


    my $win7 = {
        firefox => {
            1 => {
                ip => '192.168.56.101',

                #ip       => '192.168.56.101',
                port       => 4444,
                vboxname   => "IE10 - Win7",
                desc       => 'ff 1 (informative)',
                vm_host_ip => '192.168.56.1',
            },
            2 => {

                #ip       => '192.168.56.101',
                ip       => '192.168.56.101',
                port     => 4444,
                vboxname => "IE10 - Win7",
                desc     => 'ff 2',

                vm_host_ip => '192.168.56.1',
            },
        },
        chrome => {
            1 => {

                #ip       => '192.168.56.101',
                ip       => '192.168.56.101',
                port     => 4444,
                vboxname => "IE10 - Win7",
                desc     => 'chrome 1',

                vm_host_ip => '192.168.56.1',
            },
            2 => {

                #ip       => '192.168.56.101',
                ip       => '192.168.56.101',
                port     => 4444,
                vboxname => "IE10 - Win7",
                desc     => 'chrome 2 windows',

                vm_host_ip => '192.168.56.1',
            },
        },
        ie => {
            9 => {

                #ip       => '192.168.56.101',
                ip         => '192.168.56.103',
                port       => 4444,
                vboxname   => "IE9 - Win7",
                desc       => 'IE9 win7',
                vm_host_ip => '192.168.56.1',
            },
            10 => {

                #ip       => '192.168.56.101',
                ip       => '192.168.56.101',
                port     => 4444,
                vboxname => "IE10 - Win7",
                desc     => 'IE10 win7',

                vm_host_ip => '192.168.56.1',
            },
        },
    };

    return {
        servers => {
            windows  => $win7,
            windows7 => $win7,
            linux    => $linux,
        }
    };
  }
  ->();

