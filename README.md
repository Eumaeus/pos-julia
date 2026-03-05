# POSJulia

Interpret output from Morpheus (see <https://hub.docker.com/r/perseidsproject/morpheus/> and <https://github.com/perseids-tools/morpheus?tab=readme-ov-file>) as triplets of `form`, `lemma`, and `POS-tag`. See <https://github.com/Eumaeus/pos-tagger>.

## Usage

```
julia
include("parse_morpheus.jl")
parse_morpheus("training/training_analysis.txt", "output/parsed_output.tsv", "output/error.log")
validate_output("output/parsed_output.tsv", "training/training_all.tsv", "output/validation.log")
```

parse_morpheus("training/training_analysis.txt", "output/parsed_output.tsv", "output/error.log")



