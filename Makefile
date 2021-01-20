export SHELL:=/bin/bash
.ONESHELL:
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit
UNAME:=$(shell uname)

define help
This is the Makefile for


endef
export help
help:
	@printf "$$help"
.PHONY : help



# ~~~~~ Container ~~~~~ #
# pull the Docker container and convert it to Singularity container image file
export SINGULARITY_CACHEDIR:=$(CURDIR)/cache/#/juno/work/ci/pluto-cwl-test/cache
DOCKER_TAG:=mskcc/unpack_bam:0.1.0
DOCKER_TAG2:=mskcc/bwa_mem:0.7.12
# DOCKER_DEV_TAG:=mskcc/helix_filters_01:dev
# NOTE: you cannot use a filename with a ':' as a Makefile target
SINGULARITY_SIF:=mskcc_unpack_bam:0.1.0.sif
SINGULARITY_SIF2:=mskcc_bwa_mem:0.7.12.sif

singularity-pull:
	unset SINGULARITY_CACHEDIR && \
	module load singularity/3.3.0 && \
	singularity pull --force --name "$(SINGULARITY_SIF)" docker://$(DOCKER_TAG)
	singularity pull --force --name "$(SINGULARITY_SIF2)" docker://$(DOCKER_TAG2)

# shell into the Singularity container to check that it looks right
singularity-shell:
	-module load singularity/3.3.0 && \
	singularity shell "$(SINGULARITY_SIF)"



# ~~~~~ Setup Up and Run the CWL Workflow ~~~~~ #

# reference files

# demo locations for use for development; set these from the command line for real-world usage (not used for CWL input)

# Need to create some psuedo-JSON files for use in creating the input.json


# locations for running the CWL workflow
TMP_DIR:=$(CURDIR)/tmp/
OUTPUT_DIR:=$(CURDIR)/output/
CACHE_DIR:=$(CURDIR)/cache/

$(OUTPUT_DIR):
	mkdir -p "$(OUTPUT_DIR)"

# Run the CWL workflow
# example:
# make run PROJ_ID=10753_B MAF_DIR=/path/to/outputs/maf FACETS_DIR=/path/to/outputs/facets TARGETS_LIST=/juno/work/ci/resources/roslin_resources/targets/HemePACT_v4/b37/HemePACT_v4_b37_targets.ilist OUTPUT_DIR=/path/to/helix_filters

# input file for the CWL workflow; omits some workflow.cwl input fields that have static default values
# input.json:
# 	module load jq/1.6 && \
# 	jq -n \
# 	--arg input_bam "sample1.bam" \
# 	--arg sample_id "sample1" \
# 	--arg picard_jar "/opt/common/CentOS_6-dev/picard/v2.13/picard.jar" \
# 	--arg output_dir "output" \
# 	'{
# 	"input_bam": "sample1.bam",
# 	"sample_id": "sample1",
# 	"picard_jar": "/opt/common/CentOS_6-dev/picard/v2.13/picard.jar",
# 	"output_dir": "output",
# 	}
# 	' > input.json
# .PHONY: input.json


run_unpack: input_json/unpack_input.json $(OUTPUT_DIR)
	module load singularity/3.3.0
	module load cwl/cwltool
	module load python/3.7.1
	if [ ! -e $(SINGULARITY_SIF) ]; then $(MAKE) singularity-pull; fi
	cwl-runner \
	--parallel \
	--leave-tmpdir \
	--tmpdir-prefix $(TMP_DIR) \
	--outdir $(OUTPUT_DIR) \
	--cachedir $(CACHE_DIR) \
	--copy-outputs \
	--singularity \
	--preserve-environment SINGULARITY_CACHEDIR \
	tools/unpack-bam/0.1.0/unpack-bam.cwl input_json/unpack_input.json

run_losslessbam: input_json/losslessBamConver_input.json $(OUTPUT_DIR)
	module load singularity/3.3.0
	module load cwl/cwltool
	module load python/3.7.1
	cwl-runner \
	--parallel \
	--leave-tmpdir \
	--tmpdir-prefix $(TMP_DIR) \
	--outdir $(OUTPUT_DIR) \
	--cachedir $(CACHE_DIR) \
	--copy-outputs \
	--singularity \
	--preserve-environment SINGULARITY_CACHEDIR \
	cwl/losslessbam-workflow.cwl input_json/losslessBamConver_input.json

#if [ ! -e $(SINGULARITY_SIF) ]; then $(MAKE) singularity-pull; fi


# ~~~~~ Debug & Development ~~~~~ #
# Run the test suite


original_N_R1_fastq:=/juno/work/ci/argos-test/data/fastq/DU874145-N/DU874145-N_IGO_00000_TEST_L001_R1_001.fastq.gz #9.1M
original_N_R2_fastq:=/juno/work/ci/argos-test/data/fastq/DU874145-N/DU874145-N_IGO_00000_TEST_L001_R2_001.fastq.gz #9.3M
original_T_R1_fastq:=/juno/work/ci/argos-test/data/fastq/DU874145-T/DU874145-T_IGO_00000_TEST_L001_R1_001.fastq.gz #8.6M
original_T_R2_fastq:=/juno/work/ci/argos-test/data/fastq/DU874145-T/DU874145-T_IGO_00000_TEST_L001_R2_001.fastq.gz #8.5M
unpacked_L1_R1_fastq:=output/fastqs/rg1/foo_tumor_L002_R1_001.fastq.gz #8.6M
unpacked_L1_R2_fastq:=output/fastqs/rg1/foo_tumor_L002_R2_001.fastq.gz #8.5M
unpacked_L2_R1_fastq:=output/fastqs/rg2/foo_tumor_L001_R1_001.fastq.gz #9.1M
unpacked_L2_R2_fastq:=output/fastqs/rg2/foo_tumor_L001_R2_001.fastq.gz #9.3M

test:
	make run_losslessbam
	make run_unpack
	diff <(zcat $(original_N_R1_fastq)) <(zcat $(unpacked_L2_R1_fastq)) 1>/dev/null && echo "test passed" || echo "test failed"
	diff <(zcat $(original_N_R2_fastq)) <(zcat $(unpacked_L2_R2_fastq)) 1>/dev/null && echo "test passed" || echo "test failed"
	diff <(zcat $(original_T_R1_fastq)) <(zcat $(unpacked_L1_R1_fastq)) 1>/dev/null && echo "test passed" || echo "test failed"
	diff <(zcat $(original_T_R2_fastq)) <(zcat $(unpacked_L1_R2_fastq)) 1>/dev/null && echo "test passed" || echo "test failed"







# interactive session with environment populated
bash:
	module load singularity/3.3.0 && \
	module load python/3.7.1 && \
	module load cwl/cwltool && \
	module load jq && \
	bash

clean:
	rm -rf cache tmp
