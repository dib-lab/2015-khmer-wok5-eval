NULLGRAPH=$(HOME)/nullgraph
KHMER=$(HOME)/khmer

all: reads-b.fa genomes.fa fake_a fake_b fake_c rna-compare-noalign.txt \
	rna-compare-align.txt rseq-hardtrim-ab.txt \
	rseq-hardtrim-ba-noalign.txt rseq-hardtrim-ba-align5.txt \
	rseq-hardtrim-ba-align1.txt

clean:
	-rm -f genome-?.fa reads-?.fa *.graph *.labels *.list 

genomes.fa:
	$(NULLGRAPH)/make-random-genome.py -l 1000 -s 1 --name='genomeA' > genome-a.fa
	$(NULLGRAPH)/make-random-genome.py -l 1000 -s 2 --name='genomeB' > genome-b.fa
	cat genome-a.fa genome-b.fa > genomes.fa

reads-b.fa: genomes.fa
	$(NULLGRAPH)/make-reads.py -r 100 -C 10 -S 1 genome-b.fa > reads-b.fa

fake_a:  genomes.fa
	./compare-graphs.py genomes.fa genome-b.fa

fake_b: genomes.fa reads-b.fa
	./compare-graphs.py genomes.fa reads-b.fa

fake_c: genomes.fa reads-b.fa
	./compare-graphs.py genomes.fa reads-b.fa --align-b

fake_d: genomes.fa reads-b.fa
	./compare-graphs.py genomes.fa reads-b.fa --align-b --traverse=40

rna-compare-noalign.txt: rna.fa rseq-mapped.fq.gz
	./compare-graphs.py rna.fa rseq-mapped.fq.gz > rna-compare-noalign.txt

rna-compare-align.txt: rna.fa rseq-mapped.fq.gz
	./compare-graphs.py rna.fa rseq-mapped.fq.gz --align-b > rna-compare-align.txt

rseq-hardtrim.fq.gz: rseq-mapped.fq.gz
	TrimmomaticSE rseq-mapped.fq.gz rseq-hardtrim.fq.gz SLIDINGWINDOW:4:30

rseq-hardtrim-ab.txt: rseq-mapped.fq.gz rseq-hardtrim.fq.gz
	./compare-graphs.py rseq-mapped.fq.gz rseq-hardtrim.fq.gz > rseq-hardtrim-ab.txt

rseq-hardtrim-ba-noalign.txt: rseq-mapped.fq.gz rseq-hardtrim.fq.gz
	./compare-graphs.py rseq-hardtrim.fq.gz rseq-mapped.fq.gz > rseq-hardtrim-ba-noalign.txt

rseq-hardtrim-ba-align5.txt: rseq-mapped.fq.gz rseq-hardtrim.fq.gz
	./compare-graphs.py --align-trusted=5 --align-b rseq-hardtrim.fq.gz rseq-mapped.fq.gz > rseq-hardtrim-ba-align5.txt

rseq-hardtrim-ba-align1.txt: rseq-mapped.fq.gz rseq-hardtrim.fq.gz
	./compare-graphs.py --align-trusted=1 --align-b rseq-hardtrim.fq.gz rseq-mapped.fq.gz > rseq-hardtrim-ba-align1.txt 
