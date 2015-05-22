#! /usr/bin/env python
import screed
import khmer
import argparse
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('data_a')
    parser.add_argument('data_b')

    parser.add_argument('-k', type=int, dest='ksize', default=21)
    parser.add_argument('-x', type=float, dest='tablesize', default=1e7)
    parser.add_argument('-N', type=int, dest='n_tables', default=4)
    parser.add_argument('--noload-b', action='store_true', default=False)
    parser.add_argument('--align-b', action='store_true', default=False)
    parser.add_argument('--align-trusted', type=int, default=1)
    parser.add_argument('--traverse', type=int, default=0)
    parser.add_argument('--skip-sweep-a', action='store_true', default=False)

    args = parser.parse_args()

    lh = khmer.CountingLabelHash(args.ksize, args.tablesize, args.n_tables)
    aligner = khmer.ReadAligner(lh.graph, args.align_trusted, 1.0)

    # label everything in data_a with 1
    for n, record in enumerate(screed.open(args.data_a)):
        if n % 10000 == 0:
            print >>sys.stderr, '...', n

        seq = record.sequence.replace('N', 'A')
        lh.consume_sequence_and_tag_with_labels(seq, 1)

    # label everything in data_b with 2
    if not args.noload_b:
        for n, record in enumerate(screed.open(args.data_b)):
            if n % 10000 == 0:
                print >>sys.stderr, '...2', n

            seq = record.sequence.replace('N', 'A')
            if args.align_b:
                _, alignment, _, trunc = aligner.align(seq)
                if not trunc:
                    seq = alignment.replace('-', '')
            lh.consume_sequence_and_tag_with_labels(seq, 2)

    # now ask about overlap.
    if not args.skip_sweep_a:
        tags_a = set()
        for n, record in enumerate(screed.open(args.data_a)):
            if n % 10000 == 0:
                print >>sys.stderr, '...3', n

            seq = record.sequence.replace('N', 'A')
            if len(seq) > args.ksize:
                tags_a.update(lh.sweep_tag_neighborhood(seq, args.traverse))
    else:
        assert 0, "this doesn't work yet"

    tags_b = set()
    for n, record in enumerate(screed.open(args.data_b)):
        if n % 10000 == 0:
            print >>sys.stderr, '...4', n

        seq = record.sequence.replace('N', 'A')
        if args.align_b:
            _, alignment, _, trunc = aligner.align(seq)
            if not trunc:
                seq = alignment.replace('-', '')
        if len(seq) > args.ksize:
            tags_b.update(lh.sweep_tag_neighborhood(seq, args.traverse))

    print 'all tags:', len(tags_a.union(tags_b))
    print 'n tags in A:', len(tags_a)
    print 'n tags in B:', len(tags_b)
    print 'tags in A but not in B', len(tags_a - tags_b)
    print 'tags in B but not in A', len(tags_b - tags_a) 


if __name__ == '__main__':
    main()
