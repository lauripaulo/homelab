When installing Pi-hole, especially on systems like Ubuntu 17.10+ or Fedora 33+ that use systemd-resolved, you might encounter a conflict where systemd-resolved is already using port 53, preventing Pi-hole from binding to it. This occurs because systemd-resolved implements a caching DNS stub resolver that listens on this port by default.
To address this, you need to disable the DNSStubListener feature of systemd-resolved and ensure your system's DNS configuration correctly points to Pi-hole.
Here are the steps to resolve this conflict: Disable DNSStubListener in systemd-resolved.
Create a new configuration file to override the default systemd-resolved settings:
Código

    sudo sh -c 'mkdir -p /etc/systemd/resolved.conf.d && printf "[Resolve]\nDNSStubListener=no\n" | tee /etc/systemd/resolved.conf.d/no-stub.conf'

This command creates a directory /etc/systemd/resolved.conf.d if it doesn't exist and then creates a file no-stub.conf within it, setting DNSStubListener=no. Update /etc/resolv.conf symlink.
By default, /etc/resolv.conf might be symlinked to stub-resolv.conf, which expects the stub listener to be active. You need to change this symlink to point to the file that systemd-resolved updates with system-wide DNS settings (e.g., from Netplan or sysconfig):
Código

    sudo sh -c 'rm -f /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'

restart systemd-resolved.
Apply the changes by restarting the systemd-resolved service:
Código

    sudo systemctl restart systemd-resolved
    
After these steps, systemd-resolved will no longer bind to port 53, freeing it up for Pi-hole. You can then configure your network to use Pi-hole as the DNS server.