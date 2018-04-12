# SparCC implementation comparison
The scripts in this repository run and compare the results of four implementations of the [`SparCC`](http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1002687) algorithm (`SparCC`, `FastSpar`, `SpiecEasi SparCC`, `mothur SparCC`). The high level description of processes taken here is:
1. Set up a clean and reproducible run environment using `chroot`
2. Resolve all dependencies for the `SparCC` implementations
3. Provision the implementation software itself
4. Generate a small and medium sized OTU table by randomly subsetting a large OTU table
5. Run software implementations, once for each randomly generated OTU tables
6. Plot and compare results

# Performing this analysis
## Requirements
There are a few requirements to run this analysis:
* A modern computer with amd64 architecture running GNU/Linux
* Run commands as a supseruser (e.g. using `sudo`)
* Have `debootstrap` installed
* An internet connection


## Running
To run this analysis, a `chroot` environment is first required. The following commands will create a Ubuntu 16.04 (Xenial) `chroot` in the current working directory named `ubuntu_chroot` and run an interactive shell with it:
```bash
# Set up chroot environment
sudo debootstrap xenial ubuntu_chroot http://archive.ubuntu.com/ubuntu/

# Chroot into environment
sudo chroot ubuntu_chroot/
```

Next the appropriate dependencies must be installed within the `chroot`:
```bash
# Add Universe repository
echo 'deb http://archive.ubuntu.com/ubuntu xenial main universe' > /etc/apt/sources.list

# Install packages
apt-get update
apt-get install -y git mercurial build-essential autoconf libarmadillo-dev libgsl-dev libopenblas-dev python-numpy python-pandas libcurl4-openssl-dev libssl-dev r-base r-cran-vgam r-cran-igraph r-cran-digest time wget ca-certificates --no-install-recommends
```

Finally this repository can be cloned and the analysis run:
```bash
# Change into tmp directory
cd /tmp/

# Clone repo and perform analysis
git clone https://github.com/scwatts/sparcc_implementation_comparison
cd sparcc_implementation_comparison
./run.sh
```

Note: some processes are parallised and are set to uses 10 threads. If your machine has less than this, you'll need to edit the `run.sh` script to specify the number of threads to use.
