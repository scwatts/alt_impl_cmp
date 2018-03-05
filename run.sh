# Parameters
RNG_SEED=0
MID_SAMPLE_COUNT=500
MID_OTU_COUNT=1000
SML_SAMPLE_COUNT=200
SML_OTU_COUNT=50
ITERATIONS=50
XITERATIONS=10

DATA_DIR=data
OUTPUT_DIR=output
PROFILE_DIR=profile
SOFTWARE_DIR=software
TEMP_DIR=temp

# Functions
function run_software {
  DATA_FP=$1
  DATA_MOTHUR_FP=$2
  FULL_OUTPUT_DIR=$3
  FULL_PROFILE_DIR=$4
  ITERATIONS=$5
  XITERATIONS=$6
  SAMPLES=$7
  OTUS=$8

  echo 'Fastspar (single thread)'
  /usr/bin/time -v ./software/fastspar/fastspar -c "${DATA_FP}" -r "${FULL_OUTPUT_DIR}"/fastspar_cor.tsv -a "${FULL_OUTPUT_DIR}"/fastspar_cov.tsv -i "${ITERATIONS}" -x "${XITERATIONS}" -y 2>"${FULL_PROFILE_DIR}"/fastspar_"${SAMPLES}"_"${OTUS}".tsv 1>/dev/null

  echo 'Fastspar (10 threads)'
  /usr/bin/time -v ./software/fastspar/fastspar -c "${DATA_FP}" -r "${FULL_OUTPUT_DIR}"/fastspar_cor_threaded.tsv -a "${FULL_OUTPUT_DIR}"/fastspar_cov_threaded.tsv -i "${ITERATIONS}" -x "${XITERATIONS}" -t 10 -y 2>"${FULL_PROFILE_DIR}"/fastspar_threaded_"${SAMPLES}"_"${OTUS}".tsv 1>/dev/null

  echo 'SpiecEasi SparCC'
  /usr/bin/time -v ./scripts/run_spieceasi.R "${ITERATIONS}" "${XITERATIONS}" "${DATA_FP}" "${FULL_OUTPUT_DIR}"/spieceasi_cor.tsv 2>"${FULL_PROFILE_DIR}"/spieceasi_"${SAMPLES}"_"${OTUS}".tsv 1>/dev/null

  echo 'Mothur SparCC'
  DATA_MOTHUR_FN="${DATA_MOTHUR_FP##*/}"
  MOTHUR_BASE_FP="${DATA_MOTHUR_FP%/*}/${DATA_MOTHUR_FN/.tsv/}.1.sparcc_"
  /usr/bin/time -v timeout 3h ./software/mothur/mothur "#sparcc(shared=${DATA_MOTHUR_FP}, samplings=${ITERATIONS}, iterations=${XITERATIONS}, permutations=0, processors=1)" 2>"${FULL_PROFILE_DIR}"/mothur_"${SAMPLES}"_"${OTUS}".tsv 1>/dev/null
  mv "${MOTHUR_BASE_FP}correlation" "${FULL_OUTPUT_DIR}"/mothur_cor.tsv
  rm "${MOTHUR_BASE_FP}relabund"
}

# Provision software
MOTHUR_URL=https://github.com/mothur/mothur/releases/download/v1.39.5/Mothur.linux_64_static.zip
FASTSPAR_URL=https://github.com/scwatts/fastspar.git

echo 'Provisioning software'
mkdir -p "${TEMP_DIR}" "${SOFTWARE_DIR}"
{ wget -P "${TEMP_DIR}" "${MOTHUR_URL}"
unzip temp/Mothur.linux_64_static.zip -d temp/; } 2>/dev/null 1>&2
mv "${TEMP_DIR}"/mothur "${SOFTWARE_DIR}"

{ git clone "${FASTSPAR_URL}" "${TEMP_DIR}"/fastspar/
(cd "${TEMP_DIR}"/fastspar/; ./configure --prefix=$(pwd -P); make install -j); } 2>/dev/null 1>&2
mv "${TEMP_DIR}"/fastspar/bin "${SOFTWARE_DIR}"/fastspar

R -e "install.packages('devtools', repos='http://cran.rstudio.com/'); library(devtools); install_github('zdk123/SpiecEasi');" 2>/dev/null 1>&2

yes | rm -r temp/

# Provision data
OTU_TABLE_FP_GZ="${DATA_DIR}"/otu_table_cluster_99_collapsed.tsv.gz
OTU_TABLE_FP="${OTU_TABLE_FP_GZ/.gz/}"
MID_DATA_FP="${DATA_DIR}"/otu_table_subset_"${MID_SAMPLE_COUNT}"_"${MID_OTU_COUNT}".tsv
MID_DATA_MOTHUR_FP="${MID_DATA_FP/.tsv/_mothur.tsv}"
SML_DATA_FP="${DATA_DIR}"/otu_table_subset_"${SML_SAMPLE_COUNT}"_"${SML_OTU_COUNT}".tsv
SML_DATA_MOTHUR_FP="${SML_DATA_FP/.tsv/_mothur.tsv}"

echo 'Generating data subset'
gzip -d "${OTU_TABLE_FP_GZ}"
./scripts/generate_random_subsets.py -c "${OTU_TABLE_FP}" -a "${SML_SAMPLE_COUNT}" -t "${SML_OTU_COUNT}" -s "${RNG_SEED}" > "${SML_DATA_FP}"
./scripts/biom_tsv_to_mothur.py --input_fp "${SML_DATA_FP}" > "${SML_DATA_MOTHUR_FP}"
./scripts/generate_random_subsets.py -c "${OTU_TABLE_FP}" -a "${MID_SAMPLE_COUNT}" -t "${MID_OTU_COUNT}" -s "${RNG_SEED}" > "${MID_DATA_FP}"
./scripts/biom_tsv_to_mothur.py --input_fp "${MID_DATA_FP}" > "${MID_DATA_MOTHUR_FP}"

# Run software
mkdir -p {"${OUTPUT_DIR}","${PROFILE_DIR}"}/{large,small}
echo 'Small dataset, for results comparison'
run_software "${SML_DATA_FP}" "${SML_DATA_MOTHUR_FP}" "${OUTPUT_DIR}"/small "${PROFILE_DIR}"/small "${ITERATIONS}" "${XITERATIONS}" "${SML_SAMPLE_COUNT}" "${SML_OTU_COUNT}"

echo 'Mid-sized dataset, for profiling'
run_software "${MID_DATA_FP}" "${MID_DATA_MOTHUR_FP}" "${OUTPUT_DIR}"/large "${PROFILE_DIR}"/large "${ITERATIONS}" "${XITERATIONS}" "${MID_SAMPLE_COUNT}" "${MID_OTU_COUNT}"

# Collect data
./scripts/collect_profile_data.py --profile_log_fps profiles/* --output output/profiles.tsv
