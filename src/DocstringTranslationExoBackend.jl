module DocstringTranslationExoBackend

using Base.Docs: DocStr, Binding
using REPL: find_readme
import REPL
using Markdown

using HTTP
using JSON3
using DataFrames
using ProgressMeter

const EXO_BASE_URL = get(ENV, "EXO_BASE_URL", "http://localhost:52415")
const DEFAULT_MODEL = Ref{String}("gemma2-9b")
const DEFAULT_LANG = Ref{String}("English")

export @switchlang!, @revertlang!
export listmodel, switchmodel!

function switchlang!(lang::Union{String,Symbol})
    DEFAULT_LANG[] = String(lang)
end

function switchlang!(node::QuoteNode)
    lang = node.value
    switchlang!(lang)
end

"""
    @switchlang!(lang)

Modify the behavior of the `Docs.parsedoc(d::DocStr)` to insert translation engine.
"""
macro switchlang!(lang)
    switchlang!(lang)
    @eval function Docs.parsedoc(d::DocStr)
        if d.object === nothing
            md = Docs.formatdoc(d)
            md.meta[:module] = d.data[:module]
            md.meta[:path] = d.data[:path]
            d.object = md
        end
        translate_with_exo(d.object, string($(lang)))
    end

    @eval function REPL.summarize(io::IO, m::Module, binding::Binding; nlines::Int = 200)
        readme_path = find_readme(m)
        public = Base.ispublic(binding.mod, binding.var) ? "public" : "internal"
        if isnothing(readme_path)
            println(io, "No docstring or readme file found for $public module `$m`.\n")
        else
            println(io, "No docstring found for $public module `$m`.")
        end
        exports = filter!(!=(nameof(m)), names(m))
        if isempty(exports)
            println(io, "Module does not have any public names.")
        else
            println(io, "# Public names")
            print(io, "  `")
            join(io, exports, "`, `")
            println(io, "`\n")
        end
        if !isnothing(readme_path)
            readme_lines = readlines(readme_path)
            isempty(readme_lines) && return  # don't say we are going to print empty file
            println(io, "# Displaying contents of readme found at `$(readme_path)`")
            translated_md = translate_with_exo(join(first(readme_lines, nlines), '\n'), string($(lang)))
            readme_lines = split(string(translated_md), '\n')
            for line in readme_lines
                println(io, line)
            end
        end
    end
end

"""
    @revertlang!

re-evaluate the original implementation for 
`Docs.parsedoc(d::DocStr)`
"""
macro revertlang!()
    switchlang!("English")
    @eval function Docs.parsedoc(d::DocStr)
        if d.object === nothing
            md = Docs.formatdoc(d)
            md.meta[:module] = d.data[:module]
            md.meta[:path] = d.data[:path]
            d.object = md
        end
        d.object
    end

    @eval function REPL.summarize(io::IO, m::Module, binding::Binding; nlines::Int = 200)
        readme_path = find_readme(m)
        public = Base.ispublic(binding.mod, binding.var) ? "public" : "internal"
        if isnothing(readme_path)
            println(io, "No docstring or readme file found for $public module `$m`.\n")
        else
            println(io, "No docstring found for $public module `$m`.")
        end
        exports = filter!(!=(nameof(m)), names(m))
        if isempty(exports)
            println(io, "Module does not have any public names.")
        else
            println(io, "# Public names")
            print(io, "  `")
            join(io, exports, "`, `")
            println(io, "`\n")
        end
        if !isnothing(readme_path)
            readme_lines = readlines(readme_path)
            isempty(readme_lines) && return  # don't say we are going to print empty file
            println(io, "# Displaying contents of readme found at `$(readme_path)`")
            for line in first(readme_lines, nlines)
                println(io, line)
            end
            length(readme_lines) > nlines && println(io, "\n[output truncated to first $nlines lines]")
        end
    end
end

function revertlang!()
    DEFAULT_LANG[] = "English"
end

function switchmodel!(model::Union{String,Symbol})
    DEFAULT_MODEL[] = string(model)
end

function default_model()
    return DEFAULT_MODEL[]
end

function default_lang()
    return DEFAULT_LANG[]
end

function default_promptfn(
    m::Union{Markdown.MD, AbstractString},
    language::String = default_lang(),
)
    prompt = """
Translate the following JuliaLang Markdown based docstring in $(language) line by line. Just return the result.

\"\"\"
$(m)
\"\"\"

Please start. Please brace with 3 double quotations. 
"""
    return prompt
end

function translate_with_exo(
    doc::Union{Markdown.MD, AbstractString},
    language::String = default_lang(),
    model::String = default_model(),
    promptfn::Function = default_promptfn,
)
    prompt = promptfn(doc)
    chat_response = HTTP.post(
        joinpath(EXO_BASE_URL, "v1", "chat", "completions"),
        Dict("Content-Type" => "application/json"),
        Dict(
            "model" => model,
            "messages" => [Dict("role" => "user", "content" => prompt)],
            "stream" => false,
        ) |> JSON3.write,
    )
    chat_json_body = JSON3.read(chat_response.body)
    content = replace(chat_json_body[:choices][begin][:message][:content], "<end_of_turn>" => "")
    doclines = split(content, "\n")
    if startswith(first(doclines), "\"\"\"")
        popfirst!(doclines)
    end
    if startswith(last(doclines), "\"\"\"")
        pop!(doclines)
    end
    docstr = join(doclines, "\n")
    Markdown.parse(docstr)
end

end # module DocstringTranslationExoBackend
