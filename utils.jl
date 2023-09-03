using PkgPage

"""
hfun_rawoutput(params::Vector{String})

Include the raw file contents with no conversions
"""
function hfun_rawoutput(params::Vector{String})
    outpath  = Franklin.form_codepaths(params[1]).out_path
    # does output exist?
    isfile(outpath) || return html_err("`$(params[1])`: could not find the " *
                                       "relevant output file.")
    return read(outpath, String)
end