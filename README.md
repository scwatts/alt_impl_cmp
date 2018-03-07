```bash
# Set up chroot environment
sudo debootstrap xenial ubuntu_chroot http://archive.ubuntu.com/ubuntu/

# Chroot into environment
sudo chroot ubuntu_chroot/

# Add Universe repository
echo 'deb http://archive.ubuntu.com/ubuntu xenial main universe' > /etc/apt/sources.list

# Install packages
apt-get update
apt-get install -y git mercurial build-essential libarmadillo-dev libgsl-dev libopenblas-dev python-numpy python-pandas libcurl4-openssl-dev libssl-dev r-base r-cran-vgam r-cran-igraph r-cran-digest time wget ca-certificates --no-install-recommends

# Change into tmp directory
cd /tmp/

# Clone repo and perform timed runs
git clone https://github.com/scwatts/alt_impl_cmp
cd alt_impl_cmp
./run.sh
```
