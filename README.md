# losslessbam
Temporary repo for losslessbam creation workflow.

The Makefile includes three recepies:
* `run_losslessbam` takes the fastq.gz files defined in `input_json/losslessBamConvert_input.json`

* `run_unpack` converts the input bam file defined in `input_json/unpack_input .json` to fastq files. It also creastes two informational text files.

* `test` takes 4 fastq.gz files generates the bam file, unpacks and compares to the original fastq.gz files.

#### Important note about cloning the repo
To clone with the submodule use: `git clone --recurse-submodules git@github.com:mskcc/losslessbam.git`
