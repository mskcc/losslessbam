export SHELL:=/bin/bash
.ONESHELL:
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit
UNAME:=$(shell uname)


# ~~~~~ Container ~~~~~ #
# pull the Docker container and convert it to Singularity container image file
export SINGULARITY_CACHEDIR:=$(CURDIR)/cache/#/juno/work/ci/pluto-cwl-test/cache
DOCKER_TAG:=mskcc/unpack_bam:0.1.0
DOCKER_TAG2:=mskcc/bwa_mem:0.7.12
DOCKER_TAG3:=mjblow/samtools-1.9
DOCKER_TAG4:=mskcc/roslin-variant-cmo-utils:1.9.15
DOCKER_TAG5:=mskcc/roslin-variant-picard:2.9
DOCKER_TAG6:=mskcc/roslin-variant-samtools:1.3.1


# DOCKER_DEV_TAG:=mskcc/helix_filters_01:dev
# NOTE: you cannot use a filename with a ':' as a Makefile target
SINGULARITY_SIF:=mskcc_unpack_bam:0.1.0.sif
SINGULARITY_SIF2:=mskcc_bwa_mem:0.7.12.sif
SINGULARITY_SIF3:=mjblow_samtools-1.9:latest.sif
SINGULARITY_SIF4:=mskcc_roslin-variant-cmo-utils:1.9.15.sif
SINGULARITY_SIF5:=mskcc_roslin-variant-picard:2.9.sif
SINGULARITY_SIF6:=mskcc_roslin-variant-samtools:1.3.1.sif


singularity-pull:
	unset SINGULARITY_CACHEDIR && \
	module load singularity/3.3.0 && \
	singularity pull --force --name "$(SINGULARITY_SIF)" docker://$(DOCKER_TAG)
	singularity pull --force --name "$(SINGULARITY_SIF2)" docker://$(DOCKER_TAG2)
	singularity pull --force --name "$(SINGULARITY_SIF3)" docker://$(DOCKER_TAG3)
	singularity pull --force --name "$(SINGULARITY_SIF4)" docker://$(DOCKER_TAG4)
	singularity pull --force --name "$(SINGULARITY_SIF5)" docker://$(DOCKER_TAG5)
	singularity pull --force --name "$(SINGULARITY_SIF6)" docker://$(DOCKER_TAG6)

# shell into the Singularity container to check that it looks right
singularity-shell:
	-module load singularity/3.3.0 && \
	singularity shell "$(SINGULARITY_SIF)"



# locations for running the CWL workflow
TMP_DIR:=$(CURDIR)/tmp/
OUTPUT_DIR:=$(CURDIR)/output/
CACHE_DIR:=$(CURDIR)/cache/

$(OUTPUT_DIR):
	mkdir -p "$(OUTPUT_DIR)"


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
	argos-cwl/tools/unpack-bam/0.1.0/unpack-bam.cwl input_json/unpack_input.json

run_losslessbam: input_json/losslessBamConvert_input.json $(OUTPUT_DIR)
	module load singularity/3.3.0
	module load cwl/cwltool
	module load python/3.7.1
	if [ ! -e $(SINGULARITY_SIF2) ]; then $(MAKE) singularity-pull; fi
	if [ ! -e $(SINGULARITY_SIF3) ]; then $(MAKE) singularity-pull; fi
	if [ ! -e $(SINGULARITY_SIF4) ]; then $(MAKE) singularity-pull; fi
	if [ ! -e $(SINGULARITY_SIF5) ]; then $(MAKE) singularity-pull; fi
	if [ ! -e $(SINGULARITY_SIF6) ]; then $(MAKE) singularity-pull; fi
	cwl-runner \
	--parallel \
	--leave-tmpdir \
	--tmpdir-prefix $(TMP_DIR) \
	--outdir $(OUTPUT_DIR) \
	--cachedir $(CACHE_DIR) \
	--copy-outputs \
	--singularity \
	--preserve-environment SINGULARITY_CACHEDIR \
	cwl/losslessbam-workflow.cwl input_json/losslessBamConvert_input.json


original_L1_R1_fastq:=/work/ci/vurals/losslessbam/temp_dir/Sample_ID_L001_R1.fastq.gz
original_L2_R1_fastq:=/work/ci/vurals/losslessbam/temp_dir/Sample_ID_L002_R1.fastq.gz
original_L1_R2_fastq:=/work/ci/vurals/losslessbam/temp_dir/Sample_ID_L001_R2.fastq.gz
original_L2_R2_fastq:=/work/ci/vurals/losslessbam/temp_dir/Sample_ID_L002_R2.fastq.gz

unpacked_L1_R1_fastq:=output/fastqs/Sample_ID_L001_R1_001.fastq.gz
unpacked_L1_R2_fastq:=output/fastqs/Sample_ID_L001_R2_001.fastq.gz
unpacked_L2_R1_fastq:=output/fastqs/Sample_ID_L002_R1_001.fastq.gz
unpacked_L2_R2_fastq:=output/fastqs/Sample_ID_L002_R2_001.fastq.gz

test:
	make run_losslessbam
	make run_unpack
	mv output/fastqs/rg*/*.gz output/fastqs/;rm -rf output/fastqs/rg*;
	diff <(zcat $(original_L1_R1_fastq)) <(zcat $(unpacked_L1_R1_fastq)) 1>/dev/null && echo "test passed" || echo "test failed";
	diff <(zcat $(original_L1_R2_fastq)) <(zcat $(unpacked_L1_R2_fastq)) 1>/dev/null && echo "test passed" || echo "test failed";
	diff <(zcat $(original_L2_R1_fastq)) <(zcat $(unpacked_L2_R1_fastq)) 1>/dev/null && echo "test passed" || echo "test failed";
	diff <(zcat $(original_L2_R2_fastq)) <(zcat $(unpacked_L2_R2_fastq)) 1>/dev/null && echo "test passed" || echo "test failed";





# interactive session with environment populated
bash:
	module load singularity/3.3.0 && \
	module load python/3.7.1 && \
	module load cwl/cwltool && \
	module load jq && \
	bash

clean:
	rm -rf cache tmp
