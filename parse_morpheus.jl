using Base

# Define mapping dictionaries
pos_type_map = Dict(
    "particle" => "g",
    "conj" => "c",
    "prep" => "r",
    "adv" => "d",
    "interj" => "i",
    "pronoun" => "p",
    "article" => "l",
    # Add more if needed, e.g., "numeral" => "m" if 'm' is used for numerals
)

person_map = Dict(
    "1st" => "1",
    "2nd" => "2",
    "3rd" => "3"
)

number_map = Dict(
    "sg" => "s",
    "pl" => "p",
    "dual" => "d"
)

tense_map = Dict(
    "pres" => "p",
    "impf" => "i",
    "fut" => "f",
    "aor" => "a",
    "perf" => "r",
    "plup" => "l",
    "futperf" => "t"
)

mood_map = Dict(
    "ind" => "i",
    "subj" => "s",
    "opt" => "o",
    "imperat" => "m",
    "inf" => "n",
    "part" => "p"
)

voice_map = Dict(
    "act" => "a",
    "mid" => "m",
    "pass" => "p",
    "mp" => "e",
    "dep" => "d"  # If deponent appears
)

gender_map = Dict(
    "masc" => "m",
    "fem" => "f",
    "neut" => "n"
)

case_map = Dict(
    "nom" => "n",
    "gen" => "g",
    "dat" => "d",
    "acc" => "a",
    "voc" => "v",
    "loc" => "l"
)

degree_map = Dict(
    "compar" => "c",
    "superl" => "s"
)

article_lemmas = Set(["o(", "h(", "to/"])

function parse_morpheus(input_file::String, output_file::String, error_log::String)
    lines = readlines(input_file)
    open(output_file, "w") do out
        open(error_log, "w") do err
            for i in 1:2:length(lines)-1  # Assume paired lines
                form = strip(lines[i])
                if isempty(form)
                    continue
                end
                parsing_line = lines[i+1]
                matches = collect(eachmatch(r"<NL>(.*?)</NL>", parsing_line))
                for m in matches
                    content = m.captures[1]
                    tokens = filter(!isempty, split(content, r"\s+"))
                    if length(tokens) < 3
                        write(err, "Invalid parsing: $content\n")
                        continue
                    end
                    morph_pos = tokens[1]
                    lemma_key = tokens[2]
                    attr = tokens[3:end]
                    
                    lemma_parts = split(lemma_key, ",")
                    lemma = lemma_parts[1]
                    
                    # Default tag components
                    pos = ""
                    person = "-"
                    num = "-"
                    tense = "-"
                    mood = "-"
                    voice = "-"
                    gend = "-"
                    cas = "-"  # 'case' is reserved, use cas
                    degree = "-"
                    
                    # Check for indeclform
                    is_indecl = "indeclform" in attr
                    
                    # Remove known non-features if needed, but ignore for now
                    features = copy(attr)
                    
                    # If indecl, type is typically the last token
                    type_str = ""
                    if is_indecl
                        type_str = attr[end]
                        # Remove indeclform and type from features for mapping
                        filter!(a -> a != "indeclform" && a != type_str, features)
                    else
                        # For declinable, last is stem/class, remove it
                        if !isempty(attr)
                            pop!(features)
                        end
                    end
                    
                    # Map features
                    for a in features
                        if haskey(person_map, a)
                            person = person_map[a]
                        elseif haskey(number_map, a)
                            num = number_map[a]
                        elseif haskey(tense_map, a)
                            tense = tense_map[a]
                        elseif haskey(mood_map, a)
                            mood = mood_map[a]
                        elseif haskey(voice_map, a)
                            voice = voice_map[a]
                        elseif haskey(gender_map, a)
                            gend = gender_map[a]
                        elseif haskey(case_map, a)
                            cas = case_map[a]
                        elseif haskey(degree_map, a)
                            degree = degree_map[a]
                        # Ignore dialects like attic, poetic, contr
                        end
                    end
                    
                    # Determine POS
                    if morph_pos == "V"
                        pos = "v"
                    elseif morph_pos == "N"
                        if is_indecl && haskey(pos_type_map, type_str)
                            pos = pos_type_map[type_str]
                        elseif lemma in article_lemmas
                            pos = "l"
                        elseif degree != "-"
                            pos = "a"
                        elseif gend != "-" || cas != "-" || num != "-"  # Has nominal features
                            pos = "n"
                        else
                            pos = "x"  # Irregular or unknown
                        end
                    else
                        write(err, "Unknown morph POS: $morph_pos for $content\n")
                        continue
                    end
                    
                    if isempty(pos)
                        write(err, "Could not determine POS for $content\n")
                        continue
                    end
                    
                    # Construct tag
                    tag = pos * person * num * tense * mood * voice * gend * cas * degree
                    
                    # Output
                    write(out, "$form\t$lemma\t$tag\n")
                end
            end
        end
    end
end

# Function to validate against hand-parsed TSV
function validate_output(output_file::String, hand_tsv::String, validation_log::String)
    # Read output into dict: form => Set of (lemma, tag)
    parsed = Dict{String, Set{Tuple{String, String}}}()
    for line in readlines(output_file)
        parts = split(line, "\t")
        if length(parts) == 3
            form, lemma, tag = parts
            if !haskey(parsed, form)
                parsed[form] = Set{Tuple{String, String}}()
            end
            push!(parsed[form], (lemma, tag))
        end
    end
    
    # Check hand TSV
    open(validation_log, "w") do log
        for line in readlines(hand_tsv)
            parts = split(line, "\t")
            if length(parts) == 4
                form, lemma, tag, urn = parts
                if haskey(parsed, form)
                    if (lemma, tag) in parsed[form]
                        # OK
                    else
                        write(log, "Missing in parsed: $form\t$lemma\t$tag ($urn)\n")
                    end
                else
                    write(log, "Form not found in parsed: $form ($urn)\n")
                end
            end
        end
    end
end

# Usage example
# parse_morpheus("training_analysis.txt", "parsed_output.tsv", "error.log")
# validate_output("parsed_output.tsv", "training_all.tsv", "validation.log")