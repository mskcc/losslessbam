head -400 DU874145-N_IGO_00000_TEST_L001_R1_001.fastq | gzip > N_L001_R1.fastq.gz
tail -n400 DU874145-N_IGO_00000_TEST_L001_R1_001.fastq | gzip  > N_L002_R1.fastq.gz
head -400 DU874145-N_IGO_00000_TEST_L001_R2_001.fastq | gzip > N_L001_R2.fastq.gz
tail -n400 DU874145-N_IGO_00000_TEST_L001_R2_001.fastq | gzip > N_L002_R2.fastq.gz
