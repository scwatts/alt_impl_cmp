# Software parameters
RNG_SEED=0;
SAMPLE_COUNT=500;
OTU_COUNT=1000;
ITERATIONS=50;
XITERATIONS=10;

# Provision software
echo 'Provisioning software'
mkdir temp software
{ wget -P temp/ https://github.com/mothur/mothur/releases/download/v1.39.5/Mothur.linux_64_static.zip;
unzip temp/Mothur.linux_64_static.zip -d temp/; } 2>/dev/null 1>&2
mv temp/mothur software/

{ git clone https://github.com/scwatts/fastspar.git temp/fastspar/;
(cd temp/fastspar/; ./configure --prefix=$(pwd -P); make install -j); } 2>/dev/null 1>&2
mv temp/fastspar/bin software/fastspar

yes | rm -r temp/

# Provision data
echo 'Generating data subset'
gzip -d data/otu_table_cluster_99_collapsed.tsv.gz
./scripts/generate_random_subsets.py -c data/otu_table_cluster_99_collapsed.tsv -a "${SAMPLE_COUNT}" -t "${OTU_COUNT}" -s "${RNG_SEED}" > data/otu_table_subset_500_1000.tsv
./scripts/biom_tsv_to_mothur.py --input_fp data/otu_table_subset_500_1000.tsv > data/otu_table_subset_500_1000_mothur.tsv

# Run software
mkdir output profiles
echo 'Fastspar (single thread)'
/usr/bin/time -v ./software/fastspar/fastspar -c data/otu_table_subset_500_1000.tsv -r output/fastspar_cor.tsv -a output/fastspar_cov.tsv -i "${INTERATIONS}" -x "${XITERATIONS}" -y 2>profiles/fastspar_500_1000.tsv 1>/dev/null

echo 'Fastspar (10 threads)'
/usr/bin/time -v ./software/fastspar/fastspar -c data/otu_table_subset_500_1000.tsv -r output/fastspar_cor_threaded.tsv -a output/fastspar_cov_threaded.tsv -i "${ITERATIONS}" -x "${XITERATIONS}" -t 10 -y 2>profiles/fastspar_500_1000_threaded.tsv 1>/dev/null

echo 'Mothur SparCC'
/usr/bin/time -v ./software/mothur/mothur "#sparcc(shared=data/otu_table_subset_500_1000_mothur.tsv, samplings=${ITERATIONS}, iterations=${XITERATIONS}, permutations=0, processors=1)" 2>profiles/mothur_500_1000.tsv 1>/dev/null
mv data/otu_table_subset_500_1000_mothur.1.sparcc_{correlation,relabund} output/
