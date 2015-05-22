NULLGRAPH=../nullgraph
KHMER=../khmer

all: reads-a.fa genomes.fa

clean:
	-rm -f genome-?.fa reads-?.fa *.graph *.labels *.list 

genomes.fa:
	$(NULLGRAPH)/make-random-genome.py -l 1000 -s 1 --name='genomeA' > genome-a.fa
	$(NULLGRAPH)/make-random-genome.py -l 1000 -s 2 --name='genomeB' > genome-b.fa
	cat genome-a.fa genome-b.fa > genomes.fa

reads-a.fa: genomes.fa
	$(NULLGRAPH)/make-reads.py -r 100 -C 10 -S 1 genome-a.fa | head -6 > reads-a.fa
