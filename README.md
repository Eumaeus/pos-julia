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



## Error Progress

1. Error: 10,362. Validation: 253,807. 
1. Error: 0. Validation: 235,778.
1. Error: 0. Validation: 220.478.
1. Error: 0. Validation: 209,767.
1. Error: 0. Validation: 205,148