# PolyFun + SuSiE fine-mapping (example run on one locus)
# NOTE: this is the template command used per locus; actual locus coordinates
# were taken from the clumped GWS loci (see polyfun.input) and --n was set to
# the trait-specific effective sample size (Neff). --geno points to the
# 1000 Genomes EAS reference panel (PLINK prefix).

mkdir -p LD_cache
mkdir -p output

python finemapper.py \
    --geno  \
    --sumstats example_data/chr1.finemap_sumstats.txt.gz \
    --n 383290 \
    --chr 1 \
    --start 46000001 \
    --end 49000001 \
    --method susie \
    --max-num-causal 5 \
    --cache-dir LD_cache \
    --out output/finemap.1.46000001.49000001.gz
